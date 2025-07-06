// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IENSRegistryWithFallback {
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);
    event NewResolver(bytes32 indexed node, address resolver);
    event NewTTL(bytes32 indexed node, uint64 ttl);
    event Transfer(bytes32 indexed node, address owner);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function old() external view returns (address);
    function owner(bytes32 node) external view returns (address);
    function recordExists(bytes32 node) external view returns (bool);
    function resolver(bytes32 node) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external;
    function setOwner(bytes32 node, address owner) external;
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setResolver(bytes32 node, address resolver) external;
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external returns (bytes32);
    function setSubnodeRecord(bytes32 node, bytes32 label, address owner, address resolver, uint64 ttl) external;
    function setTTL(bytes32 node, uint64 ttl) external;
    function ttl(bytes32 node) external view returns (uint64);
}
