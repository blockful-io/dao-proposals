// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "./Interfaces.sol";
import { Treasury } from "./Treasury.sol";
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

contract ShutterDao is Test {
  /// @dev Top #1 USDC Holder will be impersonating all calls
  address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

  /// @dev Our beloved contributor that will submit the proposal and approve it
  address Joseph = 0x9Cc9C7F874eD77df06dCd41D95a2C858cd2a2506;

  /// @dev Shutter Gnosis
  address ShutterGnosis = 0x36bD3044ab68f600f6d3e081056F34f2a58432c4;

  // Amount of USDC to be sent to the DSR
  uint256 amount = 3_000_000;

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

  /// @dev Shutter Token
  address ShutterToken = 0xe485E2f1bab389C08721B291f6b59780feC83Fd7;

  /// @dev DaiJoin will multiply the DAI amount by this constant before joining
  uint constant ONE = 10 ** 27;

  /// @dev Multical contract to execute multiple calls in one transaction
  Treasury treasury = new Treasury();

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Alice);
    // Deploy the treasury contract to simulate the Gnosis without governance
    treasury = new Treasury();
    USDC.transfer(address(treasury), amount * decimalsUSDC);
  }

  // function test_depositUSDCtoSavingsDai() external {
  //   // Approve PSM to spend USDC {ERC20-approve}
  //   USDC.approve(AuthGemJoin5, amount * decimalsUSDC);
  //   // Check if allowance is set for USDC {ERC20-allowance}
  //   assert(USDC.allowance(Alice, AuthGemJoin5) == amount * decimalsUSDC);

  //   // Convert USDC to DAI {DssPsm-sellGem}
  //   DssPsm.sellGem(Alice, amount * decimalsUSDC);
  //   // Check if DAI balance was increased {ERC20-balanceOf}
  //   assert(DAI.balanceOf(Alice) == amount * decimalsDAI);

  //   // Approve SavingsDai to spend DAI {ERC20-approve}
  //   DAI.approve(address(SavingsDai), amount * decimalsDAI);
  //   // Check if allowance is set for DAI {ERC20-allowance}
  //   assert(DAI.allowance(Alice, address(SavingsDai)) == amount * decimalsDAI);

  //   // Preview the amount of shares that will be received {SavingsDai-previewDeposit}
  //   uint256 sharesToBeReceived = SavingsDai.previewDeposit(amount * decimalsDAI);
  //   // Deposit DAI to SavingsDai {SavingsDai-deposit}
  //   uint256 sharesReceived = SavingsDai.deposit(amount * decimalsDAI, Alice);
  //   // Check if the amount of shares received is the same as the previewed amount {SavingsDai-deposit}
  //   assert(sharesReceived == sharesToBeReceived);
  //   // Check if the user's balance of shares was increased {SavingsDai-balanceOf}
  //   assert(sharesReceived == SavingsDai.balanceOf(Alice));
  // }

  // function test_calldataForSavingsDai() external {
  //   // Encode the calldata for the USDC approval
  //   bytes memory approveUSDC = abi.encodeWithSelector(IERC20.approve.selector, AuthGemJoin5, amount * decimalsUSDC);
  //   // Encode the calldata for the USDC swap on PSM for DAI
  //   bytes memory sellGem = abi.encodeWithSelector(DssPsm.sellGem.selector, address(treasury), amount * decimalsUSDC);
  //   // Encode the calldata for the DAI approval
  //   bytes memory approveDAI = abi.encodeWithSelector(
  //     IERC20.approve.selector,
  //     address(SavingsDai),
  //     amount * decimalsDAI
  //   );
  //   // Encode the calldata for the DAI deposit
  //   bytes memory deposit = abi.encodeWithSelector(SavingsDai.deposit.selector, amount * decimalsDAI, address(treasury));

  //   // Aggregate the addresses
  //   address[] memory targets = new address[](4);
  //   targets[0] = address(USDC);
  //   targets[1] = address(DssPsm);
  //   targets[2] = address(DAI);
  //   targets[3] = address(SavingsDai);

  //   // Aggregate the calls
  //   bytes[] memory calls = new bytes[](4);
  //   calls[0] = approveUSDC;
  //   calls[1] = sellGem;
  //   calls[2] = approveDAI;
  //   calls[3] = deposit;

  //   bytes[] memory results = new bytes[](4);
  //   results = treasury.multicall(targets, calls);
  //   assert(abi.decode(results[3], (uint256)) == SavingsDai.balanceOf(address(treasury)));
  // }

  function test_submitProposal() external {
    // Delegate the votes of the top #1 Shutter Token holder to Joseph {Votes-delegate}
    address gigawhale = ShutterGnosis;
    vm.startPrank(gigawhale); // Pretending to be the gnosis contract
    IVotes(ShutterToken).delegate(Joseph);
    // Did Joseph became the delegate of the top #1 holder? {Votes-delegates}
    assert(IVotes(ShutterToken).delegates(gigawhale) == Joseph);

    // Going to future blocks so upperLookupRecent will return the correct value after delegation
    vm.roll(block.number + 50000);

    IAzorius.Transaction[] memory transactions = _prepareTransactionForProposal();

    uint32 totalProposalCountBefore = Azorius.totalProposalCount();

    // Prank the Joseph, which can submit proposals and get it done {Azorius-submitProposal}
    vm.startPrank(Joseph);
    Azorius.submitProposal(
      0x4b29d8B250B8b442ECfCd3a4e3D91933d2db720F,
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
    LinearERC20Voting.vote(totalProposalCountBefore, 1);

    // Get proposal votes {LinearERC20Voting-getProposalVotes}
    // Proposal count starts at 1 but proposal id starts at 0,
    // so when looking for the proposal votes we need to subtract 1 from the total proposal count
    _getProposalVotes(totalProposalCountBefore);

    // Prepare the transactions to be executed
    // We need to break them apart and join the similar types
    (
      address[] memory targets,
      uint256[] memory values,
      bytes[] memory data,
      IAzorius.Operation[] memory operations
    ) = _prepareTransactionForExecution(transactions);

    // Mine the future blocks until the proposal ends the voting period
    vm.roll(block.number + 21600);

    // Check if the proposal passed {LinearERC20Voting-isPassed}
    bool passed = LinearERC20Voting.isPassed(totalProposalCountBefore);
    assert(passed);

    // Execute the proposal {Azorius-executeProposal}
    Azorius.executeProposal(totalProposalCountBefore, targets, values, data, operations);
  }

  function _prepareTransactionForExecution(
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

  function _prepareTransactionForProposal() internal view returns (IAzorius.Transaction[] memory) {
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

  function _getProposalVotes(uint32 _totalProposalCountBefore) internal view {
    (
      uint256 noVotes,
      uint256 yesVotes,
      uint256 abstainVotes,
      uint32 startBlock,
      uint32 endBlock,
      uint256 votingSupply
    ) = LinearERC20Voting.getProposalVotes(_totalProposalCountBefore);
    console2.log("noVotes", noVotes);
    console2.log("yesVotes", yesVotes);
    console2.log("abstainVotes", abstainVotes);
    console2.log("startBlock", startBlock);
    console2.log("endBlock", endBlock);
    console2.log("votingSupply", votingSupply);
  }
}
