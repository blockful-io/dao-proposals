// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../../interfaces/Azorius/IAzorius.sol";
import "../../interfaces/Azorius/ILinearERC20Voting.sol";
import "../../interfaces/Azorius/IVotes.sol";
import "../../interfaces/Dai/IDssPsm.sol";
import "../../interfaces/Dai/ISavingsDai.sol";
import "../../interfaces/ERC20/IERC20.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract Context is Test {
  /// @dev Top #1 USDC Holder
  address Alice = 0x4B16c5dE96EB2117bBE5fd171E4d203624B014aa;

  /// @dev Top #1 DAI Holder
  address Jotaro = 0x40ec5B33f54e0E8A33A975908C5BA1c14e5BbbDf;

  /// @dev Our beloved contributor that will submit the proposal and approve it
  address Joseph = 0x9Cc9C7F874eD77df06dCd41D95a2C858cd2a2506;

  /// @dev Shutter Gnosis
  address ShutterGnosis = 0x36bD3044ab68f600f6d3e081056F34f2a58432c4;

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
}
