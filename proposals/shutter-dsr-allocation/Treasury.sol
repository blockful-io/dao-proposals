// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "./Interfaces.sol";

contract Multicall {
  function multicall(
    address[] memory targets,
    bytes[] calldata data
  ) external virtual returns (bytes[] memory results) {
    results = new bytes[](data.length);
    for (uint256 i = 0; i < data.length; i++) {
      (bool success, bytes memory result) = targets[i].call(data[i]);
      require(success, "DelegateCall Failed");
      results[i] = result;
    }
    return results;
  }
}

contract Treasury is Multicall {}
