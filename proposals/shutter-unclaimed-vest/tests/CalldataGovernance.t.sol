// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../../../contracts/governance/azorius/Vote.sol";
import "../../../contracts/governance/azorius/Delegate.sol";
import "../../../contracts/governance/azorius/SubmitProposal.sol";
import "../../../contracts/governance/azorius/ExecuteProposal.sol";

import "../Context.sol";

contract CalldataGovernance is Test, Context, Delegate, Vote, SubmitProposal, ExecuteProposal {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.label(address(AirdropContract), "Airdrop Contract");
    vm.label(address(TreasuryContract), "Treasury Contract");
  }

  /**
   * @dev Tests the entire process of claiming the unused tokens from the Airdrop
   * contract and disabling the Vesting Contract as a module in Safe. Then log.
   *
   * NOTE: No assertions will be made in here. This is just to print the calldata that will be executed.
   */
  function test_claim_disable_calldataWithGovernanceNoAssertions() external {
    // Delegate the Shutter Tokens from Gnosis to Joseph {ShutterToken-delegate}
    delegate(ShutterToken, ShutterGnosis, Joseph);
    // Prepare the transactions to submit the proposal. These are the steps that will be executed
    // in the proposal once its approved.
    IAzorius.Transaction[] memory transactions = _prepareTransactionsForProposal();
    // Submit the proposal and return the proposal ID {Azorius-submitProposal}
    uint32 proposalId = submitProposal(Joseph, address(Azorius), address(LinearERC20Voting), transactions, metadata);
    // Vote yes for the proposal ID with the input address and forward the block to the end of the voting period {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    vote(Joseph, address(LinearERC20Voting), proposalId, 1);
    // Execute the proposal {Azorius-executeProposal}
    executeProposal(Joseph, address(Azorius), proposalId, transactions);
    // Sucessfully executed the proposal with the calldata. Printing results.
    for (uint256 i = 0; i < transactions.length; i++) {
      console2.log("");
      console2.log("##### Transaction", i, "-", vm.getLabel(transactions[i].to));
      console2.log("# Target:    ", transactions[i].to);
      console2.log("# Value:     ", transactions[i].value);
      console2.log("# Operation: ", uint8(transactions[i].operation) == 0 ? "CALL" : "DELEGATECALL");
      console2.log("# Data:      ", vm.toString(transactions[i].data));
    }
  }

  /**
   * @dev Tests the entire process of claiming the unused tokens from the Airdrop
   * contract and disabling the Vesting Contract as a module in Safe using the
   * Azorius Governance.
   */
  function test_claim_disable_calldataWithGovernance() external {
    /// @notice VALIDATE PREVIOUS STATE
    // Check if the module is enabled
    bool isModuleEnabled = TreasuryContract.isModuleEnabled(VestingPoolManager);
    assert(isModuleEnabled == true);
    // The balance of the Airdrop contract before the claim
    uint256 airdropBalanceBefore = SHU.balanceOf(Airdrop);
    assert(airdropBalanceBefore == 46154583762696716270000000);
    // Store the balance of the treasury before the claim
    uint256 treasuryBalanceBefore = SHU.balanceOf(ShutterGnosis);

    /// @notice PERFORM GOVERNANCE ACTIONS
    // Delegate the votes of the top #1 Shutter Token holder to Joseph {Votes-delegate}
    vm.startPrank(ShutterGnosis); // Pretending to be the gnosis contract
    IVotes(ShutterToken).delegate(Joseph);
    // Did Joseph became the delegate of the top #1 holder? {Votes-delegates}
    assert(IVotes(ShutterToken).delegates(ShutterGnosis) == Joseph);
    // Prank Joseph, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(Joseph);
    // Prepare the transactions to submit the proposal. These are the steps that will be executed
    // in the proposal once its approved.
    IAzorius.Transaction[] memory transactions = _prepareTransactionsForProposal();
    // Get the total proposal count before submitting the proposal because this will become the proposalId
    // after the proposal is submited. This happens because Azorius proposal Ids starts at 0 and count at 1.
    uint32 proposalId = Azorius.totalProposalCount();
    // Submit the proposal {Azorius-submitProposal}
    Azorius.submitProposal(address(LinearERC20Voting), "0x", transactions, metadata);
    // Check if the total proposal count was increased by 1 {Azorius-totalProposalCount}
    uint32 totalProposalCountAfter = Azorius.totalProposalCount();
    assert(totalProposalCountAfter == proposalId + 1);
    // Mine current block because the proposal needs to be mined before voting
    // See Votes.sol at line 107 in ShutterToken
    // https://etherscan.io/token/0xe485E2f1bab389C08721B291f6b59780feC83Fd7#code
    vm.roll(block.number + 1);
    // Vote for the proposal {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    LinearERC20Voting.vote(proposalId, 1);
    // Mine the future blocks until the proposal voting period ends
    vm.roll(block.number + 21600);
    // Check if the proposal passed {LinearERC20Voting-isPassed}
    bool passed = LinearERC20Voting.isPassed(proposalId);
    assert(passed);
    // Prepare the transactions to be executed
    // We need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionsForExecution(_prepareTransactionsForProposal());
    // Execute the proposal {Azorius-executeProposal}
    Azorius.executeProposal(proposalId, targets, values, data, operations);
    // Validate if the proposal was executed correctly
    IAzorius.ProposalState state2 = Azorius.proposalState(proposalId);
    assert(state2 == IAzorius.ProposalState.EXECUTED);

    /// @notice VALIDATE FUTURE STATE
    // The balance of the Airdrop contract after the claim should be 0
    uint256 airdropBalanceAfter = SHU.balanceOf(Airdrop);
    assert(airdropBalanceAfter == 0);
    // The balance of the treasury after the claim should be the sum of its previous balance and the claimed airdrop balance
    uint256 treasuryBalanceAfter = SHU.balanceOf(ShutterGnosis);
    assert(treasuryBalanceAfter == treasuryBalanceBefore + airdropBalanceBefore);
    // The balance of the Airdrop contract after the claim should be 0
    isModuleEnabled = TreasuryContract.isModuleEnabled(VestingPoolManager);
    assert(isModuleEnabled == false);
  }
}
