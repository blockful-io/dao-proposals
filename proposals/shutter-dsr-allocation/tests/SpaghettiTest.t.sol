// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../interfaces/Azorius/IAzorius.sol";
import "../interfaces/Azorius/ILinearERC20Voting.sol";
import "../interfaces/Azorius/IVotes.sol";
import "../interfaces/Dai/IDssPsm.sol";
import "../interfaces/Dai/ISavingsDai.sol";
import "../interfaces/ERC20/IERC20.sol";

import { Treasury } from "../contracts/Treasury.sol";
import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

//  https://snapshot.org/#/shutterdao0x36.eth/proposal/0xb4a8f52edb23311c78c9523331e778578ef03ecf70255a6d6ad1eb3f437725dd
//
//  TEMP CHECK: Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract
//
//  -  Convert 3M USDC to DAI
//  -  Deposit 3M DAI in the Dai Savings Rate (DSR) Contract
//  -  Generate additional 120K DAI per annum (likely more temporarily) for Shutter DAO 0x36
//
//  ERC20 (USDC, DAI)
//      0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
//      0x6B175474E89094C44Da98b954EedeAC495271d0F
//  Maker PSM (DssPsm, AuthGemJoin5)
//      0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A
//      0x0A59649758aa4d66E25f08Dd01271e891fe52199
//  Maker DSR (SavingsDai)
//      0x83F20F44975D03b1b09e64809B757c47f942BEeA
//  Azorius Governance (Azorius, LinearERC20Voting, ShutterToken, Gnosis)
//      0xAA6BfA174d2f803b517026E93DBBEc1eBa26258e
//      0x4b29d8B250B8b442ECfCd3a4e3D91933d2db720F
//      0xe485E2f1bab389C08721B291f6b59780feC83Fd7
//      0x36bD3044ab68f600f6d3e081056F34f2a58432c4

