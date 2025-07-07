// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { ENS_Governance } from "@ens/ens.t.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";
import { IENSRegistryWithFallback } from "@ens/interfaces/IENSRegistryWithFallback.sol";
import { IENSRegistrar } from "@ens/interfaces/IENSRegistrar.sol";
import { IENSReverseRegistrar } from "@ens/interfaces/IENSReverseRegistrar.sol";
import { IENSNewReverseRegistrar } from "@ens/interfaces/IENSNewReverseRegistrar.sol";
import { IEthTLDResolver } from "@ens/interfaces/IEthTLDResolver.sol";

contract Proposal_ENS_EP_Enable_L2_Test is ENS_Governance {
    // Contract addresses - Update with actual addresses
    IENSRegistryWithFallback ensRegistry = IENSRegistryWithFallback(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    IENSRegistrar ensRegistrar = IENSRegistrar(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);
    IENSReverseRegistrar reverseRegistrar = IENSReverseRegistrar(0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb);
    IENSNewReverseRegistrar newReverseRegistrar = IENSNewReverseRegistrar(0xA7d635c8de9a58a228AA69353a1699C7Cc240DCF);
    IEthTLDResolver ethTLDResolver = IEthTLDResolver(0x30200E0cb040F38E474E53EF437c95A1bE723b2B);

    // Variables
    address arbitrumReverseResolver = 0x4b9572C03AAa8b0Efa4B4b0F0cc0f0992bEDB898;
    address baseReverseResolver = 0xc800DBc8ff9796E58EfBa2d7b35028DdD1997E5e;
    address lineaReverseResolver = 0x0Ce08a41bdb10420FB5Cac7Da8CA508EA313aeF8;
    address optimismReverseResolver = 0xF9Edb1A21867aC11b023CE34Abad916D29aBF107;
    address scrollReverseResolver = 0xd38bf7c18c25AC1b4ce2CC077cbC35b2B97f01e7;
    address newEthRegistrarController = 0x59E16fcCd424Cc24e280Be16E11Bcd56fb0CE547;
    address newPublicResolver = 0xF29100983E058B709F3D539b0c765937B804AC15;

    // Configuration parameters - Update with actual values

    // State variables for before/after comparison
    
    // TODO: Replace this with actual proposal calldata

    function _selectFork() public override {
        // TODO: Update with appropriate block number for the proposal
        vm.createSelectFork({ blockNumber: 22_000_000, urlOrAlias: "mainnet" });
    }

    function _proposer() public pure override returns (address) {
        // TODO: Update with actual proposer address
        return 0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726; // Update with actual proposer
    }

    function _beforeProposal() public override {
        // TODO: Capture initial state before execution
        // TODO: validate ownership of new contracts deployed
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
        // TODO: Update with actual proposal description
        uint256 numTransactions = 16;

        targets = new address[](numTransactions);
        values = new uint256[](numTransactions);
        calldatas = new bytes[](numTransactions);
        signatures = new string[](numTransactions);

        // 1. Set the new default reverse resolver
        targets[0] = address(ensRegistry);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setResolver.selector,
            namehash("reverse"),
            newReverseRegistrar
        );
        signatures[0] = "";
        
        // 2.1. Set the arbitrum reverse resolver
        // TODO: Check cointype hex
        targets[1] = address(ensRegistry);
        values[1] = 0;
        calldatas[1] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash("8000a4b1"),
            timelock,
            arbitrumReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[1] = "";
        
        // 2.2. Set the base reverse resolver
        targets[2] = address(ensRegistry);
        values[2] = 0;
        calldatas[2] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash("80002105"),
            timelock,
            baseReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[2] = "";
        
        // 2.3. Set the linea reverse resolver
        targets[3] = address(ensRegistry);
        values[3] = 0;
        calldatas[3] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash("8000e708"),
            timelock,
            lineaReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[3] = "";
        
        // 2.4. Set the optimism reverse resolver
        targets[4] = address(ensRegistry);
        values[4] = 0;
        calldatas[4] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash("8000000a"),
            timelock,
            optimismReverseResolver,
            uint32(3000) // TODO: Check TTL
        );
        signatures[4] = "";
        
        // 2.5. Set the scroll reverse resolver
        targets[5] = address(ensRegistry);
        values[5] = 0;
        calldatas[5] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash("80082750"),
            timelock,
            scrollReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[5] = "";
        
        // 3. Add new controller to the ETH registrar
        targets[6] = address(ensRegistrar);
        values[6] = 0;
        calldatas[6] = abi.encodeWithSelector(
            IENSRegistrar.addController.selector,
            newEthRegistrarController
        );
        signatures[6] = "";
        
        // 4. Set new .eth registrar as controller on the reverse registrar
        targets[7] = address(reverseRegistrar);
        values[7] = 0;
        calldatas[7] = abi.encodeWithSelector(
            IENSReverseRegistrar.setController.selector,
            newEthRegistrarController,
            true
        );
        signatures[7] = "";

        // 5. Set new .eth registrar as controller on the new reverse registrar
        targets[8] = address(newReverseRegistrar);
        values[8] = 0;
        calldatas[8] = abi.encodeWithSelector(
            IENSNewReverseRegistrar.setController.selector,
            newEthRegistrarController
        );
        signatures[8] = "";

        // 6. TODO 
        // TODO: Check interfaceID hex
        targets[9] = address(ethTLDResolver);
        values[9] = 0;
        calldatas[9] = abi.encodeWithSelector(
            IEthTLDResolver.setInterface.selector,
            namehash("eth"),
            0xe4f37f79,
            newEthRegistrarController
        );
        signatures[9] = "";

        // 7.
        targets[10] = address(reverseRegistrar);
        values[10] = 0;
        calldatas[10] = abi.encodeWithSelector(
            IENSReverseRegistrar.setDefaultResolver.selector,
            newPublicResolver
        );
        signatures[10] = "";

 
        console2.log("namehash('dnssec.ens.eth'):");
        console2.logBytes32(namehash(bytes("dnssec.ens.eth")));
        
        // 8.1 Set name for dnssec.ens.eth
        targets[11] = address(reverseRegistrar);
        values[11] = 0;
        calldatas[11] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            0x0fc3152971714E5ed7723FAFa650F86A4BaF30C5,
            timelock,
            newPublicResolver,
            "dnssec.ens.eth"
        );
        signatures[11] = "";

        // 8.2 Set name for registrar.ens.eth
        targets[12] = address(reverseRegistrar);
        values[12] = 0;
        calldatas[12] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85,
            timelock,
            newPublicResolver,
            "registrar.ens.eth"
        );
        signatures[12] = "";

        // 8.3 Set name for root.ens.eth
        targets[13] = address(reverseRegistrar);
        values[13] = 0;
        calldatas[13] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            0xaB528d626EC275E3faD363fF1393A41F581c5897,
            timelock,
            newPublicResolver,
            "root.ens.eth"
        );
        signatures[13] = "";

        // 8.4 Set name for controller.ens.eth
        targets[14] = address(reverseRegistrar);
        values[14] = 0;
        calldatas[14] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            0x59E16fcCd424Cc24e280Be16E11Bcd56fb0CE547,
            timelock,
            newPublicResolver,
            "controller.ens.eth"
        );
        signatures[14] = "";

        // 8.5 Set name for default.reverse.ens.eth
        targets[15] = address(reverseRegistrar);
        values[15] = 0;
        calldatas[15] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            0x283F227c4Bd38ecE252C4Ae7ECE650B0e913f1f9,
            timelock,
            newPublicResolver,
            "default.reverse.ens.eth"
        );
        signatures[15] = "";

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public override {
        // TODO: Validate changes after execution
    }

    function _isProposalSubmitted() public pure override returns (bool) {
        // TODO: Set to true if proposal already exists on-chain, false if it needs to be submitted
        return false; // Update based on proposal status
    }
}
