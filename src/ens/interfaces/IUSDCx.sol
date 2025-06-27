// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IUSDCx {
    function upgrade(uint256 amount) external;
    function downgrade(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}
