// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../Context.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TestDelegate is Test, Context {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {}

  function test_delegate() external {
    // Delegate the votes of the top #1 Shutter Token holder to Joseph {Votes-delegate}
    vm.startPrank(ShutterGnosis); // Pretending to be the gnosis contract
    IVotes(ShutterToken).delegate(Joseph);
    // Did Joseph became the delegate of the top #1 holder? {Votes-delegates}
    assert(IVotes(ShutterToken).delegates(ShutterGnosis) == Joseph);
  }

  function delegate(address token, address delegator, address delegatee) public {
    // Pranks the delegator
    vm.startPrank(delegator);
    // Delegates the delegator's voting power to the delegatee
    IVotes(token).delegate(delegatee);
    // Stops the prank
    vm.stopPrank();
  }
}
