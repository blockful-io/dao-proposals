// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface ISavingsDai {
    function balanceOf(address account) external view returns (uint256);

    function deposit(uint256 assets, address receiver) external returns (uint256 shares);

    function previewDeposit(uint256 assets) external view returns (uint256);

    function maxWithdraw(address owner) external view returns (uint256);
}
