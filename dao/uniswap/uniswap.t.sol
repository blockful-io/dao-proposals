// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IDAO } from "@contracts/token/interfaces/IDAO.sol";
import { IToken } from "@uniswap/interface/IToken.sol";
import { IGovernor } from "@uniswap/interface/IGovernor.sol";
import { ITimelock } from "@uniswap/interface/Timelock.sol";

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
        timelock = ITimelock(0x1a9C8182C09F50C8318d769245beA52c32BE35BC);
    }

    // Executing each step necessary on the proposal lifecycle to understand parameters
    function test_proposal() public {
        _generateCallData();
        _beforePropose();
        _afterExecution();
    }

    function _selectFork() public virtual {
        vm.createSelectFork({ urlOrAlias: "mainnet" });
    }

    function _proposer() public view virtual returns (address);

    function _voter() public view virtual returns (address) {
        return 0x1a9C8182C09F50C8318d769245beA52c32BE35BC;
    }

    function _beforePropose() public virtual;

    function _generateCallData()
        public
        virtual
        returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas);

    function _afterExecution() public virtual;
}
