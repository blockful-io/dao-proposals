// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { console2 } from "@forge-std/src/console2.sol";

import { UNI_Governance } from "@uniswap/uniswap.t.sol";

contract Proposal_UNI_Test is UNI_Governance {
    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 20_836_390, urlOrAlias: "mainnet" });
    }

    function _beforePropose() public override { }

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
        targets = new address[](1);
        targets[0] = address(uniToken);

        values = new uint256[](1);
        values[0] = 0;

        signatures = new string[](1);
        signatures[0] = "transfer(address,uint256)";

        calldatas = new bytes[](1);
        calldatas[0] = abi.encodePacked(address(0xe571dC7A558bb6D68FfE264c3d7BB98B0C6C73fC), uint256(1_000_000e18));
    }

    function _afterExecution() public override { }
}
