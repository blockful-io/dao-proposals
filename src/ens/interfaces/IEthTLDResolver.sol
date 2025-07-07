// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IEthTLDResolver {
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event AddrChanged(bytes32 indexed node, address a);
    event AddressChanged(bytes32 indexed node, uint256 coinType, bytes newAddress);
    event ContenthashChanged(bytes32 indexed node, bytes hash);
    event InterfaceChanged(bytes32 indexed node, bytes4 indexed interfaceID, address implementer);
    event NameChanged(bytes32 indexed node, string name);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);

    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory);
    function addr(bytes32 node) external view returns (address payable);
    function addr(bytes32 node, uint256 coinType) external view returns (bytes memory);
    function contenthash(bytes32 node) external view returns (bytes memory);
    function interfaceImplementer(bytes32 node, bytes4 interfaceID) external view returns (address);
    function isOwner() external view returns (bool);
    function name(bytes32 node) external view returns (string memory);
    function owner() external view returns (address);
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y);
    function renounceOwnership() external;
    function setABI(bytes32 node, uint256 contentType, bytes memory data) external;
    function setAddr(bytes32 node, uint256 coinType, bytes memory a) external;
    function setAddr(bytes32 node, address a) external;
    function setContenthash(bytes32 node, bytes memory hash) external;
    function setInterface(bytes32 node, bytes4 interfaceID, address implementer) external;
    function setName(bytes32 node, string memory name) external;
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external;
    function setText(bytes32 node, string memory key, string memory value) external;
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
    function text(bytes32 node, string memory key) external view returns (string memory);
    function transferOwnership(address newOwner) external;
}
