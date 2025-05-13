// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";
import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_6_2_Test is ENS_Governance {
    uint256 USDCbalanceBefore;
    uint256 ENSbalanceBefore;
    uint256 expectedUSDCtransfer = (589_000 + 356_000) * 10 ** 6;
    uint256 expectedENStransfer = 100_000 ether;

    IERC20 public usdcToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function _proposer() public pure override returns (address) {
        return 0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726; // 5pence.eth
    }

    function _beforeExecution() public override {
        USDCbalanceBefore = usdcToken.balanceOf(address(timelock));
        ENSbalanceBefore = ensToken.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (address[] memory, uint256[] memory, string[] memory, bytes[] memory, string memory)
    {
        address[] memory targets = new address[](3);
        targets[0] = address(usdcToken);
        targets[1] = address(ensToken);
        targets[2] = address(usdcToken);
        bytes[] memory calldatas = new bytes[](3);

        calldatas[0] = abi.encodeWithSelector(
            IERC20.transfer.selector, 0x91c32893216dE3eA0a55ABb9851f581d4503d39b, 589_000 * 10 ** 6
        );
        calldatas[1] = abi.encodeWithSelector(
            IERC20.transfer.selector, 0x91c32893216dE3eA0a55ABb9851f581d4503d39b, expectedENStransfer
        );
        calldatas[2] = abi.encodeWithSelector(
            IERC20.transfer.selector, 0xcD42b4c4D102cc22864e3A1341Bb0529c17fD87d, 356_000 * 10 ** 6
        );

        return (targets, new uint256[](3), new string[](1), calldatas, "");
    }

    function _afterExecution() public view override {
        uint256 USDCbalanceAfter = usdcToken.balanceOf(address(timelock));
        assertEq(USDCbalanceAfter, USDCbalanceBefore - expectedUSDCtransfer);

        uint256 ENSbalanceAfter = ensToken.balanceOf(address(timelock));
        assertEq(ENSbalanceAfter, ENSbalanceBefore - expectedENStransfer);
    }

    function _isProposalSubmitted() public pure override returns (bool) {
        return false;
    }
}
