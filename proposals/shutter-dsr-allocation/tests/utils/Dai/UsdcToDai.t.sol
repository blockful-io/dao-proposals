// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../Context.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TestUSDCtoDai is Test, Context {
  uint256 initialAliceUSDCBalance;

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Alice);
    initialAliceUSDCBalance = USDC.balanceOf(Alice);
  }

  /**
   * @dev Tests the entire process of converting USDC to DAI with PSM contract.
   *
   * The test will:
   * 1. Approve the PSM to spend USDC.
   * 2. Convert USDC to DAI.
   */
  function test_swapUsdcToDai() external {
    // Approve PSM to spend USDC {ERC20-approve}
    USDC.approve(AuthGemJoin5, amount * decimalsUSDC);
    // Check if allowance is set for USDC {ERC20-allowance}
    assert(USDC.allowance(Alice, AuthGemJoin5) == amount * decimalsUSDC);
    // Convert USDC to DAI {DssPsm-sellGem}
    DssPsm.sellGem(Alice, amount * decimalsUSDC);
    // Check if DAI balance was increased {ERC20-balanceOf}
    assert(DAI.balanceOf(Alice) == amount * decimalsDAI);
    assert(USDC.balanceOf(Alice) == initialAliceUSDCBalance - amount * decimalsUSDC);
  }

  function swapUsdcToDai(address from, address to, uint256 value) external {
    // Start pranking with the USDC owner
    vm.startPrank(from);
    // Approve PSM to spend USDC {ERC20-approve}
    USDC.approve(AuthGemJoin5, value);
    // Convert USDC to DAI {DssPsm-sellGem}
    DssPsm.sellGem(to, value);
    // Stops the prank
    vm.stopPrank();
  }
}
