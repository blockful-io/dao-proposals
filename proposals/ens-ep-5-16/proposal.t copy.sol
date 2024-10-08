// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IERC20 } from "@contracts/token/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_16_Test is ENS_Governance {
    uint256 USDCbalanceBefore;
    uint256 expectedUSDCtransfer = 1_218_669_760_000;
    uint256 USDCbalanceAfter;
    address receiver = 0x690F0581eCecCf8389c223170778cD9D029606F2; // ENS Labs

    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 20_836_390, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5;
    }

    function _beforePropose() public override {
        USDCbalanceBefore = USDC.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas)
    {
        uint256 items = 1;

        targets = new address[](items);
        targets[0] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        values = new uint256[](items);
        values[0] = 0;

        calldatas = new bytes[](items);
        calldatas[0] =
            hex"a9059cbb000000000000000000000000690f0581ececcf8389c223170778cd9d029606f20000000000000000000000000000000000000000000000000000011bbe60ce00";

        bytes memory expectedCalldata = abi.encodeWithSelector(USDC.transfer.selector, receiver, expectedUSDCtransfer);

        assertEq(calldatas[0], expectedCalldata);

        return (targets, values, calldatas);
    }

    function _afterExecution() public override {
        USDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(USDCbalanceBefore, USDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(USDCbalanceAfter, USDCbalanceBefore);
    }
}
