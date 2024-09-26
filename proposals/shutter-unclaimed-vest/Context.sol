// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../../contracts/token/interfaces/IERC20.sol";
import "../../contracts/gnosis/interfaces/IGnosisSafe.sol";
import "../../contracts/shutter/interfaces/IAirdrop.sol";
import "../../contracts/governance/azorius/interfaces/IAzorius.sol";
import "../../contracts/governance/azorius/interfaces/ILinearERC20Voting.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract Context is Test {
    /// @dev Our beloved contributor that will submit the proposal and approve it
    /// Joseph seems to be allowed to submit proposals.
    address Joseph = 0x9Cc9C7F874eD77df06dCd41D95a2C858cd2a2506;

    // Metadata for the proposal
    string metadata = "Claim Unclaimed Tokens from Airdrop and Disable Vesting Pool Manager";

    /// @dev Azorius contract to submit proposals
    IAzorius Azorius = IAzorius(0xAA6BfA174d2f803b517026E93DBBEc1eBa26258e);

    /// @dev Shutter DAO Votting contract
    ILinearERC20Voting LinearERC20Voting = ILinearERC20Voting(0x4b29d8B250B8b442ECfCd3a4e3D91933d2db720F);

    /// @dev Shutter Gnosis
    address ShutterGnosis = 0x36bD3044ab68f600f6d3e081056F34f2a58432c4;
    IGnosisSafe TreasuryContract = IGnosisSafe(ShutterGnosis);

    /// @dev Shutter Token
    address ShutterToken = 0xe485E2f1bab389C08721B291f6b59780feC83Fd7;
    IERC20 SHU = IERC20(ShutterToken);

    /// @dev The Airdrop contract to umclaim the tokens
    address Airdrop = 0x024574C4C42c72DfAaa3ccA80f73521a4eF5Ca94;
    IAirdrop AirdropContract = IAirdrop(Airdrop);

    /// @dev The vesting contract that is a Safe module and must have rights revoked
    address VestingPoolManager = 0xD724DBe7e230E400fe7390885e16957Ec246d716;

    /**
     * @dev Prepares the transactions to be submitted in the proposal.
     * @return transactions The transactions to be executed in the proposal.
     */
    function _prepareTransactionsForProposal() internal view returns (IAzorius.Transaction[] memory transactions) {
        transactions = new IAzorius.Transaction[](2);
        transactions[0] = IAzorius.Transaction({
            to: address(AirdropContract),
            value: 0,
            data: abi.encodeWithSelector(IAirdrop.claimUnusedTokens.selector, ShutterGnosis),
            operation: IAzorius.Operation.Call
        });
        transactions[1] = IAzorius.Transaction({
            to: address(TreasuryContract),
            value: 0,
            data: abi.encodeWithSelector(IGnosisSafe.disableModule.selector, address(0x1), VestingPoolManager),
            operation: IAzorius.Operation.Call
        });
    }
}
