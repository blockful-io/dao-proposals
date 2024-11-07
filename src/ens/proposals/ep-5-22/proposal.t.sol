// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { ITokenStreamingEP5_22 } from "@ens/interfaces/ITokenStreamingEP5-22.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

// https://www.tally.xyz/gov/ens/proposal/33504840096777976512510989921427323867039135570342563123194157971712476988820

contract Proposal_ENS_EP_5_22_Test is ENS_Governance {
    uint256 timelockUSDCbalanceBefore;
    uint256 expectedUSDCtransfer = 15_075_331_200;
    uint256 timelockUSDCbalanceAfter;
    address streamingContractAdmin = 0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5; // nick.eth
    address receiver = 0x690F0581eCecCf8389c223170778cD9D029606F2; // ENS Labs

    ITokenStreamingEP5_22 streamingContract = ITokenStreamingEP5_22(0x05C8f60e24FcDd9B8Ed7bB85dF8164C41cB4DA16); // stream
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    bytes proposalCalldata = hex"000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000044095ea7b300000000000000000000000005c8f60e24fcdd9b8ed7bb85df8164c41cb4da16ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008a123205b352e32325d205b45584543555441424c452050524f504f53414c5d20454e53763220446576656c6f706d656e742046756e64696e67200a0a5b54656d7020436865636b20446973636f75727365206c696e6b5d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f74656d702d636865636b2d65702d352d32322d656e7376322d646576656c6f706d656e742d66756e64696e672d726571756573742f31393736323f753d6b6174686572696e652e657468290a0a0a202323204465736372697074696f6e200a2323202a2a53756d6d6172792a2a0a0a546869732065786563757461626c652070726f706f73616c207365656b7320746f20696d706c656d656e74207468652072657669736564206275646765742073747265616d20746f20454e53204c61627320646576656c6f702c206d61696e7461696e20616e64206175646974205b454e5376325d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f656e732d6c6162732d646576656c6f706d656e742d70726f706f73616c2d656e7376322d616e642d6e61746976652d6c322d737570706f72742f3139323332292e20546865206d6f7469766174696f6e2c206a757374696669636174696f6e2c2062756467657420627265616b646f776e2c20616e6420646576656c6f706d656e7420706c616e207761732070726576696f75736c792064657461696c656420696e2061205b54656d7020436865636b5d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f74656d702d636865636b2d656e7376322d646576656c6f706d656e742d66756e64696e672d726571756573742f31393736322920726571756573742e200a0a2323202a2a4261636b67726f756e642a2a0a0a57697468206f7665722033206d696c6c696f6e202e657468206e616d657320616e64203230206d696c6c696f6e206d6f726520454e53206e616d6573207265676973746572656420627920746865206c696b6573206f6620436f696e626173652c20556e69737761702c20616e64204c696e656120e2809320454e5320686173206265636f6d6520746865207374616e6461726420666f722077656233206964656e746974792e20417320457468657265756d277320726f61646d61702065766f6c76657320746f7761726473206265696e6720726f6c6c75702d63656e747269632c206974277320657373656e7469616c20666f7220454e5320746f20616461707420696e20706172616c6c656c2c20656e737572696e67206974206d6565747320746865206e65656473206f6620626f74682074686520457468657265756d2065636f73797374656d20616e64206974732075736572732e200a0a546f20636f6e74696e7565207363616c696e6720616e642065766f6c76696e6720454e532c20454e53204c6162732069732072657175657374696e6720616e20696e63726561736520696e2069747320616e6e75616c206275646765742066726f6d2024342e324d205553444320746f2024392e374d20555344432c20616e642061206f6e652d74696d65206772616e7420666f722066757475726520736563757269747920617564697473206f6620454e5376322e205468697320726576697365642066756e64696e67206973206e656365737361727920666f7220454e53204c61627320746f20646576656c6f702c206d61696e7461696e2c20616e6420617564697420454e5376322c2061206d616a6f72207570677261646520746861742077696c6c20656e68616e636520646563656e7472616c697a6174696f6e2c20666c65786962696c6974792c20616e64207363616c6162696c697479206279206c657665726167696e67204c61796572203220736f6c7574696f6e7320616e6420726564657369676e696e672074686520454e532070726f746f636f6c2066726f6d207468652067726f756e642075702e0a0a232323202a2a4c696e6b732a2a0a0a2a205b5c5b54656d7020436865636b5c5d20454e53763220446576656c6f706d656e742046756e64696e6720526571756573745d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f74656d702d636865636b2d656e7376322d646576656c6f706d656e742d66756e64696e672d726571756573742f31393736322920200a2a205b454e53204c61627320646576656c6f706d656e742070726f706f73616c3a20454e53763220616e64206e6174697665204c3220737570706f72745d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f656e732d6c6162732d646576656c6f706d656e742d70726f706f73616c2d656e7376322d616e642d6e61746976652d6c322d737570706f72742f3139323332290a2a205b454e53204c616273205472616e73706172656e6379205265706f7274735d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f656e732d6c6162732d7472616e73706172656e63792d7265706f7274732f3139383036290a0a2323202a2a53706563696669636174696f6e2a2a0a0a546869732065786563757461626c652070726f706f73616c2077696c6c20696e6974696174652061206e6577206461696c792073747265616d206f662031352c3037352e333320555344432066726f6d2074686520454e532044414f20747265617375727920746f20454e53204c6162732c207374617274696e67206f6e204a616e7561727920312c20323032355c2e20546869732077696c6c2072756e20696e206164646974696f6e20746f20746865206578697374696e672073747265616d696e6720636f6e7472616374206f662031312c35303020555344432f646179206174203078423133373765346633326536373436343434393730383233443535303646393866354130343230312c20666f72206120746f74616c206f662032362c3537352e333420555344432f646179202824392e374d20555344432f79656172292e00000000000000000000000000000000000000000000000000000000000000";

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_086_802, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0xE3919F3f971C4589089DaA930aaFa81B8A27b406;
    }

    function _beforeExecution() public override {
        timelockUSDCbalanceBefore = USDC.balanceOf(address(timelock));
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
        (targets, values, calldatas, description) =
            abi.decode(proposalCalldata, (address[], uint256[], bytes[], string));
        
        uint256 items = 1;

        targets = new address[](items);
        targets[0] = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

        values = new uint256[](items);
        values[0] = 0;

        calldatas = new bytes[](items);
        calldatas[0] =
            hex"095ea7b300000000000000000000000005c8f60e24fcdd9b8ed7bb85df8164c41cb4da16ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";

        bytes memory expectedCalldata0 =
            abi.encodeWithSelector(USDC.approve.selector, address(streamingContract), type(uint256).max);

        // @TODO: Compare proposal calldata with expected calldata
        assertEq(calldatas[0], expectedCalldata0);

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public override {
        console2.log("Claimable balance", streamingContract.claimableBalance());
        console2.log("Total claimed", streamingContract.totalClaimed());

        vm.warp(streamingContract.startTime() + 1 days);

        console2.log("Claimable balance before claim", streamingContract.claimableBalance());

        vm.startPrank(streamingContractAdmin);
        streamingContract.claim(receiver, streamingContract.claimableBalance());
        vm.stopPrank();

        console2.log("Claimable balance after claim", streamingContract.claimableBalance());
        console2.log("Total claimed", streamingContract.totalClaimed());

        timelockUSDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(timelockUSDCbalanceBefore, timelockUSDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(timelockUSDCbalanceAfter, timelockUSDCbalanceBefore);
    }
}
