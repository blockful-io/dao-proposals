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
import { INewEthRegistrarController } from "@ens/interfaces/INewEthRegistrarController.sol";
import { IArbitrumReverseResolver } from "@ens/interfaces/IArbitrumReverseResolver.sol";
import { IBaseReverseResolver } from "@ens/interfaces/IBaseReverseResolver.sol";
import { ILineaReverseResolver } from "@ens/interfaces/ILineaReverseResolver.sol";
import { IOptimismReverseResolver } from "@ens/interfaces/IOptimismReverseResolver.sol";
import { IScrollReverseResolver } from "@ens/interfaces/IScrollReverseResolver.sol";
import { IDefaultReverseEnsAddr } from "@ens/interfaces/IDefaultReverseEnsAddr.sol";

abstract contract NameResolver {
    function setName(bytes32 node, string memory name) public virtual;
}

contract Proposal_ENS_EP_Enable_ENSIP19_Test is ENS_Governance {
    // Contract addresses - Update with actual addresses
    IENSNewReverseRegistrar newReverseRegistrar = IENSNewReverseRegistrar(0x283F227c4Bd38ecE252C4Ae7ECE650B0e913f1f9);
    INewEthRegistrarController newEthRegistrarController = 
        INewEthRegistrarController(0x59E16fcCd424Cc24e280Be16E11Bcd56fb0CE547);

    IENSRegistryWithFallback ensRegistry = IENSRegistryWithFallback(0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e);
    IENSRegistrar ensRegistrar = IENSRegistrar(0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85);
    IENSReverseRegistrar reverseRegistrar = IENSReverseRegistrar(0xa58E81fe9b61B5c3fE2AFD33CF304c454AbFc7Cb);
    IEthTLDResolver ethTLDResolver = IEthTLDResolver(0x30200E0cb040F38E474E53EF437c95A1bE723b2B);

    IArbitrumReverseResolver arbitrumReverseResolver = 
        IArbitrumReverseResolver(0x4b9572C03AAa8b0Efa4B4b0F0cc0f0992bEDB898);
    IBaseReverseResolver baseReverseResolver = IBaseReverseResolver(0xc800DBc8ff9796E58EfBa2d7b35028DdD1997E5e);
    ILineaReverseResolver lineaReverseResolver = ILineaReverseResolver(0x0Ce08a41bdb10420FB5Cac7Da8CA508EA313aeF8);
    IOptimismReverseResolver optimismReverseResolver = 
        IOptimismReverseResolver(0xF9Edb1A21867aC11b023CE34Abad916D29aBF107);
    IScrollReverseResolver scrollReverseResolver = IScrollReverseResolver(0xd38bf7c18c25AC1b4ce2CC077cbC35b2B97f01e7);

    // Variables
    address newDefaultReverseResolver = 0xA7d635c8de9a58a228AA69353a1699C7Cc240DCF;
    address newPublicResolver = 0xF29100983E058B709F3D539b0c765937B804AC15;
    
    address dnssecEnsAddr = 0x0fc3152971714E5ed7723FAFa650F86A4BaF30C5;
    address rootEnsAddr = 0xaB528d626EC275E3faD363fF1393A41F581c5897;
    IDefaultReverseEnsAddr defaultReverseEnsAddr = IDefaultReverseEnsAddr(0x283F227c4Bd38ecE252C4Ae7ECE650B0e913f1f9);

    // Coin type hex values
    string baseCoinType = bytes4ToHexString(bytes4(uint32(2147492101)));
    string arbitrumCoinType = bytes4ToHexString(bytes4(uint32(2147525809)));
    string scrollCoinType = bytes4ToHexString(bytes4(uint32(2148018000)));
    string optimismCoinType = bytes4ToHexString(bytes4(uint32(2147483658)));
    string lineaCoinType = bytes4ToHexString(bytes4(uint32(2147542792)));

    function _selectFork() public override {
        // TODO: Update with appropriate block number for the proposal
        vm.createSelectFork({ blockNumber: 22_879_171, urlOrAlias: "mainnet" });
    }

    function _proposer() public pure override returns (address) {
        // TODO: Update with actual proposer address
        return 0xe52C39327FF7576bAEc3DBFeF0787bd62dB6d726; // Update with actual proposer
    }

    function _beforeProposal() public view override {
        // check ownership of new contracts deployed
        // newDefaultReverseResolver and newPublicResolver do not have owners
        assertEq(newReverseRegistrar.owner(), address(timelock), "newReverseRegistrar owner is not timelock");
        assertEq(newEthRegistrarController.owner(), address(timelock), "newEthRegistrarController owner is not timelock");
        assertEq(arbitrumReverseResolver.owner(), address(timelock), "arbitrumReverseResolver owner is not timelock");
        assertEq(baseReverseResolver.owner(), address(timelock), "baseReverseResolver owner is not timelock");
        assertEq(lineaReverseResolver.owner(), address(timelock), "lineaReverseResolver owner is not timelock");
        assertEq(optimismReverseResolver.owner(), address(timelock), "optimismReverseResolver owner is not timelock");
        assertEq(scrollReverseResolver.owner(), address(timelock), "scrollReverseResolver owner is not timelock");
        assertEq(defaultReverseEnsAddr.owner(), address(timelock), "defaultReverseEnsAddr owner is not timelock");
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
            newDefaultReverseResolver
        );
        signatures[0] = "";
        
        // 2.1. Set the arbitrum reverse resolver
        assertEq(arbitrumCoinType, "8000a4b1");

        targets[1] = address(ensRegistry);
        values[1] = 0;
        calldatas[1] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash(arbitrumCoinType),
            timelock,
            arbitrumReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[1] = "";
        
        // 2.2. Set the base reverse resolver
        assertEq(baseCoinType, "80002105");

        targets[2] = address(ensRegistry);
        values[2] = 0;
        calldatas[2] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash(baseCoinType),
            timelock,
            baseReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[2] = "";
        
        // 2.3. Set the linea reverse resolver
        assertEq(lineaCoinType, "8000e708");

        targets[3] = address(ensRegistry);
        values[3] = 0;        
        calldatas[3] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash(lineaCoinType),
            timelock,
            lineaReverseResolver,
            3000 // TODO: Check TTL
        );
        signatures[3] = "";
        
        // 2.4. Set the optimism reverse resolver
        assertEq(optimismCoinType, "8000000a");

        targets[4] = address(ensRegistry);
        values[4] = 0;
        calldatas[4] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash(optimismCoinType),
            timelock,
            optimismReverseResolver,
            uint32(3000) // TODO: Check TTL
        );
        signatures[4] = "";
        
        // 2.5. Set the scroll reverse resolver
        assertEq(scrollCoinType, "80082750");

        targets[5] = address(ensRegistry);
        values[5] = 0;
        calldatas[5] = abi.encodeWithSelector(
            IENSRegistryWithFallback.setSubnodeRecord.selector,
            namehash("reverse"),
            labelhash(scrollCoinType),
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
            newEthRegistrarController,
            true
        );
        signatures[8] = "";

        // 6. Set interface ID for INewEthRegistrarController
        bytes4 newEthRegistrarControllerInterfaceId = calculateNewEthRegistrarControllerInterfaceId();
        assertEq(newEthRegistrarControllerInterfaceId, bytes4(0xe4f37f79));
        
        targets[9] = address(ethTLDResolver);
        values[9] = 0;
        calldatas[9] = abi.encodeWithSelector(
            IEthTLDResolver.setInterface.selector,
            namehash("eth"),
            newEthRegistrarControllerInterfaceId,
            newEthRegistrarController
        );
        signatures[9] = "";

        // 7. Set new public resolver as default resolver on the reverse registrar
        targets[10] = address(reverseRegistrar);
        values[10] = 0;
        calldatas[10] = abi.encodeWithSelector(
            IENSReverseRegistrar.setDefaultResolver.selector,
            newPublicResolver
        );
        signatures[10] = "";
        
        // 8.1
        targets[11] = address(reverseRegistrar);
        values[11] = 0;
        calldatas[11] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            dnssecEnsAddr,
            timelock,
            newPublicResolver,
            "dnssec.ens.eth"
        );
        signatures[11] = "";

        // 8.2
        targets[12] = address(reverseRegistrar);
        values[12] = 0;
        calldatas[12] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            ensRegistrar,
            timelock,
            newPublicResolver,
            "registrar.ens.eth"
        );
        signatures[12] = "";

        // 8.3
        targets[13] = address(reverseRegistrar);
        values[13] = 0;
        calldatas[13] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            rootEnsAddr,
            timelock,
            newPublicResolver,
            "root.ens.eth"
        );
        signatures[13] = "";

        // 8.4
        targets[14] = address(reverseRegistrar);
        values[14] = 0;
        calldatas[14] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            newEthRegistrarController,
            timelock,
            newPublicResolver,
            "controller.ens.eth"
        );
        signatures[14] = "";

        // 8.5
        targets[15] = address(reverseRegistrar);
        values[15] = 0;
        calldatas[15] = abi.encodeWithSelector(
            IENSReverseRegistrar.setNameForAddr.selector,
            address(defaultReverseEnsAddr),
            timelock,
            newPublicResolver,
            "default.reverse.ens.eth"
        );
        signatures[15] = "";

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public view override {
        // 1. Verify that the resolver for "reverse" was set to newDefaultReverseResolver
        assertEq(
            ensRegistry.resolver(namehash("reverse")), 
            newDefaultReverseResolver, 
            "Reverse resolver not set correctly"
        );
        
        // 2. Verify that L2 reverse resolvers were set correctly
        assertEq(
            ensRegistry.resolver(keccak256(abi.encodePacked(namehash("reverse"), labelhash(arbitrumCoinType)))), 
            address(arbitrumReverseResolver), 
            "Arbitrum reverse resolver not set"
        );
        assertEq(
            ensRegistry.resolver(keccak256(abi.encodePacked(namehash("reverse"), labelhash(baseCoinType)))), 
            address(baseReverseResolver), 
            "Base reverse resolver not set"
        );
        assertEq(
            ensRegistry.resolver(keccak256(abi.encodePacked(namehash("reverse"), labelhash(lineaCoinType)))), 
            address(lineaReverseResolver), 
            "Linea reverse resolver not set"
        );
        assertEq(
            ensRegistry.resolver(keccak256(abi.encodePacked(namehash("reverse"), labelhash(optimismCoinType)))), 
            address(optimismReverseResolver), 
            "Optimism reverse resolver not set"
        );
        assertEq(
            ensRegistry.resolver(keccak256(abi.encodePacked(namehash("reverse"), labelhash(scrollCoinType)))), 
            address(scrollReverseResolver), 
            "Scroll reverse resolver not set"
        );
        
        // 3. Verify that the new ETH registrar controller was added
        assertTrue(
            ensRegistrar.controllers(address(newEthRegistrarController)), 
            "New ETH registrar controller not added"
        );
        
        // 4. Verify that the new ETH registrar controller was set as controller on reverse registrar
        assertTrue(
            reverseRegistrar.controllers(address(newEthRegistrarController)), 
            "New controller not set on reverse registrar"
        );
        
        // 5. Verify that the new ETH registrar controller was set as controller on new reverse registrar
        assertTrue(
            newReverseRegistrar.controllers(address(newEthRegistrarController)), 
            "New controller not set on new reverse registrar"
        );
        
        // 6. Verify that the interface ID was set correctly for INewEthRegistrarController
        bytes4 expectedInterfaceId = calculateNewEthRegistrarControllerInterfaceId();
        assertEq(
            ethTLDResolver.interfaceImplementer(namehash("eth"), expectedInterfaceId), 
            address(newEthRegistrarController), 
            "Interface ID not set correctly"
        );
        
        // 7. Verify that the new public resolver was set as default resolver
        assertEq(
            reverseRegistrar.defaultResolver(), 
            newPublicResolver, 
            "Default resolver not set correctly"
        );
        
        // 8. Verify that reverse names were set for ENS addresses
        assertEq(
            ensRegistry.resolver(reverseRegistrar.node(dnssecEnsAddr)), 
            newPublicResolver, 
            "DNSSEC reverse name not set"
        );
        assertEq(
            ensRegistry.resolver(reverseRegistrar.node(address(ensRegistrar))), 
            newPublicResolver, 
            "Registrar reverse name not set"
        );
        assertEq(
            ensRegistry.resolver(reverseRegistrar.node(rootEnsAddr)), 
            newPublicResolver, 
            "Root reverse name not set"
        );
        assertEq(
            ensRegistry.resolver(reverseRegistrar.node(address(newEthRegistrarController))), 
            newPublicResolver, 
            "Controller reverse name not set"
        );
        assertEq(
            ensRegistry.resolver(reverseRegistrar.node(address(defaultReverseEnsAddr))), 
            newPublicResolver, 
            "Default reverse name not set"
        );
    }

    function _isProposalSubmitted() public pure override returns (bool) {
        // TODO: Set to true if proposal already exists on-chain, false if it needs to be submitted
        return false; // Update based on proposal status
    }

    function calculateNewEthRegistrarControllerInterfaceId() public pure returns (bytes4) {
        return 
            INewEthRegistrarController.rentPrice.selector ^
            INewEthRegistrarController.available.selector ^
            INewEthRegistrarController.makeCommitment.selector ^
            INewEthRegistrarController.commit.selector ^
            INewEthRegistrarController.register.selector ^
            INewEthRegistrarController.renew.selector;
    }

    function bytes4ToHexString(bytes4 value) public pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory result = new bytes(8);
        
        for (uint256 i = 0; i < 4; i++) {
            result[i * 2] = hexChars[uint8(value[i]) >> 4];
            result[i * 2 + 1] = hexChars[uint8(value[i]) & 0x0f];
        }
        
        return string(result);
    }
}
