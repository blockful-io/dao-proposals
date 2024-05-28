// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./interfaces/ILinearERC20Voting.sol";

contract Vote is Test {
  /**
   * @dev Votes for a proposal in the LinearERC20Voting contract.
   *
   * Walkthrough:
   * 1. Start pranking the address that will vote.
   * 2. Vote for the proposal {LinearERC20Voting-vote}
   * 3. Mine the future blocks until the proposal voting period ends.
   * 4. Stop the prank
   *
   * @param prank The address that will be impersonated.
   * @param token The token address that will be delegated
   * @param _proposalId The proposal ID to vote
   * @param choice The choice to vote for the proposal
   */
  function vote(address prank, address token, uint32 _proposalId, uint8 choice) public {
    // Starting pranking the address that will vote
    vm.startPrank(prank);
    // Vote for the proposal {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    ILinearERC20Voting(token).vote(_proposalId, choice);
    // Mine the future blocks until the proposal voting period ends
    vm.roll(block.number + 21600);
    // Stop pranking before continuing the script
    vm.stopPrank();
  }
}
