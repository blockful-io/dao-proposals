// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IENSNewReverseRegistrar {
    error InvalidSignature();
    error SignatureExpired();
    error SignatureExpiryTooHigh();

    event ControllerChanged(address indexed controller, bool enabled);
    event NameForAddrChanged(address indexed addr, string name);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function controllers(address) external view returns (bool);
    function nameForAddr(address addr) external view returns (string memory name);
    function owner() external view returns (address);
    function renounceOwnership() external;
    function setController(address controller, bool enabled) external;
    function setName(string memory name) external;
    function setNameForAddr(address addr, string memory name) external;
    function setNameForAddrWithSignature(
        address addr,
        uint256 signatureExpiry,
        string memory name,
        bytes memory signature
    ) external;
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
    function transferOwnership(address newOwner) external;
}
