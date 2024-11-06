// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ITokenStreamingEP5_22 {
    event Claimed(address indexed recipient, uint256 amount);
    event Configured(address token, address tokenSender, uint256 startTime, uint256 endTime, uint256 streamingRate);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function claim(address recipient, uint256 amount) external;
    function claimableBalance() external view returns (uint256);
    function endTime() external view returns (uint256);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function setEndTime(uint256 _endTime) external;
    function startTime() external view returns (uint256);
    function streamingRate() external view returns (uint256);
    function token() external view returns (address);
    function tokenSender() external view returns (address);
    function totalClaimed() external view returns (uint256);
    function transferOwnership(address newOwner) external;
}
