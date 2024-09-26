// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface IENSToken {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Claim(address indexed claimant, uint256 amount);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    event MerkleRootChanged(bytes32 merkleRoot);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function checkpoints(address account, uint32 pos) external view returns (Checkpoint memory);
    function claimPeriodEnds() external view returns (uint256);
    function claimTokens(uint256 amount, address delegate, bytes32[] memory merkleProof) external;
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function delegate(address delegatee) external;
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;
    function delegates(address account) external view returns (address);
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);
    function getVotes(address account) external view returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function isClaimed(uint256 index) external view returns (bool);
    function merkleRoot() external view returns (bytes32);
    function minimumMintInterval() external view returns (uint256);
    function mint(address dest, uint256 amount) external;
    function mintCap() external view returns (uint256);
    function name() external view returns (string memory);
    function nextMint() external view returns (uint256);
    function nonces(address owner) external view returns (uint256);
    function numCheckpoints(address account) external view returns (uint32);
    function owner() external view returns (address);
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external;
    function renounceOwnership() external;
    function setMerkleRoot(bytes32 _merkleRoot) external;
    function sweep(address dest) external;
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transferOwnership(address newOwner) external;
}
