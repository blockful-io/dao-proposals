// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../../contracts/token/interfaces/IERC20.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract Context is Test {
  /// @dev Recipient of token
  address recipient = 0xfE1552DA65FAcAaC5B50b73CEDa4C993e16d4694;

  // Amount of SHU to be sent to the contributor
  uint256 amount = 5;
  uint256 constant decimalsSHU = 10 ** 18;

  /// @dev Shutter Token
  IERC20 ShutterToken = IERC20(0x8CCd277Cc638E7e17F8100cE583cBcEf42007Dca);

  /**
   * @dev Prepares the transactions to be submitted in the proposal.
   * @return transaction The transactions to be executed in the proposal.
   */
  function test_EncodeTransferCall() external view returns (bytes memory) {
   return abi.encodeWithSelector(IERC20.transfer.selector, recipient, amount * decimalsSHU);
  }
}
