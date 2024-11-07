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
    address[] public voters;
    uint256 public proposalId;
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
        voters = _voters();
        // Label the base test contracts.
        vm.label(address(governor), "governor");
        vm.label(address(timelock), "timelock");
        vm.label(address(ensToken), "ensToken");
    }
    // Executing each step necessary on the proposal lifecycle to understand attack vectors

    function test_proposal() public {
        // Validate if the proposal has enough votes
        uint256 totalVotes = 0;
        for (uint256 i = 0; i < voters.length; i++) {
            totalVotes += ensToken.getVotes(voters[i]);
        }
        assertGt(totalVotes, governor.quorum(block.number - 1));

        // Validate if the proposer has enough votes
        assertGe(ensToken.getVotes(proposer), governor.proposalThreshold());

        // Generate call data
        (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        ) = _generateCallData();

        bytes32 descriptionHash = keccak256(bytes(description));

        // Calculate proposalId
        proposalId = governor.hashProposal(targets, values, calldatas, descriptionHash);
        proposalId = uint256(
            33_504_840_096_777_976_512_510_989_921_427_323_867_039_135_570_342_563_123_194_157_971_712_476_988_820
        );
        console2.log("proposalId", proposalId);
        // Verify if proposal already exists
        try governor.state(proposalId) returns (uint8 state) {
            console2.log("Proposal already exists");
        } catch {
            // Proposal does not exist
            vm.prank(proposer);
            proposalId = governor.propose(targets, values, calldatas, description);
            assertEq(governor.state(proposalId), 0);
        }

        // Make proposal ready to vote
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(governor.state(proposalId), 1);

        // Delegates vote for the proposal
        for (uint256 i = 0; i < voters.length; i++) {
            vm.prank(voters[i]);
            governor.castVote(proposalId, 1);
        }

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

        // Store parameters to be validated after execution
        _beforeExecution();

        // Execute proposal
        governor.execute(targets, values, calldatas, descriptionHash);
        assertTrue(timelock.isOperationDone(proposalIdInTimelock));

        // Assert parameters modified after execution
        _afterExecution();
    }

    function _selectFork() public virtual {
        vm.createSelectFork({ urlOrAlias: "mainnet" });
    }

    function _proposer() public view virtual returns (address) {
        return 0x5BFCB4BE4d7B43437d5A0c57E908c048a4418390; // fireeyesdao.eth
    }

    function _voters() public view virtual returns (address[] memory votersArray) {
        votersArray = new address[](10);
        votersArray[0] = 0x5BFCB4BE4d7B43437d5A0c57E908c048a4418390; // fireeyesdao.eth
        votersArray[1] = 0x81b287c0992B110ADEB5903Bf7E2d9350C80581a; // coinbase
        votersArray[2] = 0x2B888954421b424C5D3D9Ce9bB67c9bD47537d12; // lefteris.eth
        votersArray[3] = 0x89EdE5cBE53473A64d6C8DF14176a0d658dAAeDC; // scratch.ricmoo.eth
        votersArray[4] = 0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726; // 5pence.eth
        votersArray[5] = 0x839395e20bbB182fa440d08F850E6c7A8f6F0780; // griff.eth
        votersArray[6] = 0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5; // nick.eth
        votersArray[7] = 0x983110309620D911731Ac0932219af06091b6744; // brantly.eth
        votersArray[8] = 0x4e88F436422075C1417357bF957764c127B2CC93; // imtoken.eth
        votersArray[9] = 0x809FA673fe2ab515FaA168259cB14E2BeDeBF68e; // avsa.eth
    }

    function _beforeExecution() public virtual;

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
