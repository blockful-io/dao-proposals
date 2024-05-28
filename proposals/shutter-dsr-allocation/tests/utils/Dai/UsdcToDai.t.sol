// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../../Context.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TestUSDCtoDai is Test, Context {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {}

  /**
   * @dev Tests the entire process of converting USDC to DAI with PSM contract.
   *
   * The test will:
   * 1. Approve the PSM to spend USDC.
   * 2. Convert USDC to DAI.
   */
  function test_swapUsdcToDai() external {
    // Start pranking with the USDC owner
    vm.startPrank(ShutterGnosis);
    // Stores the previous balance of the user
    uint256 initialGnosisUSDCBalance = USDC.balanceOf(ShutterGnosis);
    // Approve PSM to spend USDC {ERC20-approve}
    USDC.approve(AuthGemJoin5, amount * decimalsUSDC);
    // Check if allowance is set for USDC {ERC20-allowance}
    assert(USDC.allowance(ShutterGnosis, AuthGemJoin5) == amount * decimalsUSDC);
    // Convert USDC to DAI {DssPsm-sellGem}
    DssPsm.sellGem(ShutterGnosis, amount * decimalsUSDC);
    // Check if DAI balance was increased {ERC20-balanceOf}
    assert(DAI.balanceOf(ShutterGnosis) == amount * decimalsDAI);
    assert(USDC.balanceOf(ShutterGnosis) == initialGnosisUSDCBalance - amount * decimalsUSDC);
  }

  function swapUsdcToDai(address from, address to, uint256 value) public {
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
