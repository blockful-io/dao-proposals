// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IENSRegistrar {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event ControllerAdded(address indexed controller);
    event ControllerRemoved(address indexed controller);
    event NameMigrated(uint256 indexed id, address indexed owner, uint256 expires);
    event NameRegistered(uint256 indexed id, address indexed owner, uint256 expires);
    event NameRenewed(uint256 indexed id, uint256 expires);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function GRACE_PERIOD() external view returns (uint256);
    function addController(address controller) external;
    function approve(address to, uint256 tokenId) external;
    function available(uint256 id) external view returns (bool);
    function balanceOf(address owner) external view returns (uint256);
    function baseNode() external view returns (bytes32);
    function controllers(address) external view returns (bool);
    function ens() external view returns (address);
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function isOwner() external view returns (bool);
    function nameExpires(uint256 id) external view returns (uint256);
    function owner() external view returns (address);
    function ownerOf(uint256 tokenId) external view returns (address);
    function reclaim(uint256 id, address owner) external;
    function register(uint256 id, address owner, uint256 duration) external returns (uint256);
    function registerOnly(uint256 id, address owner, uint256 duration) external returns (uint256);
    function removeController(address controller) external;
    function renew(uint256 id, uint256 duration) external returns (uint256);
    function renounceOwnership() external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;
    function setApprovalForAll(address to, bool approved) external;
    function setResolver(address resolver) external;
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function transferOwnership(address newOwner) external;
}
