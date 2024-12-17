// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface INameWrapper {
    error CannotUpgrade();
    error IncompatibleParent();
    error IncorrectTargetOwner(address owner);
    error IncorrectTokenType();
    error LabelMismatch(bytes32 labelHash, bytes32 expectedLabelhash);
    error LabelTooLong(string label);
    error LabelTooShort();
    error NameIsNotWrapped();
    error OperationProhibited(bytes32 node);
    error Unauthorised(bytes32 node, address addr);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event ControllerChanged(address indexed controller, bool active);
    event ExpiryExtended(bytes32 indexed node, uint64 expiry);
    event FusesSet(bytes32 indexed node, uint32 fuses);
    event NameUnwrapped(bytes32 indexed node, address owner);
    event NameWrapped(bytes32 indexed node, bytes name, address owner, uint32 fuses, uint64 expiry);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TransferBatch(
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event URI(string value, uint256 indexed id);

    function _tokens(uint256) external view returns (uint256);
    function allFusesBurned(bytes32 node, uint32 fuseMask) external view returns (bool);
    function approve(address to, uint256 tokenId) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids) external view returns (uint256[] memory);
    function canExtendSubnames(bytes32 node, address addr) external view returns (bool);
    function canModifyName(bytes32 node, address addr) external view returns (bool);
    function controllers(address) external view returns (bool);
    function ens() external view returns (address);
    function extendExpiry(bytes32 parentNode, bytes32 labelhash, uint64 expiry) external returns (uint64);
    function getApproved(uint256 id) external view returns (address operator);
    function getData(uint256 id) external view returns (address owner, uint32 fuses, uint64 expiry);
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function isWrapped(bytes32 parentNode, bytes32 labelhash) external view returns (bool);
    function isWrapped(bytes32 node) external view returns (bool);
    function metadataService() external view returns (address);
    function name() external view returns (string memory);
    function names(bytes32) external view returns (bytes memory);
    function onERC721Received(address to, address, uint256 tokenId, bytes memory data) external returns (bytes4);
    function owner() external view returns (address);
    function ownerOf(uint256 id) external view returns (address owner);
    function recoverFunds(address _token, address _to, uint256 _amount) external;
    function registerAndWrapETH2LD(
        string memory label,
        address wrappedOwner,
        uint256 duration,
        address resolver,
        uint16 ownerControlledFuses
    )
        external
        returns (uint256 registrarExpiry);
    function registrar() external view returns (address);
    function renew(uint256 tokenId, uint256 duration) external returns (uint256 expires);
    function renounceOwnership() external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        external;
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function setChildFuses(bytes32 parentNode, bytes32 labelhash, uint32 fuses, uint64 expiry) external;
    function setController(address controller, bool active) external;
    function setFuses(bytes32 node, uint16 ownerControlledFuses) external returns (uint32);
    function setMetadataService(address _metadataService) external;
    function setRecord(bytes32 node, address owner, address resolver, uint64 ttl) external;
    function setResolver(bytes32 node, address resolver) external;
    function setSubnodeOwner(
        bytes32 parentNode,
        string memory label,
        address owner,
        uint32 fuses,
        uint64 expiry
    )
        external
        returns (bytes32 node);
    function setSubnodeRecord(
        bytes32 parentNode,
        string memory label,
        address owner,
        address resolver,
        uint64 ttl,
        uint32 fuses,
        uint64 expiry
    )
        external
        returns (bytes32 node);
    function setTTL(bytes32 node, uint64 ttl) external;
    function setUpgradeContract(address _upgradeAddress) external;
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function transferOwnership(address newOwner) external;
    function unwrap(bytes32 parentNode, bytes32 labelhash, address controller) external;
    function unwrapETH2LD(bytes32 labelhash, address registrant, address controller) external;
    function upgrade(bytes memory name, bytes memory extraData) external;
    function upgradeContract() external view returns (address);
    function uri(uint256 tokenId) external view returns (string memory);
    function wrap(bytes memory name, address wrappedOwner, address resolver) external;
    function wrapETH2LD(
        string memory label,
        address wrappedOwner,
        uint16 ownerControlledFuses,
        address resolver
    )
        external
        returns (uint64 expiry);
}
