// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../interfaces/Dai/IDssPsm.sol";
import "../interfaces/Dai/ISavingsDai.sol";
import "../interfaces/ERC20/IERC20.sol";

import "./utils/Context.sol";
import { Treasury } from "../contracts/Treasury.sol";

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

contract TestCalldataSimulation is Test, Context {
  /// @dev Multical contract to execute multiple calls in one transaction
  Treasury treasury = new Treasury();

  /// @dev A function invoked before each test case is run.
  function setUp() public virtual {
    vm.startPrank(Alice);
  }

  /**
   * @dev Tests the entire process of depositing USDC in the DSR contract but
   * using the Treasury contract as a simulation of the Shutter DAO Gnosis contract.
   *
   * The test will:
   * 1. Encode the calldata for the USDC approval.
   * 2. Encode the calldata for the USDC swap on PSM for DAI.
   * 3. Encode the calldata for the DAI approval.
   * 4. Encode the calldata for the DAI deposit.
   * 5. Execute the encoded calls via multicall in the treasury contract.
   */
  function test_calldataUsdcToSDR() external {
    // Deploy the treasury contract to simulate the Gnosis without governance
    treasury = new Treasury();
    USDC.transfer(address(treasury), amount * decimalsUSDC);

    // Encode the calldata for the USDC approval
    bytes memory approveUSDC = abi.encodeWithSelector(IERC20.approve.selector, AuthGemJoin5, amount * decimalsUSDC);
    // Encode the calldata for the USDC swap on PSM for DAI
    bytes memory sellGem = abi.encodeWithSelector(DssPsm.sellGem.selector, address(treasury), amount * decimalsUSDC);
    // Encode the calldata for the DAI approval
    bytes memory approveDAI = abi.encodeWithSelector(
      IERC20.approve.selector,
      address(SavingsDai),
      amount * decimalsDAI
    );
    // Encode the calldata for the DAI deposit
    bytes memory deposit = abi.encodeWithSelector(SavingsDai.deposit.selector, amount * decimalsDAI, address(treasury));

    // Aggregate the addresses
    address[] memory targets = new address[](4);
    targets[0] = address(USDC);
    targets[1] = address(DssPsm);
    targets[2] = address(DAI);
    targets[3] = address(SavingsDai);

    // Aggregate the calls
    bytes[] memory calls = new bytes[](4);
    calls[0] = approveUSDC;
    calls[1] = sellGem;
    calls[2] = approveDAI;
    calls[3] = deposit;

    // Submit the encoded calls to the treasury contract which will invoke them
    bytes[] memory results = new bytes[](4);
    results = treasury.multicall(targets, calls);
    // Check if the SavingsDai balance was received by the treasury
    assert(abi.decode(results[3], (uint256)) == SavingsDai.balanceOf(address(treasury)));
  }
}
