// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IGovernor {
    type ProposalState is uint8;

    event ProposalCanceled(uint256 proposalId);
    event ProposalCreated(
        uint256 proposalId,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );
    event ProposalExecuted(uint256 proposalId);
    event ProposalQueued(uint256 proposalId, uint256 eta);
    event QuorumNumeratorUpdated(uint256 oldQuorumNumerator, uint256 newQuorumNumerator);
    event TimelockChange(address oldTimelock, address newTimelock);
    event VoteCast(address indexed voter, uint256 proposalId, uint8 support, uint256 weight, string reason);

    function BALLOT_TYPEHASH() external view returns (bytes32);

    function COUNTING_MODE() external pure returns (string memory);

    function castVote(uint256 proposalId, uint8 support) external returns (uint256);

    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (uint256);

    function castVoteWithReason(uint256 proposalId, uint8 support, string memory reason) external returns (uint256);

    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        external
        payable
        returns (uint256);

    function getVotes(address account, uint256 blockNumber) external view returns (uint256);

    function hasVoted(uint256 proposalId, address account) external view returns (bool);

    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        external
        pure
        returns (uint256);

    function name() external view returns (string memory);

    function proposalDeadline(uint256 proposalId) external view returns (uint256);

    function proposalEta(uint256 proposalId) external view returns (uint256);

    function proposalSnapshot(uint256 proposalId) external view returns (uint256);

    function proposalThreshold() external pure returns (uint256);

    function proposalVotes(uint256 proposalId)
        external
        view
        returns (uint256 againstVotes, uint256 forVotes, uint256 abstainVotes);

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        external
        returns (uint256);

    function queue(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        external
        returns (uint256);

    function quorum(uint256 blockNumber) external view returns (uint256);

    function quorumDenominator() external pure returns (uint256);

    function quorumNumerator() external view returns (uint256);

    function state(uint256 proposalId) external view returns (uint8);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function timelock() external view returns (address);

    function token() external view returns (address);

    function updateQuorumNumerator(uint256 newQuorumNumerator) external;

    function updateTimelock(address newTimelock) external;

    function version() external view returns (string memory);

    function votingDelay() external pure returns (uint256);

    function votingPeriod() external pure returns (uint256);
}
