// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

// import "../../../contracts/governance/azorius/interfaces/IAzorius.sol";
// import "../../../contracts/governance/azorius/interfaces/ILinearERC20Voting.sol";
// import "../../../contracts/governance/azorius/interfaces/IVotes.sol";
// import "../../../contracts/dai/interfaces/IDssPsm.sol";
// import "../../../contracts/dai/interfaces/ISavingsDai.sol";
// import "../../../contracts/token/interfaces/IERC20.sol";

import "../../../contracts/governance/azorius/Vote.sol";
import "../../../contracts/governance/azorius/Delegate.sol";
import "../../../contracts/governance/azorius/SubmitProposal.sol";
import "../../../contracts/governance/azorius/ExecuteProposal.sol";

import "../Context.sol";

contract CalldataGovernance is Test, Context, Delegate, Vote, SubmitProposal, ExecuteProposal {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.label(address(USDC), "USDC");
    vm.label(address(DAI), "DAI");
    vm.label(address(DssPsm), "DssPsm");
    vm.label(address(SavingsDai), "SavingsDai");
  }

  /**
   * @dev Same as {test_calldataWithGovernance} but without any assertions.
   *
   * NOTE: Joseph is an address that is allowed to submit proposals and execute them.
   *
   * The test will:
   * 1. Delegate the votes of the top #1 Shutter Token holder to Joseph.
   * 2. Encode the transactions to be executed in the proposal.
   * 3. Submit a proposal to deposit 3M DAI in the DSR contract.
   * 4. Vote for the proposal.
   * 6. Prepare the transactions to be executed.
   * 7. Execute the proposal.
   */
  function test_calldataWithGovernanceNoAssertions() external {
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
      console2.log("##### Tx[", i, "]", vm.getLabel(transactions[i].to));
      console2.log("# Target:    ", transactions[i].to);
      console2.log("# Value:     ", transactions[i].value);
      console2.log("# Operation: ", uint8(transactions[i].operation) == 0 ? "CALL" : "DELEGATECALL");
      console2.log("# Data:      ", vm.toString(transactions[i].data));
    }
  }

  /**
   * @dev Tests the entire process of submitting a proposal to the Azorius contract
   * voting for it via the LinearERC20Voting contract, and executing the proposal
   * via the Azorius contract.
   *
   * NOTE: Joseph is an address that is allowed to submit proposals and execute them.
   *
   * The test will:
   * 1. Delegate the votes of the top #1 Shutter Token holder to Joseph.
   * 2. Encode the transactions to be executed in the proposal.
   * 3. Submit a proposal to deposit 3M DAI in the DSR contract.
   * 4. Vote for the proposal.
   * 6. Prepare the transactions to be executed.
   * 7. Execute the proposal.
   */
  function test_calldataWithGovernance() external {
    // Get the initial balance of the USDC in the DAO contract
    uint256 initialDaoUSDCbalance = USDC.balanceOf(ShutterGnosis);
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
    // Validate if the Shutter Gnosis contract received the Savings Dai Token (SDR)
    // Since there is a loss of precision in the process, we need to check if the amount is
    // within the expected range using 0,000001% of the amount as the margin of error
    assert(SavingsDai.maxWithdraw(ShutterGnosis) >= ((amount * decimalsDAI * 999_999) / 1_000_000));
    // Validate if the USDC was transferred to the DSR contract
    assert(USDC.balanceOf(ShutterGnosis) == initialDaoUSDCbalance - amount * decimalsUSDC);
  }
}