contract ShutterDao is Test {
  /// @dev Top #1 USDC Holder will be impersonating all calls
  address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

  /// @dev Our beloved contributor that will submit the proposal and approve it
  address Joseph = 0x9Cc9C7F874eD77df06dCd41D95a2C858cd2a2506;

  /// @dev Shutter Gnosis
  address ShutterGnosis = 0x36bD3044ab68f600f6d3e081056F34f2a58432c4;
  uint256 initialDaoUSDCbalance;

  // Amount of USDC to be sent to the DSR
  uint256 amount = 3_000_000;

  /// @dev Shutter Token
  address ShutterToken = 0xe485E2f1bab389C08721B291f6b59780feC83Fd7;

  /// @dev Stablecoin configurations
  uint256 constant decimalsUSDC = 10 ** 6;
  uint256 constant decimalsDAI = 10 ** 18;
  IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  /// @dev Maker PSM contracts to convert USDC to DAI
  IDssPsm DssPsm = IDssPsm(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A);
  address AuthGemJoin5 = 0x0A59649758aa4d66E25f08Dd01271e891fe52199;

  /// @dev Maker DAI Savings Token
  ISavingsDai SavingsDai = ISavingsDai(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

  /// @dev Azorius contract to submit proposals
  IAzorius Azorius = IAzorius(0xAA6BfA174d2f803b517026E93DBBEc1eBa26258e);

  /// @dev Shutter DAO Votting contract
  ILinearERC20Voting LinearERC20Voting = ILinearERC20Voting(0x4b29d8B250B8b442ECfCd3a4e3D91933d2db720F);

  /// @dev Multical contract to execute multiple calls in one transaction
  Treasury treasury = new Treasury();

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Alice);
    initialDaoUSDCbalance = USDC.balanceOf(ShutterGnosis);
  }

  /**
   * @dev Tests the entire process of depositing USDC in the DSR contract
   * and receiving the shares in the SavingsDai contract.
   *
   * The test will:
   * 1. Approve the PSM to spend USDC.
   * 2. Convert USDC to DAI.
   * 3. Approve the SavingsDai to spend DAI.
   * 4. Deposit DAI in the SavingsDai contract.
   */
  function test_depositUSDCtoSavingsDai() external {
    // Approve PSM to spend USDC {ERC20-approve}
    USDC.approve(AuthGemJoin5, amount * decimalsUSDC);
    // Check if allowance is set for USDC {ERC20-allowance}
    assert(USDC.allowance(Alice, AuthGemJoin5) == amount * decimalsUSDC);

    // Convert USDC to DAI {DssPsm-sellGem}
    DssPsm.sellGem(Alice, amount * decimalsUSDC);
    // Check if DAI balance was increased {ERC20-balanceOf}
    assert(DAI.balanceOf(Alice) == amount * decimalsDAI);

    // Approve SavingsDai to spend DAI {ERC20-approve}
    DAI.approve(address(SavingsDai), amount * decimalsDAI);
    // Check if allowance is set for DAI {ERC20-allowance}
    assert(DAI.allowance(Alice, address(SavingsDai)) == amount * decimalsDAI);

    // Preview the amount of shares that will be received {SavingsDai-previewDeposit}
    uint256 sharesToBeReceived = SavingsDai.previewDeposit(amount * decimalsDAI);
    // Deposit DAI to SavingsDai {SavingsDai-deposit}
    uint256 sharesReceived = SavingsDai.deposit(amount * decimalsDAI, Alice);
    // Check if the amount of shares received is the same as the previewed amount {SavingsDai-deposit}
    assert(sharesReceived == sharesToBeReceived);
    // Check if the user's balance of shares was increased {SavingsDai-balanceOf}
    assert(sharesReceived == SavingsDai.balanceOf(Alice));
  }

  /**
   * @dev Tests the entire process of depositing USDC in the DSR contract but
   * using the Treasury contract as a simulation of the Shutter DAO Gnosis contract.
   *
   * The test will:
   * 1. Encode the calldata for the USDC approval.
   * 2. Encode the calldata for the USDC swap on PSM for DAI.
   * 3. Encode the calldata for the DAI approval.
   * 4. Encode the calldata for the DAI deposit.
   * 5. Execute the encoded calls via multicall in the treasury contract.
   */
  function test_calldataUsdcToSDR() external {
    // Deploy the treasury contract to simulate the Gnosis without governance
    treasury = new Treasury();
    USDC.transfer(address(treasury), amount * decimalsUSDC);

    // Encode the calldata for the USDC approval
    bytes memory approveUSDC = abi.encodeWithSelector(IERC20.approve.selector, AuthGemJoin5, amount * decimalsUSDC);
    // Encode the calldata for the USDC swap on PSM for DAI
    bytes memory sellGem = abi.encodeWithSelector(DssPsm.sellGem.selector, address(treasury), amount * decimalsUSDC);
    // Encode the calldata for the DAI approval
    bytes memory approveDAI = abi.encodeWithSelector(
      IERC20.approve.selector,
      address(SavingsDai),
      amount * decimalsDAI
    );
    // Encode the calldata for the DAI deposit
    bytes memory deposit = abi.encodeWithSelector(SavingsDai.deposit.selector, amount * decimalsDAI, address(treasury));

    // Aggregate the addresses
    address[] memory targets = new address[](4);
    targets[0] = address(USDC);
    targets[1] = address(DssPsm);
    targets[2] = address(DAI);
    targets[3] = address(SavingsDai);

    // Aggregate the calls
    bytes[] memory calls = new bytes[](4);
    calls[0] = approveUSDC;
    calls[1] = sellGem;
    calls[2] = approveDAI;
    calls[3] = deposit;

    // Submit the encoded calls to the treasury contract which will invoke them
    bytes[] memory results = new bytes[](4);
    results = treasury.multicall(targets, calls);
    // Check if the SavingsDai balance was received by the treasury
    assert(abi.decode(results[3], (uint256)) == SavingsDai.balanceOf(address(treasury)));
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
  function test_submitProposal() external {
    // Delegate the votes of the top #1 Shutter Token holder to Joseph {Votes-delegate}
    address gigawhale = ShutterGnosis;
    vm.startPrank(gigawhale); // Pretending to be the gnosis contract
    IVotes(ShutterToken).delegate(Joseph);
    // Did Joseph became the delegate of the top #1 holder? {Votes-delegates}
    assert(IVotes(ShutterToken).delegates(gigawhale) == Joseph);

    // Prepare the transactions to submit the proposal. These are the steps that will be executed
    // in the proposal once its approved.
    IAzorius.Transaction[] memory transactions = _prepareTransactionsForProposal();

    // Prank Joseph, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(Joseph);
    uint32 totalProposalCountBefore = Azorius.totalProposalCount();
    Azorius.submitProposal(
      address(LinearERC20Voting),
      "0x",
      transactions,
      "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract"
    );

    // Check if the total proposal count was increased by 1 {Azorius-totalProposalCount}
    uint32 totalProposalCountAfter = Azorius.totalProposalCount();
    assert(totalProposalCountAfter == totalProposalCountBefore + 1);

    // Mine current block because the proposal needs to be mined before voting
    // See Votes.sol at line 107 in ShutterToken
    // https://etherscan.io/token/0xe485E2f1bab389C08721B291f6b59780feC83Fd7#code
    vm.roll(block.number + 1);

    // Vote for the proposal {LinearERC20Voting-vote}
    // NO = 0 | YES = 1 | ABSTAIN = 2
    LinearERC20Voting.vote(totalProposalCountBefore, 1);

    // Prepare the transactions to be executed
    // We need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionsForExecution(transactions);

    // Mine the future blocks until the proposal ends the voting period
    vm.roll(block.number + 21600);

    // Check if the proposal passed {LinearERC20Voting-isPassed}
    bool passed = LinearERC20Voting.isPassed(totalProposalCountBefore);
    assert(passed);

    // Execute the proposal {Azorius-executeProposal}
    Azorius.executeProposal(totalProposalCountBefore, targets, values, data, operations);

    // Validate if the proposal was executed correctly
    IAzorius.ProposalState state = Azorius.proposalState(totalProposalCountBefore);
    assert(state == IAzorius.ProposalState.EXECUTED);

    // Validate if the Shutter Gnosis contract received the Savings Dai Token (SDR)
    // Since there is a loss of precision in the process, we need to check if the amount is
    // within the expected range using 0,000001% of the amount as the margin of error
    assert(SavingsDai.maxWithdraw(ShutterGnosis) >= ((amount * decimalsDAI * 999_999) / 1_000_000));

    // Validate if the USDC was transferred to the DSR contract
    assert(USDC.balanceOf(ShutterGnosis) == initialDaoUSDCbalance - amount * decimalsUSDC);
  }

  /**
   * @dev Same as {test_submitProposal} but without any assertions and whitespaces.
   */
  function test_submitProposalNoAssertions() external {
    vm.startPrank(ShutterGnosis); // Pretending to be the gnosis contract
    IVotes(ShutterToken).delegate(Joseph);
    // Prepare the transactions to submit the proposal. These are the steps that will be executed
    // in the proposal once its approved.
    IAzorius.Transaction[] memory transactions = _prepareTransactionsForProposal();
    uint32 totalProposalCountBefore = Azorius.totalProposalCount();
    // Prank Joseph, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(Joseph);
    Azorius.submitProposal(
      address(LinearERC20Voting),
      "0x",
      transactions,
      "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract"
    );
    // Mine current block because the proposal needs to be mined before voting
    // See Votes.sol at line 107 in ShutterToken
    // https://etherscan.io/token/0xe485E2f1bab389C08721B291f6b59780feC83Fd7#code
    vm.roll(block.number + 1);
    // Vote for the proposal {LinearERC20Voting-vote}
    LinearERC20Voting.vote(totalProposalCountBefore, 1);
    // Prepare the transactions to be executed
    // We need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionsForExecution(transactions);
    // Mine the future blocks where the voting period ends
    vm.roll(block.number + 21600);
    // Execute the proposal {Azorius-executeProposal}
    Azorius.executeProposal(totalProposalCountBefore, targets, values, data, operations);
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
