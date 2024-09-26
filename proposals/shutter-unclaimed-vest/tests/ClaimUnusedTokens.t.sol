// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "../Context.sol";

contract ClaimUnusedTokens is Test, Context {
    /// @dev A function invoked before each test case is run.
    function setUp() public virtual { }

    /**
     * @dev Will validate the following steps:
     * - Claim of unused tokens from the Airdrop contract
     * - Check the transfer to the treasury.
     */
    function test_claim_unused_tokens() external {
        // Pretending to be the gnosis contract
        vm.startPrank(ShutterGnosis);
        // The balance of the Airdrop contract before the claim
        uint256 airdropBalanceBefore = SHU.balanceOf(Airdrop);
        assert(airdropBalanceBefore == 46_154_583_762_696_716_270_000_000);
        // Store the balance of the treasury before the claim
        uint256 treasuryBalanceBefore = SHU.balanceOf(ShutterGnosis);
        // Claim tokens from the Airdrop Contract
        AirdropContract.claimUnusedTokens(ShutterGnosis);
        // The balance of the Airdrop contract after the claim should be 0
        uint256 airdropBalanceAfter = SHU.balanceOf(Airdrop);
        assert(airdropBalanceAfter == 0);
        // The balance of the treasury after the claim should be the sum of its previous balance and the claimed airdrop
        // balance
        uint256 treasuryBalanceAfter = SHU.balanceOf(ShutterGnosis);
        assert(treasuryBalanceAfter == treasuryBalanceBefore + airdropBalanceBefore);
    }
}
