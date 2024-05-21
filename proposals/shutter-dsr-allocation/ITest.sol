// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IERC20 {
  function approve(address spender, uint256 value) external;

  function balanceOf(address account) external view returns (uint256);
}

interface IDssPsm {
  function sellGem(address usr, uint256 gemAmt) external;
}

interface IDaiJoin {
  function join(address usr, uint256 wad) external;
}

interface IVat {
  function hope(address usr) external;
}

interface IPot {
  function drip() external returns (uint256);

  function join(uint256 wad) external;
}
