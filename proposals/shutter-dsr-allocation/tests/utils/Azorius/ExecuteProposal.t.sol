// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../../Context.sol";
import "./Vote.t.sol";

contract TestExecuteProposal is Test, Context, TestVote {
  // The amount of UDSC initilized
  uint256 initialDaoUSDCbalance;

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual override {}

  function test_executeProposal() external {
    vm.startPrank(Joseph);
    // Stores the current USDC balance of the Gnosis contract
    initialDaoUSDCbalance = USDC.balanceOf(ShutterGnosis);
    // Delegate the Shutter Tokens from Gnosis to Joseph
    delegate(ShutterToken, ShutterGnosis, Joseph);
    // Submits the proposal and return the proposalId
    uint32 proposalId = submitProposal(
      Joseph,
      _prepareTransactionsForProposal(),
      "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract"
    );
    // Votes for the proposal ID with a given address
    // and move the block to the end of the voting period
    vote(Joseph, proposalId, 1);
    // Prepare the transactions to be executed
    // We need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionsForExecution(_prepareTransactionsForProposal());
    // Check if the proposal passed {LinearERC20Voting-isPassed}
    bool passed = LinearERC20Voting.isPassed(proposalId);
    assert(passed);
    // Execute the proposal {Azorius-executeProposal}
    Azorius.executeProposal(proposalId, targets, values, data, operations);
    // Validate if the proposal was executed correctly
    IAzorius.ProposalState state2 = Azorius.proposalState(proposalId);
    assert(state2 == IAzorius.ProposalState.EXECUTED);
    // Validate if the Shutter Gnosis contract received the Savings Dai Token (SDR)
    // Since there is a loss of precision in the process, we need to check if the amount is
    // within the expected range using 0,000001% of the amount as the margin of error
    assert(SavingsDai.maxWithdraw(ShutterGnosis) >= ((amount * decimalsDAI * 999_999) / 1_000_000));
    // Validate if the USDC was transferred to the DSR contract
    assert(USDC.balanceOf(ShutterGnosis) == initialDaoUSDCbalance - amount * decimalsUSDC);
  }

  function executeProposal(uint32 proposalId, IAzorius.Transaction[] memory transaction) public {
    // Prepare the transactions to be executed. Same data as submit Proposal but
    // we need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionsForExecution(transaction);
    // Execute the proposal {Azorius-executeProposal}
    Azorius.executeProposal(proposalId, targets, values, data, operations);
  }
}
