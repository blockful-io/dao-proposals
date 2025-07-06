// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IENSRoot {
    event TLDLocked(bytes32 indexed label);

    function controllers(address) external view returns (bool);
    function ens() external view returns (address);
    function isOwner(address addr) external view returns (bool);
    function lock(bytes32 label) external;
    function locked(bytes32) external view returns (bool);
    function owner() external view returns (address);
    function setController(address controller, bool enabled) external;
    function setResolver(address resolver) external;
    function setSubnodeOwner(bytes32 label, address owner) external;
    function supportsInterface(bytes4 interfaceID) external pure returns (bool);
    function transferOwnership(address newOwner) external;
}
