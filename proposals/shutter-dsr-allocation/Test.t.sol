// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "./ITest.sol";
import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

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

contract Calldata is Test {
  /// @dev Top #1 USDC Holder will be impersonated
  address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

  // Amount to be converted
  uint256 amount = 3_000_000;

  /// @dev Stablecoin configurations
  uint256 constant decimalsUSDC = 10 ** 6;
  uint256 constant decimalsDAI = 10 ** 18;
  IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  /// @dev Maker PSM contract
  IDssPsm DssPsm = IDssPsm(0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A);
  address AuthGemJoin5 = 0x0A59649758aa4d66E25f08Dd01271e891fe52199;

  /// @dev Maker DSR contract
  IDaiJoin DaiJoin = IDaiJoin(0x9759A6Ac90977b93B58547b4A71c78317f391A28);
  IPot Pot = IPot(0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7);
  IVat Vat = IVat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Alice);
  }

  /// @dev Basic test. Run it with `yarn test:fork` to see the console log.
  function test_depositUSDCtoPot() external {
    // Approve PSM to spend USDC {ERC20-approve}
    USDC.approve(AuthGemJoin5, amount * decimalsUSDC);

    // Convert USDC to DAI {DssPsm-sellGem}
    DssPsm.sellGem(Alice, amount * decimalsUSDC);

    // BalanceOf DAI {ERC20-balanceOf}
    uint256 balanceBeforeDAI = DAI.balanceOf(Alice);

    // Assert increased balance of DAI
    assertEq(balanceBeforeDAI, amount * decimalsDAI);

    // Approve Pot to spend DAI {ERC20-approve}
    DAI.approve(address(DaiJoin), amount * decimalsDAI);

    // Join DAI to Vat {SdrManager-join}
    DaiJoin.join(Alice, amount * decimalsDAI);

    // Hope to join Vat {Vat-hope}
    Vat.hope(address(Pot));

    // Drip DAI {Pot-drip}
    uint256 chi = Pot.drip();

    // Join with DAI {Pot-join}
    uint256 RAY = 10 ** 27;
    Pot.join(mul(amount, RAY) / chi);
  }

  /// @dev Multiplication function to prevent overflow fetched
  /// from the official DAI's Pot contract.
  function mul(uint x, uint y) internal pure returns (uint z) {
    require(y == 0 || (z = x * y) / y == x);
  }
}
