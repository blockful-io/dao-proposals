// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IERC20 {
  function approve(address spender, uint256 value) external;

  function allowance(address owner, address spender) external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IDssPsm {
  function sellGem(address usr, uint256 gemAmt) external;
}

interface IDaiJoin {
  function join(address usr, uint256 wad) external;

  function exit(address usr, uint256 wad) external;
}

interface IVat {
  function dai(address usr) external returns (uint256);

  function hope(address usr) external;

  function can(address bit, address usr) external returns (uint);
}

interface IPot {
  function pie(address usr) external returns (uint256);

  function drip() external returns (uint256);

  function chi() external returns (uint256);

  function join(uint256 wad) external;

  function exit(uint256 wad) external;
}

interface ISavingsDai {
  function previewDeposit(uint256 assets) external view returns (uint256);

  function deposit(uint256 assets, address receiver) external returns (uint256 shares);

  function balanceOf(address account) external view returns (uint256);
}
