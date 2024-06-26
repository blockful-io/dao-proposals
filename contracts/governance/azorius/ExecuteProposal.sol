// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./interfaces/IAzorius.sol";

contract ExecuteProposal is Test {
  /**
   * @dev Executes a proposal in the Azorius contract.
   *
   * Walkthrough:
   * 1. Prank the executor of the proposal
   * 2. Prepare the transactions to be executed
   * 3. Execute the proposal {Azorius-executeProposal}
   * 4. Stops the prank
   *
   * @param prank The address that will be impersonated.
   * @param governor The Azorius contract address.
   * @param proposalId The proposal ID to execute.
   * @param transactions The transactions to be executed.
   */
  function executeProposal(
    address prank,
    address governor,
    uint32 proposalId,
    IAzorius.Transaction[] memory transactions
  ) public {
    // Prank the executor of the proposal
    vm.startPrank(prank);
    // Prepare the transactions to be executed. Same data as submit Proposal but
    // we need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionsForExecution(transactions);
    // Execute the proposal {Azorius-executeProposal}
    IAzorius(governor).executeProposal(proposalId, targets, values, data, operations);
    // Stops the prank
    vm.stopPrank();
  }

  /**
   * @dev Prepares the transactions to be executed in the proposal.
   * @param transactions The transactions submited in the proposal generated by {_prepareTransactionsForProposal}
   * @return targets The addresses of the contracts to be called.
   * @return values The amount of ETH to be sent to the contracts.
   * @return data The encoded calldata to be sent to the contracts.
   * @return operations The type of operation to be executed in the contracts. Call or DelegateCall.
   */
  function _prepareTransactionsForExecution(
    IAzorius.Transaction[] memory transactions
  )
    internal
    pure
    returns (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    )
  {
    targets = new address[](4);
    targets[0] = transactions[0].to;
    targets[1] = transactions[1].to;
    targets[2] = transactions[2].to;
    targets[3] = transactions[3].to;

    values = new uint256[](4);
    values[0] = transactions[0].value;
    values[1] = transactions[0].value;
    values[2] = transactions[0].value;
    values[3] = transactions[0].value;

    data = new bytes[](4);
    data[0] = transactions[0].data;
    data[1] = transactions[1].data;
    data[2] = transactions[2].data;
    data[3] = transactions[3].data;

    operations = new IAzorius.Operation[](4);
    operations[0] = transactions[0].operation;
    operations[1] = transactions[1].operation;
    operations[2] = transactions[2].operation;
    operations[3] = transactions[3].operation;
  }
}
