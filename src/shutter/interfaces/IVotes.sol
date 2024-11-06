// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IVotes {
  function delegate(address delegatee) external;

  function delegates(address account) external view returns (address);
}
