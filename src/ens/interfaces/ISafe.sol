// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ISafe {
    function execTransaction(
        address,
        uint256,
        bytes memory,
        uint8,
        uint256,
        uint256,
        uint256,
        address,
        address,
        bytes memory
    )
        external;
}
