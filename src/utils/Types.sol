// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

struct Users {
    // Deployer of contracts.
    address deployer;
    // Impartial user.
    address alice;
    // Security Council multisig.
    address securityCouncilMultisig;
    // Malicious user.
    address attacker;
}
