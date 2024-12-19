// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test } from "@forge-std/src/Test.sol";
import { console2 } from "@forge-std/src/console2.sol";

import { IERC20 } from "@contracts/utils/interfaces/IERC20.sol";
import { IUSDC } from "@contracts/utils/interfaces/IUSDC.sol";
import { SuperToken } from "@contracts/utils/interfaces/IUSDCx.sol";
import { ISuperfluid } from "@contracts/utils/interfaces/ISuperfluid.sol";
import { BatchPlanner } from "@ens/interfaces/IHedgey.sol";
import { VotingTokenVestingPlans } from "@ens/interfaces/IHedgey.sol";

import { ENS_Governance } from "@ens/ens.t.sol";

contract Proposal_ENS_EP_5_29_Test is ENS_Governance {
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 ENS = IERC20(0xC18360217D8F7Ab5e7c516566761Ea12Ce7F9D72);
    IERC20 USDCx = IERC20(0x1BA8603DA702602A8657980e825A6DAa03Dee93a);
    ISuperfluid superFluid = ISuperfluid(0xcfA132E353cB4E398080B9700609bb008eceB125);
    VotingTokenVestingPlans vestingLocker = VotingTokenVestingPlans(0x1bb64AF7FE05fc69c740609267d2AbE3e119Ef82);

    uint256 expectedUSDCtransfer = 1_200_000 * (10 ** 18);
    int96 USDCFlowRateBefore;
    int256 expectedUSDCFlowRate = 38_026_517_538_495_352; // 0,038/s

    uint256 ENSbalanceBefore;
    uint256 expectedENStransfer = 24_000 * (10 ** 18);

    address receiver = 0x64Ca550F78d6Cc711B247319CC71A04A166707Ab;

    bytes proposalCalldata =
        hex"00000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000160000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000007a00000000000000000000000000000000000000000000000000000000000000006000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb480000000000000000000000001ba8603da702602a8657980e825a6daa03dee93a000000000000000000000000cfa132e353cb4e398080b9700609bb008eceb125000000000000000000000000a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000000000000000000000000c18360217d8f7ab5e7c516566761ea12ce7f9d720000000000000000000000003466eb008edd8d5052446293d1a7d212cb65c6460000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000001a0000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000002c000000000000000000000000000000000000000000000000000000000000003400000000000000000000000000000000000000000000000000000000000000044095ea7b30000000000000000000000001ba8603da702602a8657980e825a6daa03dee93a000000000000000000000000000000000000000000000000000000174876e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002445977d03000000000000000000000000000000000000000000000000000000174876e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006457e6aa360000000000000000000000001ba8603da702602a8657980e825a6daa03dee93a00000000000000000000000064ca550f78d6cc711b247319cc71a04a166707ab000000000000000000000000000000000000000000000000008718ea8ded5b78000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044395093510000000000000000000000001d65c6d3ad39d454ea8f682c49ae7744706ea96d000000000000000000000000000000000000000000000000000001001d1bf800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044095ea7b30000000000000000000000003466eb008edd8d5052446293d1a7d212cb65c6460000000000000000000000000000000000000000000005150ae84a8cdf0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001c494d37b5a0000000000000000000000001bb64af7fe05fc69c740609267d2abe3e119ef82000000000000000000000000c18360217d8f7ab5e7c516566761ea12ce7f9d720000000000000000000000000000000000000000000005150ae84a8cdf00000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000fe89cc7abb2c4183683ab71653c4cdc9b02d44b700000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000100000000000000000000000064ca550f78d6cc711b247319cc71a04a166707ab0000000000000000000000000000000000000000000005150ae84a8cdf00000000000000000000000000000000000000000000000000000000000000676b014f00000000000000000000000000000000000000000000000000000000694c34cf00000000000000000000000000000000000000000000000000015a1422a526f70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022ce23205b455020352e32395d2046756e64696e67207265717565737420666f7220556e7275676761626c6520746f206275696c6420616e64206f7065726174652061206e6574776f726b206f6620676174657761797320737570706f7274696e672074686520726f6c6c6f7574206f6620454e5349502d31393a2045564d2d636861696e2052657665727365205265736f6c7574696f6e200a0a5b54656d7020436865636b20446973636f75727365206c696e6b5d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f74656d702d636865636b2d65702d782d782d66756e64696e672d726571756573742d666f722d756e7275676761626c652d746f2d6275696c642d616e642d6f7065726174652d612d6e6574776f726b2d6f662d67617465776179732d737570706f7274696e672d7468652d726f6c6c6f75742d6f662d656e7369702d31392d65766d2d636861696e2d726576657273652d7265736f6c7574696f6e2f3139393032290a0a0a202323204465736372697074696f6e200a232053756d6d6172790a0a5765206172652072657175657374696e672066756e64696e672066726f6d2074686520454e532044414f20746f206275696c6420612070726f64756374696f6e206e6574776f726b206f662067617465776179732e2054686573652067617465776179732077696c6c20737570706f72742074686520726f6c6c6f7574206f662072657665727365207265736f6c7574696f6e20666f72202a2a417262697472756d2c20426173652c204c696e65612c204f7074696d69736d2c20616e64205363726f6c6c2e2a2a20576520616c736f20706c616e20746f20636f6e74696e7565206f757220726573656172636820616e6420646576656c6f706d656e74206f6e2074686520454e532070726f746f636f6c20616e64206163746976656c7920636f6e7472696275746520746f2074686520454e532065636f73797374656d2077697468206120666f637573206f6e207265736f6c76696e67206e616d65732066726f6d204c32732e204f75722066756e64696e67207265717565737420666f6375736573206f6e20696e6672617374727563747572652c2074616c656e74206163717569736974696f6e20616e6420726574656e74696f6e2c20616e64206f6e676f696e6720646576656c6f706d656e7420746f207375737461696e207468697320637269746963616c20454e5320696e6672617374727563747572652e0a0a23202a2a526571756573742a2a0a0a5765206172652072657175657374696e67202a2a24312c3230302c303030205553444320616e6e75616c6c7920616e642032342c30303020454e5320746f6b656e732028766573746564206f766572203220796561727320776974682061206f6e65207965617220636c696666292e2a2a0a0a54686973207265717565737420676976657320636f6e73696465726174696f6e20746f2074686520666565646261636b206f6e206f7572205b54656d7020436865636b5d2868747470733a2f2f646973637573732e656e732e646f6d61696e732f742f74656d702d636865636b2d65702d782d782d66756e64696e672d726571756573742d666f722d756e7275676761626c652d746f2d6275696c642d616e642d6f7065726174652d612d6e6574776f726b2d6f662d67617465776179732d737570706f7274696e672d7468652d726f6c6c6f75742d6f662d656e7369702d31392d65766d2d636861696e2d726576657273652d7265736f6c7574696f6e2f313939303229206f6e2074686520454e532044414f20666f72756d2e0a0a232045786563757461626c6520436f64650a0a546869732070726f706f73616c20636f6e73746974757465732074776f2073747265616d733a0a0a2d20412073747265616d206f66202a2a24312c3230302c30303020555344432a2a202a2a70657220796561722a2a20283132206d6f6e746873292e0a2d20412073747265616d206f66202a2a32342c30303020454e532a2a20746f6b656e73206f766572202a2a322079656172732a2a20283234206d6f6e7468732920776974682061202a2a31207965617220636c6966662a2a20283132206d6f6e746873292e0a0a215b6865646765792d76657374696e672d67726170682e706e675d2868747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f756e7275676761626c652d6c6162732f756e7275676761626c652d73747265616d2f396166373435636137346233646166336238376635353031346337663465346533303763346666622f696d616765732f6865646765792d73747265616d2d67726170682e706e67290a0a426f74682073747265616d732061726520636f6e74726f6c6c6564206469726563746c792062792074686520454e532044414f2057616c6c65742e20546865792063616e2062652063616e63656c6c656420617420616e792074696d65207769746820612044414f20766f74652073686f756c6420556e7275676761626c65206e6f742066756c66696c2074686569722070726f6d697365732e0a0a546869732063616c6c6461746120686173206265656e2067656e657261746564207573696e67207468497320636f6465626173653a20205b5d2868747470733a2f2f6769746875622e636f6d2f756e7275676761626c652d6c6162732f756e7275676761626c652d73747265616d2f747265652f64636534346530666333613436316634663235306334333631303132333165353533383239653033295b68747470733a2f2f6769746875622e636f6d2f756e7275676761626c652d6c6162732f756e7275676761626c652d73747265616d2f747265652f336433633439393830646566626162333135623665303933383562323239343664643937323962305d2868747470733a2f2f6769746875622e636f6d2f756e7275676761626c652d6c6162732f756e7275676761626c652d73747265616d2f747265652f33643363343939383064656662616233313562366530393338356232323934366464393732396230292c2077686963682067656e65726174657320616e642073696d756c6174657320657865637574696f6e206f66207468652062656c6f77206c6973746564207472616e73616374696f6e732e200a0a54656e6465726c792073696d756c6174696f6e206c696e6b7320617265206c69737465642062656c6f772e0a0a2323232053747265616d2031202d2024312c3230302c30303020555344432e0a0a2a2a506c6174666f726d3a2a2a205b5375706572666c7569645d2868747470733a2f2f7777772e7375706572666c7569642e66696e616e63652f292e0a0a5375706572666c756964206973206120747269656420616e642074657374656420706c6174666f726d20666f722073747265616d696e672066756e64732e20497420686173206265656e207573656420666f72206e6561726c7920612079656172206e6f7720666f72205b2a2a5b4550352e325d205b45786563757461626c655d20436f6d6d656e63652053747265616d7320666f7220536572766963652050726f7669646572732e2a2a5d2868747470733a2f2f7777772e74616c6c792e78797a2f676f762f656e732f70726f706f73616c2f3633383635353330363032343138343234353730383133313630323737373039313234353531383531303431323337363438383630353530353736353631353736373032393531393735383136290a0a496e697469616c6973696e6720746865205375706572666c7569642073747265616d20696e766f6c766573202a2a34207472616e73616374696f6e732a2a3a0a0a7c204465736372697074696f6e207c20546172676574204e616d65207c205461726765742041646472657373207c2046756e6374696f6e205369676e6174757265207c2046756e6374696f6e20417267756d656e7473207c2043616c6c64617461205b315d207c2053696d756c6174696f6e207c0a7c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c0a7c20546869732066756e6374696f6e20617070726f7665732074686520537570657220555344437820636f6e747261637420746f207370656e6420243130302c303030206f662055534443206f6e20626568616c66206f66207468652073656e6465722c2074686520454e532044414f2077616c6c65742e207c2055534443207c205b3078413062383639393163363231386233366331643139443461326539456230634533363036654234385d2868747470733a2f2f65746865727363616e2e696f2f616464726573732f30784130623836393931633632313862333663316431394434613265394562306345333630366542343829207c206066756e6374696f6e20617070726f76652861646472657373207370656e6465722c2075696e7432353620616d6f756e74292065787465726e616c2072657475726e732028626f6f6c2960207c20605b22307831424138363033444137303236303241383635373938306538323541364441613033446565393361222c203130303030303030303030305d60207c206030783039356561376233303030303030303030303030303030303030303030303030316261383630336461373032363032613836353739383065383235613664616130336465653933613030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303137343837366538303060207c205b53696d756c6174696f6e5d2868747470733a2f2f7777772e74646c792e636f2f7368617265642f73696d756c6174696f6e2f37613333626138302d373637642d343736342d383931662d62393336393061643762323529207c0a7c20546869732066756e6374696f6e202775706772616465732720243130302c30303020555344432066726f6d2074686520454e532044414f2077616c6c65742f2754696d656c6f636b2720746f2055534443782e207c205553444378207c205b3078314241383630334441373032363032413836353739383065383235413644416130334465653933615d2868747470733a2f2f65746865727363616e2e696f2f616464726573732f30783142413836303344413730323630324138363537393830653832354136444161303344656539336129207c206066756e6374696f6e20757067726164652875696e7432353620616d6f756e742960207c20605b3130303030303030303030305d60207c2060307834353937376430333030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303137343837366538303060207c205b53696d756c6174696f6e5d2868747470733a2f2f7777772e74646c792e636f2f7368617265642f73696d756c6174696f6e2f64353634653462392d336335642d346539302d393166372d39616537386533326662643129207c0a7c20546869732066756e6374696f6e2073657473207570207468652073747265616d20746f2074686520556e7275676761626c65206d756c74697369672077616c6c65742e205b325d207c205375706572666c756964207c205b3078636641313332453335336342344533393830383042393730303630396262303038656365423132355d2868747470733a2f2f65746865727363616e2e696f2f616464726573732f30786366413133324533353363423445333938303830423937303036303962623030386563654231323529207c206066756e6374696f6e20736574466c6f7772617465286164647265737320746f6b656e416464726573732c2061646472657373207265636569766572416464726573732c20696e74393620616d6f756e745065725365636f6e642960207c20605b22307831424138363033444137303236303241383635373938306538323541364441613033446565393361222c2022307836344361353530463738643643633731314232343733313943433731413034413136363730374162222c2033383032363531373533383439353335325d60207c20603078353765366161333630303030303030303030303030303030303030303030303031626138363033646137303236303261383635373938306538323561366461613033646565393361303030303030303030303030303030303030303030303030363463613535306637386436636337313162323437333139636337316130346131363637303761623030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030383731386561386465643562373860207c205b53696d756c6174696f6e5d2868747470733a2f2f7777772e74646c792e636f2f7368617265642f73696d756c6174696f6e2f37323564383732622d383137342d346661352d613630622d35643435656561313831326629207c0a7c20546869732066756e6374696f6e20696e637265617365732074686520616d6f756e74206f66205553444320286f776e65642062792074686520454e532044414f2077616c6c65742f54696d656c6f636b29207468617420746865204175746f7772617020737472617465677920636f6e74726163742069732061626c6520746f207370656e642e207c2055534443207c205b3078413062383639393163363231386233366331643139443461326539456230634533363036654234385d2868747470733a2f2f65746865727363616e2e696f2f616464726573732f30784130623836393931633632313862333663316431394434613265394562306345333630366542343829207c206066756e6374696f6e20696e637265617365416c6c6f77616e63652861646472657373207370656e6465722c2075696e7432353620696e6372656d656e742960207c20605b22307831443635633664334144333964343534456138463638326334396145373734343730366541393664222c20313130303030303030303030305d60207c206030783339353039333531303030303030303030303030303030303030303030303030316436356336643361643339643435346561386636383263343961653737343437303665613936643030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030313030316431626638303060207c205b53696d756c6174696f6e5d2868747470733a2f2f7777772e74646c792e636f2f7368617265642f73696d756c6174696f6e2f64393464373035622d303032352d343530302d623564302d65346562613532323161626529207c0a0a2323232053747265616d2032202d2032342c30303020454e530a0a506c6174666f726d3a205b4865646765795d2868747470733a2f2f6865646765792e66696e616e63652f290a0a48656467657920686173206265656e207574696c697365642062792074686520454e532044414f20666f7220616c6c6f636174696e672064656c656761746561626c6520454e5320746f6b656e7320746f20646573657276696e672065636f73797374656d207061727469636970616e74732e0a0a496e697469616c6973696e6720746865204865646765792073747265616d20696e766f6c766573202a2a32207472616e73616374696f6e732a2a3a0a0a7c204465736372697074696f6e207c20546172676574204e616d65207c205461726765742041646472657373207c2046756e6374696f6e205369676e6174757265207c2046756e6374696f6e20417267756d656e7473207c2043616c6c64617461205b315d207c2053696d756c6174696f6e207c0a7c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c202d2d2d207c0a7c20417070726f76652074686520604261746368506c616e6e65726020746f207370656e642032342c30303020454e5320746f6b656e73206f776e65642062792074686520454e532044414f2057616c6c6574207c20454e5320546f6b656e207c205b3078433138333630323137443846374162356537633531363536363736314561313243653746394437325d2868747470733a2f2f65746865727363616e2e696f2f616464726573732f30784331383336303231374438463741623565376335313635363637363145613132436537463944373229207c206066756e6374696f6e20617070726f76652861646472657373207370656e6465722c2075696e7432353620616d6f756e74292065787465726e616c2072657475726e732028626f6f6c2960207c20605b2022307833343636454230303845444438643530353234343632393344316137443231326362363543363436222c203234303030303030303030303030303030303030303030205d60207c206030783039356561376233303030303030303030303030303030303030303030303030333436366562303038656464386435303532343436323933643161376432313263623635633634363030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303531353061653834613863646630303030303060207c205b53696d756c6174696f6e5d2868747470733a2f2f7777772e74646c792e636f2f7368617265642f73696d756c6174696f6e2f38323833386566612d326464612d343636302d616266372d39393166323738373338386129207c0a7c20437265617465207468652056657374696e6720506c616e2e20546f6b656e7320766573746564206f766572203234206d6f6e7468732c20776974682061203132206d6f6e746820636c6966662e205b335d207c2048656467657920426174636820506c616e6e6572207c205b3078333436364542303038454444386435303532343436323933443161374432313263623635433634365d2868747470733a2f2f65746865727363616e2e696f2f616464726573732f30783334363645423030384544443864353035323434363239334431613744323132636236354336343629207c206066756e6374696f6e20626174636856657374696e67506c616e732861646472657373206c6f636b65722c206164647265737320746f6b656e2c2075696e7432353620746f74616c416d6f756e742c286164647265737320726563697069656e742c2075696e7432353620616d6f756e742c2075696e743235362073746172742c2075696e7432353620636c6966662c2075696e743235362072617465295b5d2c2075696e7432353620706572696f642c20616464726573732076657374696e6741646d696e2c20626f6f6c2061646d696e5472616e736665724f424f2c2075696e7438206d696e74547970652960207c20605b22307831626236344146374645303566633639633734303630393236376432416245336531313945663832222c2022307843313833363032313744384637416235653763353136353636373631456131324365374639443732222c2032343030303030303030303030303030303030303030302c205b5b22307836344361353530463738643643633731314232343733313943433731413034413136363730374162222c2032343030303030303030303030303030303030303030302c20313733353036353933352c20313736363630313933352c203338303531373530333830353137355d5d2c20312c2022307846653839636337614242324334313833363833616237313635334334636463394230324434346237222c20747275652c20345d60207c206030783934643337623561303030303030303030303030303030303030303030303030316262363461663766653035666336396337343036303932363764326162653365313139656638323030303030303030303030303030303030303030303030306331383336303231376438663761623565376335313635363637363165613132636537663964373230303030303030303030303030303030303030303030303030303030303030303030303030303030303030303035313530616538346138636466303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303130303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303130303030303030303030303030303030303030303030303066653839636337616262326334313833363833616237313635336334636463396230326434346237303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030313030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303430303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303031303030303030303030303030303030303030303030303030363463613535306637386436636337313162323437333139636337316130346131363637303761623030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303531353061653834613863646630303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303637366230313466303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303036393463333463663030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303135613134323261353236663760207c205b53696d756c6174696f6e5d2868747470733a2f2f7777772e74646c792e636f2f7368617265642f73696d756c6174696f6e2f64333366393332332d386563302d343430322d613435382d32363562376661353436663729207c0a0a5b315d20596f752063616e2064656570206469766520696e746f20746869732063616c6c646174612061742074686520666f6c6c6f77696e67206c696e6b3a205b68747470733a2f2f657468746f6f6c732e636f6d2f63616c6c646174612d636f6c6c656374696f6e732f756e7275676761626c652d65786563757461626c652d70726f706f73616c5d2868747470733a2f2f657468746f6f6c732e636f6d2f63616c6c646174612d636f6c6c656374696f6e732f756e7275676761626c652d65786563757461626c652d70726f706f73616c290a0a5b325d206033383032363531373533383439353335326020726570726573656e74732024302e3033382e2e205553444320706572207365636f6e64206e6f74696e67207468617420555344432068617320313820646563696d616c7320616e64207468657265206172652060333135353639323660207365636f6e647320696e206120796561722e0a0a5b335d2060706572696f64602c20616e6420606d696e74547970656020617267756d656e7473206172652074616b656e2066726f6d207468652048656467657920646f63756d656e746174696f6e3a205b68747470733a2f2f6865646765792e676974626f6f6b2e696f2f6865646765792d636f6d6d756e6974792d646f63732f666f722d646576656c6f706572732f746563686e6963616c2d646f63756d656e746174696f6e2f746f6b656e2d76657374696e672f696e746567726174696f6e2d616e642d6469726563742d636f6e74726163742d696e746572616374696f6e735d2868747470733a2f2f6865646765792e676974626f6f6b2e696f2f6865646765792d636f6d6d756e6974792d646f63732f666f722d646576656c6f706572732f746563686e6963616c2d646f63756d656e746174696f6e2f746f6b656e2d76657374696e672f696e746567726174696f6e2d616e642d6469726563742d636f6e74726163742d696e746572616374696f6e7329000000000000000000000000000000000000";

    function _selectFork() public override {
        vm.createSelectFork({ blockNumber: 21_424_461, urlOrAlias: "mainnet" });
    }

    function _proposer() public view override returns (address) {
        return 0x983110309620D911731Ac0932219af06091b6744; // brantly.eth
    }

    function _beforeExecution() public override {
        USDCFlowRateBefore = superFluid.getAccountFlowrate(address(USDCx), receiver);
        ENSbalanceBefore = ENS.balanceOf(receiver);
    }

    function _generateCallData()
        public
        override
        returns (address[] memory, uint256[] memory, string[] memory, bytes[] memory, string memory)
    {
        (targets, values, calldatas, description) =
            abi.decode(proposalCalldata, (address[], uint256[], bytes[], string));

        uint256 secondsInYear = 31_556_926;

        // USDC transferring

        uint256 USDCInitialAllowance = 100_000 * 10 ** 6; // USDC decimals
        uint256 USDCAmountPerSecond = expectedUSDCtransfer / secondsInYear;

        bytes[] memory internalCalldatas = new bytes[](6);

        internalCalldatas[0] = abi.encodeWithSelector(IUSDC.approve.selector, address(USDCx), USDCInitialAllowance);
        internalCalldatas[1] = abi.encodeWithSelector(SuperToken.upgrade.selector, USDCInitialAllowance);
        internalCalldatas[2] =
            abi.encodeWithSelector(ISuperfluid.setFlowrate.selector, address(USDCx), receiver, USDCAmountPerSecond);
        internalCalldatas[3] = abi.encodeWithSelector(
            IUSDC.increaseAllowance.selector, 0x1D65c6d3AD39d454Ea8F682c49aE7744706eA96d, 1_100_000 * 10 ** 6
        );

        // ENS transferring

        BatchPlanner vesting = BatchPlanner(0x3466EB008EDD8d5052446293D1a7D212cb65C646);

        BatchPlanner.Plan[] memory plans = new BatchPlanner.Plan[](1);

        uint256 vestingStart = 1_735_065_935; // 2024-12-24
        uint256 cliff = 1_766_601_935; // 2025-12-24
        uint256 rate = 380_517_503_805_175; // 0,0003805175038 ENS/s
        plans[0] = BatchPlanner.Plan(receiver, expectedENStransfer, vestingStart, cliff, rate);

        internalCalldatas[4] = abi.encodeWithSelector(ENS.approve.selector, address(vesting), expectedENStransfer);
        internalCalldatas[5] = abi.encodeWithSelector(
            BatchPlanner.batchVestingPlans.selector,
            vestingLocker,
            address(ENS),
            expectedENStransfer,
            plans,
            1,
            0xFe89cc7aBB2C4183683ab71653C4cdc9B02D44b7,
            true,
            4
        );

        for (uint256 i = 0; i < 6; i++) {
            assertEq(calldatas[i], internalCalldatas[i]);
        }

        bytes memory expectedCalldata = abi.encode(targets, values, internalCalldatas, description);
        assertEq(proposalCalldata, expectedCalldata);

        return (targets, values, signatures, calldatas, description);
    }

    function _afterExecution() public override {
        int96 USDCFlowRateAfter = superFluid.getAccountFlowrate(address(USDCx), receiver);
        assertEq(USDCFlowRateAfter - USDCFlowRateBefore, expectedUSDCFlowRate);

        // Before cliff
        assertEq(ENSbalanceBefore, ENS.balanceOf(receiver));

        // 1 year cliff
        vm.warp(365 days);
        assertEq(ENSbalanceBefore, ENS.balanceOf(receiver));

        // 1 year vesting
        vm.warp(365 days);
        assertEq(vestingLocker.lockedBalances(receiver, address(ENS)), expectedENStransfer);
    }

    function _isProposalSubmitted() public view override returns (bool) {
        return true;
    }
}
