// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "./utils/Context.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./utils/Azorius/ExecuteProposal.t.sol";

contract CalldataGovernance is Test, Context, TestExecuteProposal {
  /// @dev A function invoked before each test case is run.
  function setUp() public virtual override {
    vm.label(address(USDC), "USDC");
    vm.label(address(DAI), "DAI");
    vm.label(address(DssPsm), "DssPsm");
    vm.label(address(SavingsDai), "SavingsDai");
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
  function test_CalldataWithGovernance() external {
    // Delegate the Shutter Tokens from Gnosis to Joseph {ShutterToken-delegate}
    delegate(ShutterToken, ShutterGnosis, Joseph);
    // Prepare the transactions to submit the proposal. These are the steps that will be executed
    // in the proposal once its approved.
    IAzorius.Transaction[] memory transactions = _prepareTransactionsForProposal();
    // Submit the proposal and return the proposal ID {Azorius-submitProposal}
    uint32 proposalId = submitProposal(
      Joseph,
      transactions,
      "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract"
    );
    // Vote yes for the proposal ID with the input address and forward the block to the end of the voting period {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    vote(Joseph, proposalId, 1);
    // Execute the proposal {Azorius-executeProposal}
    executeProposal(proposalId, transactions);
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
}
