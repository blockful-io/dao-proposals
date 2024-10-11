interface IDAO {
    function test_proposal() external;
    function _selectFork() external;
    function _proposer() external view returns (address);
    function _voter() external view returns (address);
    function _afterExecution() external;
    function _generateCallData() external returns (address[] memory targets, uint256[] memory values, string[] memory signatures, bytes[] memory calldatas, string memory description);
}
