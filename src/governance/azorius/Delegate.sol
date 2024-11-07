// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "@shutter/interfaces/IVotes.sol";

contract Delegate is Test {
    /**
     * @dev Delegate the votes of `delegator` to `delegatee`
     *
     * Walkthrough:
     * 1. Pranks the delegator
     * 2. Delegates the delegator's voting power to the delegatee
     * 3. Stops the prank
     *
     * @param token The token address that will be delegated
     * @param delegator The delegator's address
     * @param delegatee The delegatee's address
     */
    function delegate(address token, address delegator, address delegatee) public {
        // Pranks the delegator
        vm.startPrank(delegator);
        // Delegates the delegator's voting power to the delegatee
        IVotes(token).delegate(delegatee);
        // Stops the prank
        vm.stopPrank();
    }
}
