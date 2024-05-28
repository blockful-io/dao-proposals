// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../../../contracts/dai/interfaces/IDssPsm.sol";
import "../../../contracts/dai/interfaces/ISavingsDai.sol";

import "../Context.sol";

contract DepositUSDCtoSDR is Test, Context {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {}

  /**
   * @dev Tests depositing USDC to the SDR contract.
   *
   * The test will:
   * 1. Approve the PSM to spend USDC.
   * 2. Convert USDC to DAI.
   * 3. Approve the SavingsDai to spend DAI.
   * 4. Deposit DAI in the SavingsDai contract.
   */
  function test_dsrAllocation_depositUSDCToSDR() external {
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
