// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface BatchPlanner {
    struct Plan {
        address recipient;
        uint256 amount;
        uint256 start;
        uint256 cliff;
        uint256 rate;
    }

    event BatchCreated(address indexed creator, address token, uint256 recipients, uint256 totalAmount, uint8 mintType);

    function batchLockingPlans(
        address locker,
        address token,
        uint256 totalAmount,
        Plan[] memory plans,
        uint256 period,
        uint8 mintType
    ) external;
    function batchVestingPlans(
        address locker,
        address token,
        uint256 totalAmount,
        Plan[] memory plans,
        uint256 period,
        address vestingAdmin,
        bool adminTransferOBO,
        uint8 mintType
    ) external;
}
