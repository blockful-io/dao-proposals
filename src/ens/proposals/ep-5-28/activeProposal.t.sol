// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IToken } from "@ens/interfaces/IToken.sol";
import { IGovernor } from "@ens/interfaces/IGovernor.sol";
import { ITimelock } from "@ens/interfaces/ITimelock.sol";
import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_28_Test is ENS_Governance {
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    uint256 USDCbalanceBefore;
    uint256 expectedUSDCtransfer = 240_632_380_000; // $240,632.38
    uint256 USDCbalanceAfter;

    address receiver = 0xB352bB4E2A4f27683435f153A259f1B207218b1b;

    bytes proposalCalldata =
        hex"000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000001c00000000000000000000000000000000000000000000000000000000000000001000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb4800000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000044a9059cbb000000000000000000000000b352bb4e2a4f27683435f153a259f1b207218b1b0000000000000000000000000000000000000000000000000000003806ceba6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000134c23205b455020352e32385d205b45786563757461626c655d205265696d62757273656d656e74206f66206574682e6c696d6fe2809973206f6e676f696e67206c6567616c20666565730a0a0a0a202323204465736372697074696f6e200a2323232053756d6d6172790a0a546869732070726f706f73616c2061696d7320746f207265696d6275727365206574682e6c696d6f20666f72206f6e676f696e67206c6567616c20666565732072656c6174656420746f20746865206f7065726174696f6e206f6620746865206574682e6c696d6f2f6574682e6c696e6b20676174657761792073657276696365732e0a0a232323204261636b67726f756e640a0a232323205468652048756d616e20436f737473206f66205075626c696320476f6f64730a0a4174206574682e6c696d6f20776520636f6e74696e756f75736c792073747269766520746f2064656c6976657220612068696768207175616c69747920454e53206761746577617920657870657269656e63652e20576520756e6465727374616e642074686520637269746963616c207574696c6974792074686174206f757220736572766963652070726f766964657320616e6420776520686176652064656469636174656420636f756e746c65737320686f75727320746f20646576656c6f70696e6720616e64206d61696e7461696e696e6720746865206761746577617920696e667261737472756374757265207468617420706f776572732074686f7573616e6473206f6620644170707320616e642064576562736974657320616c696b652e0a0a537065616b696e67206265796f6e6420707572656c7920746563686e6963616c20726571756972656d656e74732c206f6e6520617370656374206f66206f7065726174696e67206574682e6c696d6f2074686174206973206f6674656e206f7665726c6f6f6b6564206973207468652068756d616e20636f73742e20576520617265206120736d616c6c207465616d2077697468206c696d69746564207265736f75726365732077686f20617265206465646963617465642032342f3720746f20656e73757265207468617420776520726573706f6e6420746f20737570706f727420726571756573747320696e20612074696d656c792066617368696f6e2c20776f726b2077697468206f746865722063757474696e6720656467652065636f73797374656d2070726f6a6563747320666f7220696e746567726174696f6e732c20616e642070726f76696465206f6e2d63616c6c20617661696c6162696c69747920666f7220616e79207365727665722d73696465206973737565732074686174206d696768742061726973652e20496e206164646974696f6e2c2077652061726520636f6e7374616e746c792068616e646c696e6720616275736520636f6d706c61696e747320616e64206f74686572206d6174746572732074686174206f6674656e20676f20756e6d656e74696f6e65642e0a0a57652062656c6965766520696e207075626c696320676f6f647320616e6420746865207574696c69747920746865792070726f766964652c20776869636820697320776879207765206861766520736163726966696365642074696d65207769746820667269656e647320616e642066616d696c7920696e206f7264657220746f2066756c66696c206f7572206f626c69676174696f6e7320746f2074686520454e5320616e642062726f61646572205765623320636f6d6d756e697469657320627920636f6e7374616e746c7920776f726b696e6720746f20656e73757265206120737461626c6520616e6420617661696c61626c65207573657220657870657269656e63652e0a0a23232320546865204c6567616c20436f737473206f66205075626c696320476f6f64730a0a4f7065726174696e67207075626c696320696e66726173747275637475726520636f6d65732077697468206120756e6971756520736574206f66206368616c6c656e6765732c206d616e79206f662077686963682077652077657265206e6f7420657870656374696e672c207375636820617320656e666f7263656d656e7420616e6420646973707574652d72656c61746564206c6567616c20666565732e204265696e67206f6e207468652066726f6e746c696e6573206f66206272696467696e67205765623220e286922057656233206d65616e73207468617420776520617265206f6674656e2074686520666972737420706f696e74206f6620636f6e7461637420666f72206c617720656e666f7263656d656e742c20616275736520636f6d706c61696e74732c20616e64206c6567616c20616e6420726567756c61746f72792072657175657374732e204173206f6e652063616e20696d6167696e652c207468697320717569636b6c7920626567696e7320746f2074616b65206120746f6c6c206f6e206f75722066696e616e6369616c207265736f757263657320616e64206d656e74616c206865616c74682e0a0a41742070726573656e742c206574682e6c696d6f20686173206265656e206c61626f7572696e6720756e646572205553206665646572616c2072657175657374732c20617320612074686972642d70617274792c2074686174206861732064726167676564206f6e20666f72206d6f6e74687320616e642077696c6c206c696b656c7920636f6e74696e756520746f20646f20736f2077656c6c20696e746f20323032352e205765206172652063757272656e746c7920756e61626c6520746f2070726f7669646520667572746865722064657461696c7320726567617264696e6720746865206e6174757265206f662074686973206d61747465722c20627574207265737420617373757265642c20617320736f6f6e20617320776520617265207065726d697474656420746f2c2077652077696c6c2070726f766964652061206d6f72652066756c736f6d652073756d6d61727920746f20746865205765623320636f6d6d756e6974792e0a0a4173206120555320636f6d70616e792c20776520617265206c6567616c6c7920726571756972656420746f20636f6f706572617465207769746820746865205553204665646572616c20476f7665726e6d656e7420696e20726573706f6e736520746f206365727461696e207479706573206f66206c617766756c2072657175657374732e205375636820726571756972656420636f6d706c69616e6365206861732070726f76656e20746f20626520616e2065787472656d652066696e616e6369616c2062757264656e20696e2074686520666f726d206f66206665657320616e6420657870656e7365732066726f6d206f7572206c61777965727320616e6420656d6f74696f6e616c206469737472657373206e6f74206a757374206f6e20757320696e646976696475616c6c792c2062757420746f206f75722066616d696c6965732061732077656c6c2e205765206e65676f746961746564207369676e69666963616e7420646973636f756e74732066726f6d206f757220636f756e73656c2c2077686f206172652077656c6c2d76657273656420696e20576562332c20616e642077686f207265636f676e697a652074686520696d706f7274616e6365206f66206574682e6c696d6f20616e6420746865207369676e69666963616e74207075626c696320676f6f6420736572766963652069742070726f76696465732e0a0a41742070726573656e742c2077652068617665206e6f2077617920746f20616e746963697061746520657870656374656420667574757265206c6567616c20636f737473206173736f6369617465642077697468207468697320737065636966696320736574206f66206c6567616c2072657175657374732c206e6f72206172652077652061626c6520746f20666f72656361737420616e79206164646974696f6e616c206c6567616c206d617474657273206f722070726f63656564696e67732074686174206d6179206172697365206173206120726573756c74206f66206d61696e7461696e696e67206574682e6c696d6f2061732061207075626c696320676f6f642e2054686973206861732074686520696e64697265637420656666656374206f66206c696d6974696e67206f7572206162696c69747920746f2067726f7720616e64207363616c6520746865206574682e6c696d6f20736572766963652c2061732077656c6c20617320746f207075727375652066757475726520706c616e732072656c6174696e6720746f206164646974696f6e616c20696e746567726174696f6e7320616e6420726f61646d6170206566666f7274732e0a0a546f20707574207468697320696e746f2070657273706563746976652c207765206861766520616c7265616479207370656e7420636c6f736520746f20243235306b2055534420696e206c6567616c2066656573206f76657220746865207061737420666577206d6f6e7468732e20576974686f7574206164646974696f6e616c2066756e64696e672c20746869732076657279206c696b656c7920636f756c6420636f6e73756d65206f75722072656d61696e696e672066696e616e6369616c207265736f75726365732c206c656176696e6720757320776974686f757420746865206162696c69747920746f20636f6e74696e756520746f206f706572617465206574682e6c696d6f2061732061207075626c696320676f6f642e0a0a2323204c696e6b730a5b54656d706572617475726520436865636b5d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f74656d702d636865636b2d7265696d62757273656d656e742d6f662d6574682d6c696d6f732d6f6e676f696e672d6c6567616c2d666565732f31393937362f31290a0a2323232053706563696669636174696f6e0a546869732065786563757461626c652070726f706f73616c2077696c6c20696e6974696174652061207472616e73666572206f66203234302c3633322e333820555344432066726f6d2074686520454e532044414f20747265617375727920746f20657468646f746c696d6f2e6574682e205468697320616d6f756e7420726570726573656e747320746865206f6e676f696e67206c6567616c20666565732072656c6174656420746f20746865206f7065726174696f6e206f6620746865206574682e6c696d6f2f6574682e6c696e6b20676174657761792073657276696365732e0a0a232323205472616e73616374696f6e2044657461696c730a0a2a202a2a46726f6d2a2a3a20454e532044414f2054726561737572792028307846653839636337614242324334313833363833616237313635334334636463394230324434346237290a2a202a2a546f2a2a3a205553444320546f6b656e20436f6e74726163742028307841306238363939316336323138623336633164313944346132653945623063453336303665423438290a2a202a2a526563697069656e742a2a3a20657468646f746c696d6f2e6574682028307842333532624234453241346632373638333433356631353341323539663142323037323138623162290a2a202a2a416d6f756e742a2a3a203234302c3633322e33382055534443202832343036333233383030303020636f6e7369646572696e672055534443e2809973203620646563696d616c20706c61636573290a2a202a2a507572706f73652a2a3a20546865207265696d62757273656d656e74206f66206574682e6c696d6f20666f72206f6e676f696e67206c6567616c20666565732072656c6174656420746f20746865206f7065726174696f6e206f6620746865206574682e6c696d6f2f6574682e6c696e6b20676174657761792073657276696365732e0a0a54686973207472616e73616374696f6e2063616c6c732074686520607472616e73666572602066756e6374696f6e206f6620746865205553444320636f6e74726163742c207472616e7366657272696e67203234302c3633322e3338205553444320746f206574682e6c696d6f277320616464726573732e0a0a23232043616c6c646174610a0a606060200a7b0a2020202022746172676574223a2022307841306238363939316336323138623336633164313944346132653945623063453336303665423438222c0a202020202276616c7565223a20302c0a202020202263616c6c64617461223a2022307861393035396362623030303030303030303030303030303030303030303030306233353262623465326134663237363833343335663135336132353966316232303732313862316230303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303033383036636562613630220a7d0a6060600a23232320526174696f6e616c650a0a427920617070726f76696e67207468697320636f6d70656e736174696f6e2c20454e532044414f2061636b6e6f776c65646765732074686520696d706f7274616e6365206f662070726f766964696e67206574682e6c696d6f2077697468207265696d62757273656d656e74206f6620697473206c6567616c206665657320736f2069742063616e20636f6e74696e756520746f206f7065726174652061206672656520616e64207075626c696320454e532067617465776179207468617420656e61626c657320757365727320746f2061636365737320457468657265756d2d6e617469766520644170707320616e6420636f6e74656e742e0000000000000000000000000000000000000000";

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_424_433, urlOrAlias: "mainnet" });
    }

    function _proposer() public pure override returns (address) {
        return 0x983110309620D911731Ac0932219af06091b6744; // brantly.eth
    }

    function _beforeExecution() public override {
        USDCbalanceBefore = USDC.balanceOf(address(timelock));
    }

    function _generateCallData()
        public
        override
        returns (address[] memory, uint256[] memory, string[] memory, bytes[] memory, string memory)
    {
        (targets, values, calldatas, description) =
            abi.decode(proposalCalldata, (address[], uint256[], bytes[], string));

        bytes[] memory internalCalldatas = new bytes[](1);
        internalCalldatas[0] = abi.encodeWithSelector(USDC.transfer.selector, receiver, expectedUSDCtransfer);

        bytes memory expectedCalldata = abi.encode(targets, values, internalCalldatas, description);

        assertEq(calldatas, internalCalldatas);
        assertEq(proposalCalldata, expectedCalldata);

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public override {
        USDCbalanceAfter = USDC.balanceOf(address(timelock));
        assertEq(USDCbalanceBefore, USDCbalanceAfter + expectedUSDCtransfer);
        assertNotEq(USDCbalanceAfter, USDCbalanceBefore);
    }

    function _isProposalSubmitted() public pure override returns (bool) {
        return true;
    }
}
