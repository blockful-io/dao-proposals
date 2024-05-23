// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IERC20 {
  function approve(address spender, uint256 value) external;

  function allowance(address owner, address spender) external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IDssPsm {
  function sellGem(address usr, uint256 gemAmt) external;
}

interface ISavingsDai {
  function previewDeposit(uint256 assets) external view returns (uint256);

  function deposit(uint256 assets, address receiver) external returns (uint256 shares);

  function balanceOf(address account) external view returns (uint256);

  function maxWithdraw(address owner) external view returns (uint256);
}

interface IVotes {
  function delegate(address delegatee) external;

  function delegates(address account) external view returns (address);
}

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

interface IAzorius {
  enum Operation {
    Call,
    DelegateCall
  }

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

  function totalProposalCount() external view returns (uint32);

  enum ProposalState {
    ACTIVE,
    TIMELOCKED,
    EXECUTABLE,
    EXECUTED,
    EXPIRED,
    FAILED
  }

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
}
