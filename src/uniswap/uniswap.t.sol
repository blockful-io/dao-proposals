// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IDAO } from "@contracts/utils/interfaces/IDAO.sol";
import { IToken } from "@uniswap/interfaces/IToken.sol";
import { IGovernor } from "@uniswap/interfaces/IGovernor.sol";
import { ITimelock } from "@uniswap/interfaces/ITimelock.sol";

abstract contract UNI_Governance is Test, IDAO {
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
                                   TEST CONTRACTS
    //////////////////////////////////////////////////////////////////////////*/

    IToken public uniToken;
    IGovernor public governor;
    ITimelock public timelock;

    uint256 public votingDelay;
    uint256 public votingPeriod;
    uint256 public proposalThreshold;
    uint256 public quorumVotes;

    address public proposer;
    address public voter;

    /*//////////////////////////////////////////////////////////////////////////
                                  SET-UP FUNCTION
    //////////////////////////////////////////////////////////////////////////*/

    function setUp() public virtual {
        _selectFork();

        votingDelay = 13_140; // 43 hours and 48 minutes
        votingPeriod = 40_320; // 5 days and 14 hours and 24 minutes
        proposalThreshold = 1_000_000_000_000_000_000_000_000; // 1,000,000 UNI
        quorumVotes = 40_000_000_000_000_000_000_000_000; // 40,000,000 UNI

        uniToken = IToken(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
        governor = IGovernor(0x408ED6354d4973f66138C91495F2f2FCbd8724C3);
        timelock = ITimelock(payable(0x1a9C8182C09F50C8318d769245beA52c32BE35BC));

        proposer = _proposer();
        voter = _voter();
    }

    // Executing each step necessary on the proposal lifecycle to understand parameters
    function test_proposal() public {
        vm.prank(voter);
        uniToken.delegate(voter);

        vm.roll(block.number + 1);

        (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        ) = _generateCallData();

        _beforePropose();

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, signatures, calldatas, description);

        // TODO: Assert states of proposal

        vm.roll(block.number + votingDelay + 1);

        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + votingPeriod);

        governor.queue(proposalId);

        vm.warp(block.timestamp + timelock.delay());

        governor.execute(proposalId);

        _afterExecution();
    }

    function _selectFork() public virtual {
        vm.createSelectFork({ urlOrAlias: "mainnet" });
    }

    function _proposer() public view virtual returns (address) {
        return 0x1a9C8182C09F50C8318d769245beA52c32BE35BC;
    }

    function _voters() public view virtual returns (address[] memory) {
        return [
            0x8E4ED221fa034245F14205f781E0b13C5bd6a42E,
            0x53689948444CfD03d2Ad77266b05e61B8Eed3132,
            0xe7925D190aea9279400cD9a005E33CEB9389Cc2b, // jessewldn
            0x1d8F369F05343F5A642a78BD65fF0da136016452,
            0xe02457a1459b6C49469Bf658d4Fe345C636326bF,
            0x88E15721936c6eBA757A27E54e7aE84b1EA34c05,
            0x8962285fAac45a7CBc75380c484523Bb7c32d429, // Consensys
            0xcb70D1b61919daE81f5Ca620F1e5d37B2241e638,
            0x88FB3D509fC49B515BFEb04e23f53ba339563981, // Robert Leshner
            0x683a4F9915D6216f73d6Df50151725036bD26C02  // Gauntlet
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
