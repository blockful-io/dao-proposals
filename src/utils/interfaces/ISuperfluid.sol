// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface ISuperfluid {
    error CFA_FWD_INVALID_FLOW_RATE();

    function createFlow(
        address token,
        address sender,
        address receiver,
        int96 flowrate,
        bytes memory userData
    )
        external
        returns (bool);
    function deleteFlow(
        address token,
        address sender,
        address receiver,
        bytes memory userData
    )
        external
        returns (bool);
    function getAccountFlowInfo(
        address token,
        address account
    )
        external
        view
        returns (uint256 lastUpdated, int96 flowrate, uint256 deposit, uint256 owedDeposit);
    function getAccountFlowrate(address token, address account) external view returns (int96 flowrate);
    function getBufferAmountByFlowrate(address token, int96 flowrate) external view returns (uint256 bufferAmount);
    function getFlowInfo(
        address token,
        address sender,
        address receiver
    )
        external
        view
        returns (uint256 lastUpdated, int96 flowrate, uint256 deposit, uint256 owedDeposit);
    function getFlowOperatorPermissions(
        address token,
        address sender,
        address flowOperator
    )
        external
        view
        returns (uint8 permissions, int96 flowrateAllowance);
    function getFlowrate(address token, address sender, address receiver) external view returns (int96 flowrate);
    function grantPermissions(address token, address flowOperator) external returns (bool);
    function revokePermissions(address token, address flowOperator) external returns (bool);
    function setFlowrate(address token, address receiver, int96 flowrate) external returns (bool);
    function setFlowrateFrom(address token, address sender, address receiver, int96 flowrate) external returns (bool);
    function updateFlow(
        address token,
        address sender,
        address receiver,
        int96 flowrate,
        bytes memory userData
    )
        external
        returns (bool);
    function updateFlowOperatorPermissions(
        address token,
        address flowOperator,
        uint8 permissions,
        int96 flowrateAllowance
    )
        external
        returns (bool);
}
