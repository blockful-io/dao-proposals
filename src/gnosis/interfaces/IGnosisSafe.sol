// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

interface IGnosisSafe {
    function isModuleEnabled(address module) external view returns (bool);

    function disableModule(address prevModule, address module) external;
}
