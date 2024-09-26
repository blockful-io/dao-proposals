// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { Users } from "../../contracts/utils/Types.sol";

import { IToken } from "../../dao/ens/interfaces/IToken.sol";
import { IGovernor } from "../../dao/ens/interfaces/IGovernor.sol";
import { ITimelock } from "../../dao/ens/interfaces/ITimelock.sol";
import { IERC20 } from "../../contracts/token/interfaces/IERC20.sol";

contract Attack_DAO_Test is Test {
    uint256 USDCbalanceBefore;
    uint256 expectedUSDCtransfer = 1218669760000;
    uint256 USDCbalanceAfter;
    address receiver = 0x690F0581eCecCf8389c223170778cD9D029606F2; // ENS Labs

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
    Users internal users;

    /*//////////////////////////////////////////////////////////////////////////
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IToken public token;
    IGovernor public governor;
    ITimelock public timelock;
    address public proposer;
    address public voter;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        vm.createSelectFork({ blockNumber: 20_836_390, urlOrAlias: "mainnet" });

        // Create users for testing.
        users = Users({
            deployer: makeAddr("Deployer"),
            alice: makeAddr("Alice"),
            securityCouncilMultisig: address(0x53589828690662ead300299fF70aE11FD1AF9A16),
            attacker: makeAddr("Attacker")
        });

        // Governance contracts ENS
        token = IToken(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);
        governor = IGovernor(0x323A76393544d5ecca80cd6ef2A560C6a395b7E3);
        timelock = ITimelock(payable(0xFe89cc7aBB2C4183683ab71653C4cdc9B02D44b7));
        proposer = _proposer();
        voter = _voter();
        // Label the base test contracts.
        vm.label(address(governor), "governor");
        vm.label(address(timelock), "timelock");
        vm.label(address(token), "token");
    }
    // Executing each step necessary on the proposal lifecycle to understand attack vectors
    function test_proposal_ens_ep_5_16() public {
        // Delegate from top token holder
        vm.prank(voter);
        token.delegate(voter);

        // Need to advance 1 block for delegation to be valid on governor
        vm.roll(block.number + 1);
        
        assertGt(token.getVotes(voter), governor.quorum(block.number - 1));
        assertGt(token.getVotes(proposer), governor.proposalThreshold());


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

    function _proposer() internal returns (address) {
        return 0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5;
    }

    function _voter() internal returns (address) {
        return 0xd7A029Db2585553978190dB5E85eC724Aa4dF23f;
    }

    function _beforePropose() internal {
        USDCbalanceBefore = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).balanceOf(address(timelock));
    }

    function _generateCallData() internal returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas) {
        uint256 items = 1;

        address[] memory targets = new address[](items);
        targets[0] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        uint256[] memory values = new uint256[](items);
        values[0] = 0;

        bytes[] memory calldatas = new bytes[](items);
        calldatas[0] = hex"a9059cbb000000000000000000000000690f0581ececcf8389c223170778cd9d029606f20000000000000000000000000000000000000000000000000000011bbe60ce00";

        bytes memory expectedCalldata = abi.encodeWithSelector(IERC20.transfer.selector, receiver, expectedUSDCtransfer);

        assertEq(calldatas[0], expectedCalldata);

        return (targets, values, calldatas);
    }
    
    function _afterExecution() internal {    
        USDCbalanceAfter = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48).balanceOf(address(timelock));
        assertEq(USDCbalanceBefore, USDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(USDCbalanceAfter, USDCbalanceBefore);
    }
}
