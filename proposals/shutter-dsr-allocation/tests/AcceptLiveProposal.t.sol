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
    function setUp() public virtual { }

    /**
     * @dev This test gets the live proposal submitted by the DAO, votes for it, and executes it.
     * https://app.decentdao.org/proposals/18?dao=eth:0x36bD3044ab68f600f6d3e081056F34f2a58432c4
     *
     * The test will:
     * 1. Get the last proposal ID.
     * 2. Vote for the proposal.
     * 3. Prepare the transactions to be executed.
     * 4. Execute the proposal.
     */
    function test_dsrAllocation_liveProposal() external {
        // Get the initial balance of the USDC in the DAO contract
        uint256 initialDaoUSDCbalance = USDC.balanceOf(ShutterGnosis);
        // Get the initial balance of the Savings Dai in the DAO contract
        uint256 initialDaoSavingsDaibalance = SavingsDai.balanceOf(ShutterGnosis);
        // Delegate the votes of the top #1 Shutter Token holder to Joseph {Votes-delegate}
        vm.startPrank(ShutterGnosis); // Pretending to be the gnosis contract
        IVotes(ShutterToken).delegate(Joseph);
        // Did Joseph became the delegate of the top #1 holder? {Votes-delegates}
        assert(IVotes(ShutterToken).delegates(ShutterGnosis) == Joseph);
        // Get the total proposal count
        uint32 totalProposalCountAfter = Azorius.totalProposalCount();
        // Take 1 integer from the total count because proposal ids starts at index 0
        uint32 proposalId = totalProposalCountAfter - 1;
        // Vote for the proposal {LinearERC20Voting-vote}
        // NO = 0 | YES = 1 | ABSTAIN = 2
        vm.startPrank(Joseph);
        LinearERC20Voting.vote(proposalId, 1);
        vm.startPrank(0x06c2c4dB3776D500636DE63e4F109386dCBa6Ae2);
        LinearERC20Voting.vote(proposalId, 1);
        vm.startPrank(0x18856179B08b4C92Bf5ad5c7A16e11ac8Bd022aA);
        LinearERC20Voting.vote(proposalId, 1);
        vm.startPrank(0x39EE88e8c70f289a28892D062aB0D4EB06432Fa0);
        LinearERC20Voting.vote(proposalId, 1);
        vm.startPrank(0x057928bc52bD08e4D7cE24bF47E01cE99E074048);
        LinearERC20Voting.vote(proposalId, 1);
        vm.startPrank(0xffFA76e332cA7afaae3931cb5d513B7fd681C4CF);
        LinearERC20Voting.vote(proposalId, 1);
        vm.startPrank(0xDffDb9BeeA2aB3151BcBcf37a01EE8726F22ed94);
        LinearERC20Voting.vote(proposalId, 1);
        // Mine the future blocks until the proposal voting period ends
        vm.roll(block.number + 21_600);
        // Check if the proposal passed {LinearERC20Voting-isPassed}
        bool passed = LinearERC20Voting.isPassed(proposalId);
        assert(passed);
        // Prepare the transactions to be executed
        // We need to break them apart and join the similar types
        (address[] memory targets, uint256[] memory values, bytes[] memory data, IAzorius.Operation[] memory operations)
        = _prepareTransactionsForExecution(_prepareTransactionsForProposal());
        // Execute the proposal {Azorius-executeProposal}
        Azorius.executeProposal(proposalId, targets, values, data, operations);
        // Validate if the proposal was executed correctly
        IAzorius.ProposalState state = Azorius.proposalState(proposalId);
        assert(state == IAzorius.ProposalState.EXECUTED);
        // Validate if the Shutter Gnosis contract received the Savings Dai Token (DSR)
        // Since there is a loss of precision in the process, we need to check if the amount is
        // within the expected range using 0,000001% of the amount as the margin of error
        assert(SavingsDai.maxWithdraw(ShutterGnosis) >= ((amount * decimalsDAI * 999_999) / 1_000_000));
        // Validate if the DAI was transferred to the Shutter Gnosis
        assert(SavingsDai.balanceOf(ShutterGnosis) > initialDaoSavingsDaibalance);
        // Validate if the USDC was transferred to the DSR contract
        assert(USDC.balanceOf(ShutterGnosis) == initialDaoUSDCbalance - amount * decimalsUSDC);
    }
}
