// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IENSToken } from "@ens/interfaces/IENSToken.sol";

abstract contract ENS_Governance is Test {
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 public constant TIMELOCK_ADMIN_ROLE = keccak256("TIMELOCK_ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
    address public proposer;
    address public voter;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IGovernor public governor;
    ITimelock public timelock;
    IENSToken public ensToken;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        vm.createSelectFork({ blockNumber: 20_836_390, urlOrAlias: "mainnet" });
        
        // Governance contracts ENS
        ensToken = IENSToken(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);
        governor = IGovernor(0x323A76393544d5ecca80cd6ef2A560C6a395b7E3);
        timelock = ITimelock(payable(0xFe89cc7aBB2C4183683ab71653C4cdc9B02D44b7));
        proposer = _proposer();
        voter = _voter();
        // Label the base test contracts.
        vm.label(address(governor), "governor");
        vm.label(address(timelock), "timelock");
        vm.label(address(ensToken), "ensToken");
    }
    // Executing each step necessary on the proposal lifecycle to understand attack vectors
    function test_proposal() public {
        // Delegate from top token holder
        vm.prank(voter);
        ensToken.delegate(voter);

        // Need to advance 1 block for delegation to be valid on governor
        vm.roll(block.number + 1);
        
        assertGt(ensToken.getVotes(voter), governor.quorum(block.number - 1));
        assertGt(ensToken.getVotes(proposer), governor.proposalThreshold());


        // Creating a proposal that gives a proposer role to
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas) = _generateCallData();

        string memory description = "";
        bytes32 descriptionHash = keccak256(bytes(description));

        // Governor
        // Submit proposal
        _beforePropose();

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        assertEq(governor.state(proposalId), 0);

        // Proposal is ready to vote after 2 block because of the revert ERC20Votes: block not yet mined
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(governor.state(proposalId), 1);

        // Vote for the proposal
        vm.prank(voter);
        governor.castVote(proposalId, 1);

        // Let the voting end
        vm.roll(block.number + governor.votingPeriod());
        assertEq(governor.state(proposalId), 4);

        // Queue the proposal to be executed
        governor.queue(targets, values, calldatas, descriptionHash);
        assertEq(governor.state(proposalId), 5);

        // Calculate proposalId in timelock
        bytes32 proposalIdInTimelock = timelock.hashOperationBatch(targets, values, calldatas, 0, descriptionHash);
        assertTrue(timelock.isOperationPending(proposalIdInTimelock));

        // Wait the operation in the DAO wallet timelock to be Ready
        vm.warp(block.timestamp + timelock.getMinDelay() + 1);
        assertTrue(timelock.isOperationReady(proposalIdInTimelock));

        // Execute proposal
        governor.execute(targets, values, calldatas, descriptionHash);
        assertTrue(timelock.isOperationDone(proposalIdInTimelock));

        _afterExecution();
    }

    function _proposer() internal virtual view returns (address);

    function _voter() internal virtual view returns (address) {
        return 0xd7A029Db2585553978190dB5E85eC724Aa4dF23f;
    }

    function _beforePropose() internal virtual;

    function _generateCallData() internal virtual returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas);

    function _afterExecution() internal virtual;
}
