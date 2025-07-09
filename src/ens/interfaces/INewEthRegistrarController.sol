// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

library IETHRegistrarController {
    struct Registration {
        string label;
        address owner;
        uint256 duration;
        bytes32 secret;
        address resolver;
        bytes[] data;
        uint8 reverseRecord;
        bytes32 referrer;
    }
}

library IPriceOracle {
    struct Price {
        uint256 base;
        uint256 premium;
    }
}

interface INewEthRegistrarController {
    error CommitmentNotFound(bytes32 commitment);
    error CommitmentTooNew(bytes32 commitment, uint256 minimumCommitmentTimestamp, uint256 currentTimestamp);
    error CommitmentTooOld(bytes32 commitment, uint256 maximumCommitmentTimestamp, uint256 currentTimestamp);
    error DurationTooShort(uint256 duration);
    error InsufficientValue();
    error MaxCommitmentAgeTooHigh();
    error MaxCommitmentAgeTooLow();
    error NameNotAvailable(string name);
    error ResolverRequiredForReverseRecord();
    error ResolverRequiredWhenDataSupplied();
    error UnexpiredCommitmentExists(bytes32 commitment);

    event NameRegistered(
        string label,
        bytes32 indexed labelhash,
        address indexed owner,
        uint256 baseCost,
        uint256 premium,
        uint256 expires,
        bytes32 referrer
    );
    event NameRenewed(string label, bytes32 indexed labelhash, uint256 cost, uint256 expires, bytes32 referrer);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function MIN_REGISTRATION_DURATION() external view returns (uint256);
    function available(string memory label) external view returns (bool);
    function commit(bytes32 commitment) external;
    function commitments(bytes32) external view returns (uint256);
    function defaultReverseRegistrar() external view returns (address);
    function ens() external view returns (address);
    function makeCommitment(IETHRegistrarController.Registration memory registration)
        external
        pure
        returns (bytes32 commitment);
    function maxCommitmentAge() external view returns (uint256);
    function minCommitmentAge() external view returns (uint256);
    function owner() external view returns (address);
    function prices() external view returns (address);
    function recoverFunds(address _token, address _to, uint256 _amount) external;
    function register(IETHRegistrarController.Registration memory registration) external payable;
    function renew(string memory label, uint256 duration, bytes32 referrer) external payable;
    function renounceOwnership() external;
    function rentPrice(string memory label, uint256 duration) external view returns (IPriceOracle.Price memory price);
    function reverseRegistrar() external view returns (address);
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
    function transferOwnership(address newOwner) external;
    function valid(string memory label) external pure returns (bool);
    function withdraw() external;
}
