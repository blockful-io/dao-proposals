// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "@shutter/interfaces/IAzorius.sol";

contract SubmitProposal is Test {
  /**
   * @dev Submits a proposal to the Azorius governor contract.
   *
   * The test will:
   * 1. Start pranking with the proposer.
   * 2. Submit a proposal to the Azorius governor contract.
   * 3. Stop the prank.
   *
   * @param prank The impersonated address that will submit the proposal.
   * @param governor The Azorius governor contract address.
   * @param strategy The strategy address to execute the proposal.
   * @param transactions The transactions to execute in the proposal.
   * @param metadata The metadata of the proposal.
   * @return proposalId The proposal ID submitted.
   */
  function submitProposal(
    address prank,
    address governor,
    address strategy,
    IAzorius.Transaction[] memory transactions,
    string memory metadata
  ) public returns (uint32 proposalId) {
    // Get the total proposal count before submitting the proposal because this will become the proposalId
    // after the proposal is submited. This happens because Azorius proposal Ids starts at 0 and count at 1.
    uint32 totalProposalCountBefore = IAzorius(governor).totalProposalCount();
    // Prank the proposer, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(prank);
    IAzorius(governor).submitProposal(strategy, "0x", transactions, metadata);
    vm.stopPrank();
    // Mine current block because the proposal needs to be mined before voting
    // See Votes.sol at line 107 in ShutterToken
    // https://etherscan.io/token/0xe485E2f1bab389C08721B291f6b59780feC83Fd7#code
    vm.roll(block.number + 1);
    // Return the proposal ID
    return totalProposalCountBefore;
  }
}
