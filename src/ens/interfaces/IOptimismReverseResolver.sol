// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IOptimismReverseResolver {
    error DNSDecodingFailed(bytes dns);
    error OffchainLookup(address from, string[] urls, bytes request, bytes4 callback, bytes carry);
    error OwnableInvalidOwner(address owner);
    error OwnableUnauthorizedAccount(address account);
    error RequestOverflow();
    error UnreachableName(bytes name);
    error UnsupportedResolverProfile(bytes4 selector);

    event GatewayURLsChanged(string[] urls);
    event GatewayVerifierChanged(address verifier);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function chainId() external view returns (uint32);
    function coinType() external view returns (uint256);
    function defaultRegistrar() external view returns (address);
    function fetchCallback(bytes memory response, bytes memory carry) external view;
    function gatewayURLs(uint256) external view returns (string memory);
    function gatewayVerifier() external view returns (address);
    function l2Registrar() external view returns (address);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function resolve(bytes memory name, bytes memory data) external view returns (bytes memory result);
    function resolveNameCallback(bytes[] memory values, uint8, bytes memory extraData)
        external
        view
        returns (bytes memory result);
    function resolveNames(address[] memory addrs, uint8 perPage) external view returns (string[] memory names);
    function resolveNamesCallback(bytes[] memory values, uint8, bytes memory extraData)
        external
        view
        returns (string[] memory names);
    function setGatewayURLs(string[] memory gateways) external;
    function setGatewayVerifier(address verifier) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function transferOwnership(address newOwner) external;
} 