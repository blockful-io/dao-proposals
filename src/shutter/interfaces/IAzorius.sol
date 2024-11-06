// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IAzorius {
  enum Operation {
    Call,
    DelegateCall
  }

  enum ProposalState {
    ACTIVE,
    TIMELOCKED,
    EXECUTABLE,
    EXECUTED,
    EXPIRED,
    FAILED
  }

  function totalProposalCount() external view returns (uint32);

  function proposalState(uint32 _proposalId) external view returns (ProposalState);

  function getProposal(
    uint32 _proposalId
  )
    external
    view
    returns (
      address _strategy,
      bytes32[] memory _txHashes,
      uint32 _timelockPeriod,
      uint32 _executionPeriod,
      uint32 _executionCounter
    );

  struct Transaction {
    address to; // destination address of the transaction
    uint256 value; // amount of ETH to transfer with the transaction
    bytes data; // encoded function call data of the transaction
    Operation operation; // Operation type, Call or DelegateCall
  }

  function submitProposal(
    address _strategy,
    bytes memory _data,
    Transaction[] calldata _transactions,
    string calldata _metadata
  ) external;

  function executeProposal(
    uint32 _proposalId,
    address[] memory _targets,
    uint256[] memory _values,
    bytes[] memory _data,
    Operation[] memory _operations
  ) external;
}
