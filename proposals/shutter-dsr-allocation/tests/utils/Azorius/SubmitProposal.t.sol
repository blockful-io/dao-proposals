// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../Context.sol";
import "./Delegate.t.sol";

contract TestSubmitProposal is Test, Context, TestDelegate {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual override {
    // Delegate the Shutter Tokens from Gnosis to Joseph
    delegate(ShutterToken, ShutterGnosis, Joseph);
  }

  function test_submitProposal() external {
    // Prank Joseph, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(Joseph);
    // Prepare the transactions to submit the proposal. These are the steps that will be executed
    // in the proposal once its approved.
    IAzorius.Transaction[] memory transactions = _prepareTransactionsForProposal();
    // Get the total proposal count before submitting the proposal because this will become the proposalId
    // after the proposal is submited. This happens because Azorius proposal Ids starts at 0 and count at 1.
    uint32 totalProposalCountBefore = Azorius.totalProposalCount();
    // Submit the proposal {Azorius-submitProposal}
    Azorius.submitProposal(
      address(LinearERC20Voting),
      "0x",
      transactions,
      "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract"
    );
    // Check if the total proposal count was increased by 1 {Azorius-totalProposalCount}
    uint32 totalProposalCountAfter = Azorius.totalProposalCount();
    assert(totalProposalCountAfter == totalProposalCountBefore + 1);
  }

  function submitProposal(
    address proposer,
    IAzorius.Transaction[] memory transactions,
    string memory metadata
  ) public returns (uint32 proposalId) {
    // Get the total proposal count before submitting the proposal because this will become the proposalId
    // after the proposal is submited. This happens because Azorius proposal Ids starts at 0 and count at 1.
    uint32 totalProposalCountBefore = Azorius.totalProposalCount();
    // Prank the proposer, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(proposer);
    Azorius.submitProposal(address(LinearERC20Voting), "0x", transactions, metadata);
    vm.stopPrank();
    // Mine current block because the proposal needs to be mined before voting
    // See Votes.sol at line 107 in ShutterToken
    // https://etherscan.io/token/0xe485E2f1bab389C08721B291f6b59780feC83Fd7#code
    vm.roll(block.number + 1);
    // Return the proposal ID
    return totalProposalCountBefore;
  }

  /**
   * @dev Prepares the transactions to be submitted in the proposal.
   * @return transactions The transactions to be executed in the proposal.
   */
  function _prepareTransactionsForProposal() internal view returns (IAzorius.Transaction[] memory) {
    IAzorius.Transaction[] memory transactions = new IAzorius.Transaction[](4);
    transactions[0] = IAzorius.Transaction({
      to: address(USDC),
      value: 0,
      data: abi.encodeWithSelector(IERC20.approve.selector, AuthGemJoin5, amount * decimalsUSDC),
      operation: IAzorius.Operation.Call
    });
    transactions[1] = IAzorius.Transaction({
      to: address(DssPsm),
      value: 0,
      data: abi.encodeWithSelector(DssPsm.sellGem.selector, ShutterGnosis, amount * decimalsUSDC),
      operation: IAzorius.Operation.Call
    });
    transactions[2] = IAzorius.Transaction({
      to: address(DAI),
      value: 0,
      data: abi.encodeWithSelector(IERC20.approve.selector, address(SavingsDai), amount * decimalsDAI),
      operation: IAzorius.Operation.Call
    });
    transactions[3] = IAzorius.Transaction({
      to: address(SavingsDai),
      value: 0,
      data: abi.encodeWithSelector(SavingsDai.deposit.selector, amount * decimalsDAI, ShutterGnosis),
      operation: IAzorius.Operation.Call
    });

    return transactions;
  }
}
