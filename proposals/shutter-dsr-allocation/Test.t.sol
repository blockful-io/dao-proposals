// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "./Interfaces.sol";
import "./ShutterDaoDSR.sol";
import "./DelegateMulticall.sol";
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
//  Maker DSR (DaiJoin,Pot, Vat, Vow)
//      0x9759A6Ac90977b93B58547b4A71c78317f391A28
//      0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7
//      0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B
//      0xA950524441892A31ebddF91d3cEEFa04Bf454466

contract ShutterDao is Test {
  /// @dev Top #1 USDC Holder will be impersonating all calls
  address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

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

  /// @dev Maker DSR contracts to receive DAI
  IDaiJoin DaiJoin = IDaiJoin(0x9759A6Ac90977b93B58547b4A71c78317f391A28);
  IPot Pot = IPot(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
  IVat Vat = IVat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);

  /// @dev Maker DAI Savings Token
  ISavingsDai SavingsDai = ISavingsDai(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

  /// @dev DaiJoin will multiply the DAI amount by this constant before joining
  uint constant ONE = 10 ** 27;

  /// @dev Multical contract to execute multiple calls in one transaction
  DelegateMulticall multicall = new DelegateMulticall();

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Alice);
  }

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

  function test_calldataForSavingsDai() external {
    // Encode the calldata for the USDC approval
    bytes memory approveUSDC = abi.encodeWithSelector(IERC20.approve.selector, AuthGemJoin5, amount * decimalsUSDC);
    // Encode the calldata for the USDC swap on PSM for DAI
    bytes memory sellGem = abi.encodeWithSelector(DssPsm.sellGem.selector, Alice, amount * decimalsUSDC);
    // Encode the calldata for the DAI approval
    bytes memory approveDAI = abi.encodeWithSelector(
      IERC20.approve.selector,
      address(SavingsDai),
      amount * decimalsDAI
    );
    // Encode the calldata for the DAI deposit
    bytes memory deposit = abi.encodeWithSelector(SavingsDai.deposit.selector, amount * decimalsDAI, Alice);

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

    bytes[] memory results = new bytes[](4);
    results = multicall.delegateMulticall(targets, calls);
    assert(abi.decode(results[3], (uint256)) == SavingsDai.balanceOf(Alice));
  }

  // function test_ShutterDaoDSR() external {
  //   ShutterDaoDSR executor = new ShutterDaoDSR(Alice);
  //   USDC.transfer(address(executor), amount * decimalsUSDC);
  //   // Run the execution from USDC deposit to the DSR Vault
  //   executor.depositAll();
  //   // Run the execution from DSR Vault to DAI withdraw
  //   executor.withdrawAll();
  // }

  // function test_calldataForShutterDaoDSR() external {
  //   // We are deploying here but we assume the contract has been previously deployed
  //   ShutterDaoDSR executor = new ShutterDaoDSR(Alice);

  //   // Encode the calldata for the USDC approval
  //   bytes memory approve = abi.encodeWithSelector(IERC20.approve.selector, AuthGemJoin5, amount * decimalsUSDC);
  //   // Encode the calldata for the USDC transfer
  //   bytes memory transferFrom = abi.encodeWithSelector(
  //     IERC20.transferFrom.selector,
  //     Alice,
  //     address(executor),
  //     amount * decimalsUSDC
  //   );
  //   // Encode the calldata for the depositAll function
  //   bytes memory depositAll = abi.encodeWithSelector(executor.depositAll.selector);
  //   // Encode the calldata for the withdrawAll function
  //   bytes memory withdrawAll = abi.encodeWithSelector(executor.withdrawAll.selector);

  //   // Aggregate the addresses
  //   address[] memory targets = new address[](4);
  //   targets[0] = address(USDC);
  //   targets[1] = address(USDC);
  //   targets[2] = address(executor);
  //   targets[3] = address(executor);

  //   // Aggregate the calls
  //   bytes[] memory calls = new bytes[](4);
  //   calls[0] = approve;
  //   calls[1] = transferFrom;
  //   calls[2] = depositAll;
  //   calls[3] = withdrawAll;

  //   // Execute the calls forwarding the msg.sender.
  //   // If any of the transaction are unsuccessful, the whole transaction will revert
  //   executor.delegateMulticall(targets, calls);
  // }

  // /// @dev Run it with `yarn test:fork` to see the console log.
  // function test_depositUSDCtoPot() external {
  //   // Approve PSM to spend USDC {ERC20-approve}
  //   USDC.approve(AuthGemJoin5, amount * decimalsUSDC);
  //   // Check if allowance is set for USDC {ERC20-allowance}
  //   assert(USDC.allowance(Alice, AuthGemJoin5) == amount * decimalsUSDC);

  //   // Convert USDC to DAI {DssPsm-sellGem}
  //   DssPsm.sellGem(Alice, amount * decimalsUSDC);
  //   // Check if DAI balance was increased {ERC20-balanceOf}
  //   assert(DAI.balanceOf(Alice) == amount * decimalsDAI);

  //   // Approve Pot to spend DAI {ERC20-approve}
  //   DAI.approve(address(DaiJoin), amount * decimalsDAI);
  //   // Check if allowance is set for DAI {ERC20-allowance}
  //   assert(DAI.allowance(Alice, address(DaiJoin)) == amount * decimalsDAI);

  //   // Add DAI to Vat {DaiJoin-join}
  //   // This will burn DAI token and change the Vat balance of the user
  //   DaiJoin.join(Alice, amount * decimalsDAI);
  //   // Check if DAI balance was decreased {ERC20-balanceOf}
  //   assert(DAI.balanceOf(Alice) == 0);
  //   // Check if DAI balance was increased in the Vat {Vat-dai}
  //   // The DAI deposited can be seen in the user's internal state balance in the Vat
  //   assert(Vat.dai(Alice) == amount * decimalsDAI * ONE);

  //   // Hope to join Vat {Vat-hope}
  //   // This will permit the Pot contract to interact with the Vat contract on behalf of the user
  //   Vat.hope(address(Pot));
  //   // Check if the Pot can interact with the Vat {Vat-can} on behalf of the user
  //   assert(Vat.can(Alice, address(Pot)) == 1);

  //   // Drip DAI {Pot-drip}
  //   // This will refresh the interest rate accrued
  //   // Drip should always be called before joining or exiting the Pot
  //   // Returns the new chi value
  //   uint256 chi = Pot.drip();

  //   // Join the Pot with internal amount of DAI in state storage {Pot-join}
  //   // The amount is multiplied by Ray and divide by chi to get the approximated
  //   // amount the user first joined using {DaiJoin-join}
  //   uint256 RAY = 10 ** 27;
  //   uint wad = mul(amount, RAY) / chi;
  //   // Join the Pot with the approximated pie amount
  //   Pot.join(wad);
  //   // Check if the user's pie balance was increased {Pot-pie}
  //   assert(Pot.pie(Alice) == wad);
  // }

  /// @dev Multiplication function to prevent overflow fetched
  /// from the official Dai's Pot contract.
  function mul(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x);
  }
}
