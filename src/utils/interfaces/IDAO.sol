// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IDAO {
    function test_proposal() external;
    function _selectFork() external;
    function _proposer() external view returns (address);
    function _voters() external view returns (address[] memory);
    function _beforeExecution() external;
    function _afterExecution() external;
    function _isProposalSubmitted() external view returns (bool);
    function _generateCallData()
        external
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas,
            string memory description
        );
}
