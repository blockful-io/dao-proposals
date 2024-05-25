// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface ILinearERC20Voting {
  function vote(uint32 _proposalId, uint8 _voteType) external;

  function isPassed(uint32 _proposalId) external view returns (bool);

  function getProposalVotes(
    uint32 _proposalId
  )
    external
    view
    returns (
      uint256 noVotes,
      uint256 yesVotes,
      uint256 abstainVotes,
      uint32 startBlock,
      uint32 endBlock,
      uint256 votingSupply
    );
}
