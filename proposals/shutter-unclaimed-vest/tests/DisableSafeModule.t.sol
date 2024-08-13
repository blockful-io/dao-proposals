// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../Context.sol";

contract DisableSafeModule is Test, Context {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {}

  /**
   * @dev Will validate the following steps:
   * - Disable the Vesting Contract as a module in Safe
   * - Check if the module is disabled
   */
  function test_disable_vest_as_module() external {
    // Pretending to be the gnosis contract
    vm.startPrank(ShutterGnosis);
    //Check if the module is enabled
    bool isModuleEnabled = TreasuryContract.isModuleEnabled(VestingPoolManager);
    assert(isModuleEnabled == true);
    // Disable the Vesting Contract as a module in Safe
    TreasuryContract.disableModule(address(0x1), VestingPoolManager);
    // The balance of the Airdrop contract after the claim should be 0
    isModuleEnabled = TreasuryContract.isModuleEnabled(VestingPoolManager);
    assert(isModuleEnabled == false);
  }
}
