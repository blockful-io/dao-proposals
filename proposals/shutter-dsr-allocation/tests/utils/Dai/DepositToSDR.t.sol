// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../Context.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TestDepositToSDR is Test, Context {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Jotaro);
  }

  /**
   * @dev Tests the process of depositing DAI to the SDR contract.
   *
   * The test will:
   * 1. Approve the SavingsDai to spend DAI.
   * 2. Deposit DAI in the SavingsDai contract.
   */
  function test_depositToSDR() external {
    // Stores the previous balance of the user
    uint256 balanceOfSavingsDaiBefore = SavingsDai.balanceOf(Jotaro);
    // Approve SavingsDai to spend DAI {ERC20-approve}
    DAI.approve(address(SavingsDai), amount * decimalsDAI);
    // Check if allowance is set for DAI {ERC20-allowance}
    assert(DAI.allowance(Jotaro, address(SavingsDai)) == amount * decimalsDAI);
    // Preview the amount of shares that will be received {SavingsDai-previewDeposit}
    uint256 sharesToBeReceived = SavingsDai.previewDeposit(amount * decimalsDAI);
    // Deposit DAI to SavingsDai {SavingsDai-deposit}
    uint256 sharesReceived = SavingsDai.deposit(amount * decimalsDAI, Jotaro);
    // Check if the amount of shares received is the same as the previewed amount {SavingsDai-deposit}
    assert(sharesReceived == sharesToBeReceived);
    // Check if the user's balance of shares was increased {SavingsDai-balanceOf}
    assert(sharesReceived == SavingsDai.balanceOf(Jotaro) - balanceOfSavingsDaiBefore);
  }

  function depositToSDR(address from, address to, uint256 value) external returns (uint256 sharesReceived) {
    // Start pranking with the USDC owner
    vm.startPrank(from);
    // Approve SavingsDai to spend DAI {ERC20-approve}
    DAI.approve(address(SavingsDai), value);
    // Deposit DAI to SavingsDai {SavingsDai-deposit}
    sharesReceived = SavingsDai.deposit(value, to);
    // Stops the prank
    vm.stopPrank();
  }
}
