// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_23_Test is ENS_Governance {
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 ENS = IERC20(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);

    uint256 USDCbalanceBefore;
    uint256 expectedUSDCtransfer = 100_000 * 10 ** 6; // USDC decimals
    uint256 USDCbalanceAfter;

    uint256 ENSbalanceBefore;
    uint256 expectedENStransfer = 15_000 * 10 ** 18; // ENS decimals
    uint256 ENSbalanceAfter;

    address receiver = 0x91c32893216dE3eA0a55ABb9851f581d4503d39b;

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_089_400, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0x76A6D08b82034b397E7e09dAe4377C18F132BbB8;
    }

    function _beforeExecution() public override {
        USDCbalanceBefore = USDC.balanceOf(address(timelock));
        ENSbalanceBefore = ENS.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        )
    {
        uint256 items = 2;

        targets = new address[](items);
        targets[0] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        targets[1] = address(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);

        values = new uint256[](items);
        values[0] = 0;
        values[1] = 0;

        calldatas = new bytes[](items);
        calldatas[0] =
            hex"a9059cbb00000000000000000000000091c32893216de3ea0a55abb9851f581d4503d39b000000000000000000000000000000000000000000000000000000174876e800";
        calldatas[1] =
            hex"a9059cbb00000000000000000000000091c32893216de3ea0a55abb9851f581d4503d39b00000000000000000000000000000000000000000000032d26d12e980b600000";

        bytes memory expectedUSDCCalldata =
            abi.encodeWithSelector(IERC20.transfer.selector, receiver, expectedUSDCtransfer);
        assertEq(calldatas[0], expectedUSDCCalldata);

        bytes memory expectedENSCalldata =
            abi.encodeWithSelector(IERC20.transfer.selector, receiver, expectedENStransfer);
        assertEq(calldatas[1], expectedENSCalldata);

        return (targets, values, signatures, calldatas, "");
    }

    function _afterExecution() public override {
        USDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(USDCbalanceBefore, USDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(USDCbalanceAfter, USDCbalanceBefore);

        ENSbalanceAfter = ENS.balanceOf(address(timelock));
        assertEq(ENSbalanceBefore, ENSbalanceAfter + expectedENStransfer);
        assertNotEq(ENSbalanceAfter, ENSbalanceBefore);
    }

    function _isProposalSubmitted() public view override returns (bool) {
        return true;
    }
}
