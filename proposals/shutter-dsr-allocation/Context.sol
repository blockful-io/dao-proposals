// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../../contracts/governance/azorius/interfaces/IAzorius.sol";
import "../../contracts/governance/azorius/interfaces/ILinearERC20Voting.sol";
import "../../contracts/dai/interfaces/IDssPsm.sol";
import "../../contracts/dai/interfaces/ISavingsDai.sol";
import "../../contracts/token/interfaces/IERC20.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract Context is Test {
    /// @dev Our beloved contributor that will submit the proposal and approve it
    /// Joseph seems to be allowed to submit proposals.
    address Joseph = 0x9Cc9C7F874eD77df06dCd41D95a2C858cd2a2506;

    /// @dev Shutter Gnosis is USDC Holder
    address ShutterGnosis = 0x36bD3044ab68f600f6d3e081056F34f2a58432c4;

    // Amount of USDC to be sent to the DSR
    uint256 amount = 3_000_000;

    // Metadata for the proposal
    string metadata = "Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract";

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

    /**
     * @dev Prepares the transactions to be submitted in the proposal.
     * @return transactions The transactions to be executed in the proposal.
     */
    function _prepareTransactionsForProposal() internal view returns (IAzorius.Transaction[] memory transactions) {
        transactions = new IAzorius.Transaction[](4);
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
    }
}
