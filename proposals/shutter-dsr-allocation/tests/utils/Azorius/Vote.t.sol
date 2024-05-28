// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../../Context.sol";
import "./SubmitProposal.t.sol";

contract TestVote is Test, Context, TestSubmitProposal {
  // The proposal ID during this test execution
  uint32 proposalId;

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual override {}

  function test_vote() external {
    // Delegate the Shutter Tokens from Gnosis to Joseph
    delegate(ShutterToken, ShutterGnosis, Joseph);
    // Submits the proposal as Joseph and return the proposal ID
    proposalId = submitProposal(
      Joseph,
      _prepareTransactionsForProposal(),
      "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract"
    );
    // Prank Joseph, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(Joseph);
    // Vote for the proposal {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    LinearERC20Voting.vote(proposalId, 1);
    // Mine the future blocks until the proposal voting period ends
    vm.roll(block.number + 21600);
    // Check if the proposal passed {LinearERC20Voting-isPassed}
    bool passed = LinearERC20Voting.isPassed(proposalId);
    assert(passed);
  }

  function vote(address voter, uint32 _proposalId, uint8 choice) public {
    // Starting pranking the address that will vote
    vm.startPrank(voter);
    // Vote for the proposal {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    LinearERC20Voting.vote(_proposalId, choice);

    // Mine the future blocks until the proposal voting period ends
    vm.roll(block.number + 21600);
    // Stop pranking before continuing the script
    vm.stopPrank();
  }
}
