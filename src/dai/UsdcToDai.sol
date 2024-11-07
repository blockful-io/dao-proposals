// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./interfaces/IDssPsm.sol";
import "../utils/interfaces/IERC20.sol";

contract USDCtoDai is Test {
    /// @dev Stablecoin configurations
    uint256 constant decimalsUSDC = 10 ** 6;
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    /// @dev Maker PSM contracts to convert USDC to DAI
    IDssPsm DssPsm = IDssPsm(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A);
    address AuthGemJoin5 = 0x0A59649758aa4d66E25f08Dd01271e891fe52199;

    /**
     * @dev Swaps USDC to DAI with PSM contract.
     *
     * Walkthrough:
     * 1. Prank the USDC holder.
     * 2. Approve the PSM to spend USDC.
     * 3. Convert USDC to DAI.
     * 4. Stop the prank.
     *
     * @param prank The address that will be impersonated.
     * @param to The address to receive the DAI.
     * @param value The amount of USDC to convert.
     */
    function swapUsdcToDai(address prank, address to, uint256 value) public {
        // Start pranking with the USDC owner
        vm.startPrank(prank);
        // Approve PSM to spend USDC {ERC20-approve}
        USDC.approve(AuthGemJoin5, value);
        // Convert USDC to DAI {DssPsm-sellGem}
        DssPsm.sellGem(to, value);
        // Stops the prank
        vm.stopPrank();
    }
}
