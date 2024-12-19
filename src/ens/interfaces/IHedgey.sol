// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface BatchPlanner {
    struct Plan {
        address recipient;
        uint256 amount;
        uint256 start;
        uint256 cliff;
        uint256 rate;
    }

    event BatchCreated(address indexed creator, address token, uint256 recipients, uint256 totalAmount, uint8 mintType);

    function batchLockingPlans(
        address locker,
        address token,
        uint256 totalAmount,
        Plan[] memory plans,
        uint256 period,
        uint8 mintType
    )
        external;
    function batchVestingPlans(
        address locker,
        address token,
        uint256 totalAmount,
        Plan[] memory plans,
        uint256 period,
        address vestingAdmin,
        bool adminTransferOBO,
        uint8 mintType
    )
        external;
}

interface VotingTokenVestingPlans {
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    event ApprovalForAllDelegation(address owner, address operator, bool approved);
    event DelegatorApproved(uint256 indexed id, address owner, address delegator);
    event PlanCreated(
        uint256 indexed id,
        address indexed recipient,
        address indexed token,
        uint256 amount,
        uint256 start,
        uint256 cliff,
        uint256 end,
        uint256 rate,
        uint256 period,
        address vestingAdmin,
        bool adminTransferOBO
    );
    event PlanRedeemed(uint256 indexed id, uint256 amountRedeemed, uint256 planRemainder, uint256 resetDate);
    event PlanRevoked(uint256 indexed id, uint256 amountRedeemed, uint256 revokedAmount);
    event PlanTransferredByVestingAdmin(uint256 indexed id, address indexed from, address indexed to);
    event PlanVestingAdminTransferToggle(uint256 indexed id, bool transferable);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event URIAdminDeleted(address _admin);
    event URISet(string newURI);
    event VestingPlanAdminChanged(uint256 indexed id, address _newVestingAdmin);
    event VotingVaultCreated(uint256 indexed id, address vaultAddress);

    function approve(address to, uint256 tokenId) external;
    function approveDelegator(address delegator, uint256 planId) external;
    function approveSpenderDelegator(address spender, uint256 planId) external;
    function balanceOf(address owner) external view returns (uint256);
    function baseURI() external view returns (string memory);
    function changeVestingPlanAdmin(uint256 planId, address newVestingAdmin) external;
    function createPlan(
        address recipient,
        address token,
        uint256 amount,
        uint256 start,
        uint256 cliff,
        uint256 rate,
        uint256 period,
        address vestingAdmin,
        bool adminTransferOBO
    )
        external
        returns (uint256 newPlanId);
    function delegate(uint256 planId, address delegatee) external;
    function delegateAll(address token, address delegatee) external;
    function delegatePlans(uint256[] memory planIds, address[] memory delegatees) external;
    function deleteAdmin() external;
    function futureRevokePlans(uint256[] memory planIds, uint256 revokeTime) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function getApprovedDelegator(uint256 planId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function isApprovedForAllDelegation(address owner, address operator) external view returns (bool);
    function lockedBalances(address holder, address token) external view returns (uint256 lockedBalance);
    function name() external view returns (string memory);
    function ownerOf(uint256 tokenId) external view returns (address);
    function partialRedeemPlans(uint256[] memory planIds, uint256 redemptionTime) external;
    function planBalanceOf(
        uint256 planId,
        uint256 timeStamp,
        uint256 redemptionTime
    )
        external
        view
        returns (uint256 balance, uint256 remainder, uint256 latestUnlock);
    function planEnd(uint256 planId) external view returns (uint256 end);
    function plans(uint256)
        external
        view
        returns (
            address token,
            uint256 amount,
            uint256 start,
            uint256 cliff,
            uint256 rate,
            uint256 period,
            address vestingAdmin,
            bool adminTransferOBO
        );
    function redeemAllPlans() external;
    function redeemPlans(uint256[] memory planIds) external;
    function revokePlans(uint256[] memory planIds) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function setApprovalForAllDelegation(address operator, bool approved) external;
    function setApprovalForOperator(address operator, bool approved) external;
    function setupVoting(uint256 planId) external returns (address votingVault);
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function symbol() external view returns (string memory);
    function toggleAdminTransferOBO(uint256 planId, bool transferrable) external;
    function tokenByIndex(uint256 index) external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenURI(uint256 tokenId) external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function updateBaseURI(string memory _uri) external;
    function votingVaults(uint256) external view returns (address);
}
