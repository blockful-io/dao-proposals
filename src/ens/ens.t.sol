// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IENSToken } from "@ens/interfaces/IENSToken.sol";
import { IDAO } from "@contracts/utils/interfaces/IDAO.sol";

abstract contract ENS_Governance is Test, IDAO {
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
        _selectFork();

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
        assertGe(ensToken.getVotes(proposer), governor.proposalThreshold());

        // Creating a proposal that gives a proposer role to
        (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        ) = _generateCallData();

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

    function _selectFork() public virtual {
        vm.createSelectFork({ urlOrAlias: "mainnet" });
    }

    function _proposer() public view virtual returns (address);

    function _voters() public view virtual returns (address[] memory) {
        return [
            0x5BFCB4BE4d7B43437d5A0c57E908c048a4418390, // fireeyesdao.eth
            0x81b287c0992B110ADEB5903Bf7E2d9350C80581a, // coinbase
            0x2B888954421b424C5D3D9Ce9bB67c9bD47537d12, // lefteris.eth
            0x89EdE5cBE53473A64d6C8DF14176a0d658dAAeDC, // scratch.ricmoo.eth
            0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726, // 5pence.eth
            0x839395e20bbB182fa440d08F850E6c7A8f6F0780, // griff.eth
            0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5, // nick.eth
            0x983110309620D911731Ac0932219af06091b6744, // brantly.eth
            0x4e88F436422075C1417357bF957764c127B2CC93, // imtoken.eth
            0x809FA673fe2ab515FaA168259cB14E2BeDeBF68e  // avsa.eth
        ];
    }

    function _beforePropose() public virtual;

    function _generateCallData()
        public
        virtual
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        );

    function _afterExecution() public virtual;
}
