// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./interfaces/IGnosisSafe.sol";

contract GnosisSafe is Test {
  /**
   * @dev Disables a module in the Gnosis Safe contract
   *
   * Walkthrough:
   * 1. Prank the caller
   * 2. Disables the module
   * 3. Stops the prank
   *
   * @param caller The pranked address to execute the call
   * @param safeAddress The address of the Gnosis Safe contract
   * @param prevModule The previous module in the modules array list
   * @param module The module to be removed
   */
  function disableModule(address caller, address safeAddress, address prevModule, address module) public {
    // Pranks the delegator
    vm.startPrank(caller);
    // Disable the Safe module
    IGnosisSafe(safeAddress).disableModule(prevModule, module);
    // Stops the prank
    vm.stopPrank();
  }
}
