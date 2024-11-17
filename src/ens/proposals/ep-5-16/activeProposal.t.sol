// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_16_Test is ENS_Governance {
    uint256 USDCbalanceBefore;
    uint256 expectedUSDCtransfer = 1_218_669_760_000;
    uint256 USDCbalanceAfter;
    address receiver = 0x690F0581eCecCf8389c223170778cD9D029606F2; // ENS Labs

    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    bytes proposalCalldata = hex"000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000044a9059cbb000000000000000000000000690f0581ececcf8389c223170778cd9d029606f20000000000000000000000000000000000000000000000000000011bbe60ce00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bac23205b455020352e31365d205b45786563757461626c655d205265696d62757273656d656e74206f6620454e53204c616273e28099206c6567616c206665657320696e206574682e6c696e6b206c697469676174696f6e0a0a5b54656d7020436865636b20446973636f75727365206c696e6b5d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f65702d352d782d65786563757461626c652d7265696d62757273656d656e742d6f662d656e732d6c6162732d6c6567616c2d666565732d696e2d6574682d6c696e6b2d6c697469676174696f6e2f3139363133290a0a0a202323204465736372697074696f6e200a23232053756d6d6172790a546869732065786563757461626c652070726f706f73616c207365656b7320746f20696d706c656d656e7420746865207265696d62757273656d656e74207061796d656e7420746f20454e53204c61627320666f7220746865206c6567616c206665657320696e637572726564207768696c65207075727375696e67206c697469676174696f6e20746f2070726f7465637420746865206574682e6c696e6b20646f6d61696e2e20546865207265696d62757273656d656e742077617320617070726f76656420696e207468652070726576696f75736c792070617373656420736f6369616c2070726f706f73616c205b455020352e335d2868747470733a2f2f646f63732e656e732e646f6d61696e732f64616f2f70726f706f73616c732f352e33292e0a0a2323204261636b67726f756e640a546865206c617773756974207468617420454e532066696c656420696e206665646572616c20646973747269637420636f75727420696e204172697a6f6e6120746f206d61696e7461696e206f776e65727368697020616e6420636f6e74726f6c206f766572206574682e6c696e6b20686173206265656e207265736f6c7665642c20616e64206f6e2032362041756775737420323032342c2074686520436f757274206f6666696369616c6c7920636c6f736564207468697320636173652e20200a454e53204c61627320686173206d61696e7461696e65642066756c6c206f776e65727368697020616e6420636f6e74726f6c206f76657220746865206574682e6c696e6b20646f6d61696e20616e642c207468657265666f72652c20454e53204c616273206861732061636869657665642074686520696e697469616c206f626a656374697665207468657920686164207768656e2066697273742066696c696e672074686520636f6d706c61696e7420616e64206f627461696e696e6720696e6a756e63746976652072656c6965662e2020546f2072656163682074686973206f7574636f6d652c20454e53204c61627320686173207370656e7420696e20746f74616c20312c3231382c3636392e3736205553442e200a54686973206c6567616c20616374696f6e20776173206e656365737361727920746f20646566656e642074686520454e532065636f73797374656d20616e64206d61696e7461696e20636f6e74726f6c206f6620746865206574682e6c696e6b20646f6d61696e2c206120637269746963616c20696e66726173747275637475726520636f6d706f6e656e742073696e636520323031372e0a0a232323204c696e6b730a2d205b455020352e3320536e617073686f7420566f74655d2868747470733a2f2f736e617073686f742e6f72672f232f656e732e6574682f70726f706f73616c2f307834353663636234333865656435643138396362653531653565333661383864326262346463306336316631326636643965333130613762613437393864356663290a2d205b466f72756d2044697363757373696f6e206f6e20455020352e335d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f6570352d322d736f6369616c2d64657465726d696e652d656e732d6c6162732d6e6578742d73746570732d696e2d6574682d6c696e6b2d6c697469676174696f6e2f3138373536290a0a23232053706563696669636174696f6e0a546869732065786563757461626c652070726f706f73616c2077696c6c20696e6974696174652061207472616e73666572206f6620312c3231382c3636392e373620555344432066726f6d2074686520454e532044414f20747265617375727920746f20454e53204c6162732e205468697320616d6f756e7420726570726573656e7473207468652066696e616c20746f74616c206f6620616c6c206c6567616c20657870656e7365732072656c6174656420746f20746865206574682e6c696e6b206c697469676174696f6e2e0a0a232323205472616e73616374696f6e2044657461696c730a2d202a2a46726f6d3a2a2a20454e532044414f2054726561737572792028307846653839636337614242324334313833363833616237313635334334636463394230324434346237290a2d202a2a546f3a2a2a205553444320546f6b656e20436f6e74726163742028307841306238363939316336323138623336633164313944346132653945623063453336303665423438290a2d202a2a526563697069656e743a2a2a20454e53204c6162732028307836393046303538316543656343663833383963323233313730373738634439443032393630364632290a2d202a2a416d6f756e743a2a2a20312c3231382c3636392e3736205553444320283132313836363937363030303020636f6e7369646572696e6720555344432773203620646563696d616c20706c61636573290a2d202a2a507572706f73653a2a2a205265696d62757273656d656e7420666f72206c6567616c206665657320696e206574682e6c696e6b206c697469676174696f6e0a0a0a0a54686973207472616e73616374696f6e2063616c6c732074686520607472616e73666572602066756e6374696f6e206f6620746865205553444320636f6e74726163742c207472616e7366657272696e6720312c3231382c3636392e3736205553444320746f20454e53204c6162732720616464726573732e0a0a232320526174696f6e616c650a54686520454e5320636f6d6d756e6974792c207468726f756768207468652070617373616765206f6620455020352e332c206861732064656d6f6e737472617465642069747320737570706f727420666f72207265696d62757273696e6720454e53204c61627320666f7220746865206c6567616c20657870656e73657320696e63757272656420696e2070726f74656374696e6720746865206574682e6c696e6b20646f6d61696e2e2054686973207265696d62757273656d656e742061636b6e6f776c656467657320746865206566666f727473206d61646520627920454e53204c61627320746f20736166656775617264206120637269746963616c206173736574206f662074686520454e532065636f73797374656d2e20497420656e73757265732074686174207468652066696e616e6369616c2062757264656e206f662074686973206c6567616c20616374696f6e20646f6573206e6f742066616c6c20736f6c656c79206f6e20454e53204c6162732c20706172746963756c61726c7920676976656e207468617420746865697220616374696f6e7320776572652074616b656e20746f2062656e656669742074686520656e7469726520454e5320636f6d6d756e6974792e0a0a0a0a2d2d2d0a0a0a0a2a4e6f7465202d205768656e20746865206f7269676e616c20736e617073686f7420666f722074686520736f6369616c20766f74652077617320706f7374656420697420776173206e756d626572656420617320352e322c206275742069742073686f756c642068617665206265656e20352e332e2020497420686173206265656e2072656e756d626572656420696e20746865206f6666696369616c20454e5320646f63756d656e746174696f6e2e2020536f6d65206c696e6b7320706f696e7420746f20666f72756d2064697363757373696f6e7320616e6420536e617073686f747320746861742073686f7720746865206f726967696e616c206475706c69636974697665206c6162656c206f6620352e322a0000000000000000000000000000000000000000";

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 20_828_677, urlOrAlias: "mainnet" });
    }

    function _proposer() public pure override returns (address) {
        return 0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5;
    }

    function _beforeExecution() public override {
        USDCbalanceBefore = USDC.balanceOf(address(timelock));
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
        (targets, values, calldatas, description) =
            abi.decode(proposalCalldata, (address[], uint256[], bytes[], string));

        bytes[] memory internalCalldatas = new bytes[](1);
        internalCalldatas[0] = abi.encodeWithSelector(USDC.transfer.selector, receiver, expectedUSDCtransfer);

        bytes memory expectedCalldata = abi.encode(
            targets,
            values,
            internalCalldatas,
            description
        );

        assertEq(calldatas, internalCalldatas);
        assertEq(proposalCalldata, expectedCalldata);

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public override {
        USDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(USDCbalanceBefore, USDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(USDCbalanceAfter, USDCbalanceBefore);
    }

    function _isProposalSubmitted() public view override returns (bool) {
        return true;
    }
}
