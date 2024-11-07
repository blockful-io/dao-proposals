// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./interfaces/IAirdrop.sol";

contract Airdrop is Test {
    /**
     * @dev Claim the unclaimed tokens from the Airdrop contract
     *
     * Walkthrough:
     * 1. Prank the caller
     * 2. Claim the tokens
     * 3. Stops the prank
     *
     * @param caller The pranked address to execute the call
     * @param airdropContract The address of the Airdrop contract
     * @param beneficiary The address to receive the unclaimed tokens
     */
    function claimUnusedTokens(address caller, address airdropContract, address beneficiary) public {
        // Pranks the delegator
        vm.startPrank(caller);
        // Claim the unused tokens
        IAirdrop(airdropContract).claimUnusedTokens(beneficiary);
        // Stops the prank
        vm.stopPrank();
    }
}
