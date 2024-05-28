// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../../Context.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./UsdcToDai.t.sol";

contract TestDepositToSDR is Test, TestUSDCtoDai {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual override {}

  /**
   * @dev Tests the process of depositing DAI to the SDR contract.
   *
   * The test will:
   * 1. Approve the SavingsDai to spend DAI.
   * 2. Deposit DAI in the SavingsDai contract.
   */
  function test_depositToSDR() external {
    // Convert USDC to DAI {UsdcToDai-swapUsdcToDai}
    swapUsdcToDai(ShutterGnosis, ShutterGnosis, amount * decimalsUSDC);
    // Start pranking with the ShutterGnosis
    vm.startPrank(ShutterGnosis);
    // Stores the previous balance of the user
    uint256 balanceOfSavingsDaiBefore = SavingsDai.balanceOf(ShutterGnosis);
    // Approve SavingsDai to spend DAI {ERC20-approve}
    DAI.approve(address(SavingsDai), amount * decimalsDAI);
    // Check if allowance is set for DAI {ERC20-allowance}
    assert(DAI.allowance(ShutterGnosis, address(SavingsDai)) == amount * decimalsDAI);
    // Preview the amount of shares that will be received {SavingsDai-previewDeposit}
    uint256 sharesToBeReceived = SavingsDai.previewDeposit(amount * decimalsDAI);
    // Deposit DAI to SavingsDai {SavingsDai-deposit}
    uint256 sharesReceived = SavingsDai.deposit(amount * decimalsDAI, ShutterGnosis);
    // Check if the amount of shares received is the same as the previewed amount {SavingsDai-deposit}
    assert(sharesReceived == sharesToBeReceived);
    // Check if the user's balance of shares was increased {SavingsDai-balanceOf}
    assert(sharesReceived == SavingsDai.balanceOf(ShutterGnosis) - balanceOfSavingsDaiBefore);
  }
}
