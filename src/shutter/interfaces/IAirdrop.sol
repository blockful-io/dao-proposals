// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IAirdrop {
    function claimUnusedTokens(address beneficiary) external;
}
