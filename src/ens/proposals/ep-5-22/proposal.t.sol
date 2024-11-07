// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { ITokenStreamingEP5_22 } from "@ens/interfaces/ITokenStreamingEP5-22.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

// https://www.tally.xyz/gov/ens/proposal/33504840096777976512510989921427323867039135570342563123194157971712476988820

contract Proposal_ENS_EP_5_22_Test is ENS_Governance {
    uint256 timelockUSDCbalanceBefore;
    uint256 expectedUSDCtransfer = 15_075_331_200;
    uint256 timelockUSDCbalanceAfter;
    address streamingContractAdmin = 0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5; // nick.eth
    address receiver = 0x690F0581eCecCf8389c223170778cD9D029606F2; // ENS Labs

    ITokenStreamingEP5_22 streamingContract = ITokenStreamingEP5_22(0x05C8f60e24FcDd9B8Ed7bB85dF8164C41cB4DA16); // stream
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_086_802, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0xE3919F3f971C4589089DaA930aaFa81B8A27b406;
    }

    function _beforeExecution() public override {
        timelockUSDCbalanceBefore = USDC.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        )
    {
        uint256 items = 1;

        targets = new address[](items);
        targets[0] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        values = new uint256[](items);
        values[0] = 0;

        calldatas = new bytes[](items);
        calldatas[0] =
            hex"095ea7b300000000000000000000000005c8f60e24fcdd9b8ed7bb85df8164c41cb4da16ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

        bytes memory expectedCalldata =
            abi.encodeWithSelector(USDC.approve.selector, address(streamingContract), type(uint256).max);

        assertEq(calldatas[0], expectedCalldata);

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public override {
        console2.log("Claimable balance", streamingContract.claimableBalance());
        console2.log("Total claimed", streamingContract.totalClaimed());

        vm.warp(streamingContract.startTime() + 1 days);

        console2.log("Claimable balance before claim", streamingContract.claimableBalance());

        vm.startPrank(streamingContractAdmin);
        streamingContract.claim(receiver, streamingContract.claimableBalance());
        vm.stopPrank();

        console2.log("Claimable balance after claim", streamingContract.claimableBalance());
        console2.log("Total claimed", streamingContract.totalClaimed());

        timelockUSDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(timelockUSDCbalanceBefore, timelockUSDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(timelockUSDCbalanceAfter, timelockUSDCbalanceBefore);
    }
}
