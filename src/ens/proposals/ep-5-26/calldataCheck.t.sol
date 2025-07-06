// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_26_Test is ENS_Governance {
    IERC20 ENS = IERC20(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);

    uint256 ENSbalanceBefore;
    uint256 ENSbalanceAfter;
    uint256 metagovExpectedENStransfer = 30_000 * 10 ** 18; // ENS decimals

    address metagovMultisig = 0x91c32893216dE3eA0a55ABb9851f581d4503d39b;

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_130_700, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726;
    }

    function _beforeProposal() public override {
        ENSbalanceBefore = ENS.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (
            address[] memory,
            uint256[] memory,
            string[] memory,
            bytes[] memory,
            string memory
        )
    {
        uint256 items = 1;

        targets = new address[](items);
        targets[0] = address(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);

        values = new uint256[](items);
        values[0] = 0;

        calldatas = new bytes[](items);
        calldatas[0] =
            hex"a9059cbb00000000000000000000000091c32893216de3ea0a55abb9851f581d4503d39b00000000000000000000000000000000000000000000065a4da25d3016c00000";
        bytes memory expectedENSCalldata0 =
            abi.encodeWithSelector(IERC20.transfer.selector, metagovMultisig, metagovExpectedENStransfer);

        assertEq(calldatas[0], expectedENSCalldata0);

        return (targets, values, signatures, calldatas, "");
    }

    function _afterExecution() public override {
        ENSbalanceAfter = ENS.balanceOf(address(timelock));
        assertEq(
            ENSbalanceBefore,
            ENSbalanceAfter + metagovExpectedENStransfer
        );
        assertNotEq(ENSbalanceAfter, ENSbalanceBefore);
    }

    function _isProposalSubmitted() public view override returns (bool) {
        return false;
    }
}
