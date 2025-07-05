// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_25_Test is ENS_Governance {
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256 USDCbalanceBefore;
    uint256 USDCbalanceAfter;
    uint256 metagovExpectedUSDCtransfer = 254_000 * 10 ** 6; // USDC decimals
    uint256 ecosystemExpectedUSDCtransfer = 836_000 * 10 ** 6; // USDC decimals
    uint256 pgExpectedUSDCtransfer = 226_000 * 10 ** 6; // USDC decimals

    address metagovMultisig = 0x91c32893216dE3eA0a55ABb9851f581d4503d39b;
    address ecosystemMultisig = 0x2686A8919Df194aA7673244549E68D42C1685d03;
    address pgMultisig = 0xcD42b4c4D102cc22864e3A1341Bb0529c17fD87d;

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_130_700, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726;
    }

    function _beforeProposal() public override {
        USDCbalanceBefore = USDC.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (
            address[] memory,
            uint256[] memory,
            string[] memory,
            bytes[] memory,
            string memory
        )
    {
        uint256 items = 3;

        targets = new address[](items);
        targets[0] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        targets[1] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        targets[2] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        values = new uint256[](items);
        values[0] = 0;
        values[1] = 0;
        values[2] = 0;

        calldatas = new bytes[](items);
        calldatas[0] =
            hex"a9059cbb00000000000000000000000091c32893216de3ea0a55abb9851f581d4503d39b0000000000000000000000000000000000000000000000000000003b23946c00";
        calldatas[1] =
            hex"a9059cbb0000000000000000000000002686a8919df194aa7673244549e68d42c1685d03000000000000000000000000000000000000000000000000000000c2a57ba800";
        calldatas[2] =
            hex"a9059cbb000000000000000000000000cd42b4c4d102cc22864e3a1341bb0529c17fd87d000000000000000000000000000000000000000000000000000000349ea65400";

        bytes memory expectedUSDCCalldata0 =
            abi.encodeWithSelector(IERC20.transfer.selector, metagovMultisig, metagovExpectedUSDCtransfer);
        bytes memory expectedUSDCCalldata1 =
            abi.encodeWithSelector(IERC20.transfer.selector, ecosystemMultisig, ecosystemExpectedUSDCtransfer);
        bytes memory expectedUSDCCalldata2 =
            abi.encodeWithSelector(IERC20.transfer.selector, pgMultisig, pgExpectedUSDCtransfer);

        assertEq(calldatas[0], expectedUSDCCalldata0);
        assertEq(calldatas[1], expectedUSDCCalldata1);
        assertEq(calldatas[2], expectedUSDCCalldata2);

        return (targets, values, signatures, calldatas, "");
    }

    function _afterExecution() public override {
        USDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(
            USDCbalanceBefore,
            USDCbalanceAfter + metagovExpectedUSDCtransfer + ecosystemExpectedUSDCtransfer + pgExpectedUSDCtransfer
        );
        assertNotEq(USDCbalanceAfter, USDCbalanceBefore);
    }

    function _isProposalSubmitted() public view override returns (bool) {
        return false;
    }
}
