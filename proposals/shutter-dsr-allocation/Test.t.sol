// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

// import interfaces
//  governance contract Shutter
//  ERC20 (USDC, DAI)
//  Maker DSR
//  Maker PSM 0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A 0x0A59649758aa4d66E25f08Dd01271e891fe52199

contract FooTest is Test {
    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
    }

    /// @dev Basic test. Run it with `forge test -vvv` to see the console log.
    function test_Example() external view {
        // fork mainnet

        // flow described on task
    }
}
