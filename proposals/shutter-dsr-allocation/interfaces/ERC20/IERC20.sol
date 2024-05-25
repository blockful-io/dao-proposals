// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IERC20 {
  function approve(address spender, uint256 value) external;

  function allowance(address owner, address spender) external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);
}
