// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IENSReverseRegistrar {
    event ControllerChanged(address indexed controller, bool enabled);
    event DefaultResolverChanged(address indexed resolver);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ReverseClaimed(address indexed addr, bytes32 indexed node);

    function claim(address owner) external returns (bytes32);
    function claimForAddr(address addr, address owner, address resolver) external returns (bytes32);
    function claimWithResolver(address owner, address resolver) external returns (bytes32);
    function controllers(address) external view returns (bool);
    function defaultResolver() external view returns (address);
    function ens() external view returns (address);
    function node(address addr) external pure returns (bytes32);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function setController(address controller, bool enabled) external;
    function setDefaultResolver(address resolver) external;
    function setName(string memory name) external returns (bytes32);
    function setNameForAddr(address addr, address owner, address resolver, string memory name)
        external
        returns (bytes32);
    function transferOwnership(address newOwner) external;
}
