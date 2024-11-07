// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";

import "./interfaces/ISavingsDai.sol";
import "../utils/interfaces/IERC20.sol";

contract TestDepositDaiToDSR is Test {
    /// @dev Stablecoin configurations
    uint256 constant decimalsDAI = 10 ** 18;
    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    /// @dev Maker DAI Savings Token
    ISavingsDai SavingsDai = ISavingsDai(0x83F20F44975D03b1b09e64809B757c47f942BEeA);

    /**
     * @dev Deposit DAI to the DSR contract and returns the received shares.
     *
     * NOTE: `amount` is the USDC token and should not have decimals.
     *
     * Walkthrough:
     * 1. Prank the DAI holder.
     * 2. Approve the SavingsDai to spend DAI.
     * 3. Deposit DAI in the SavingsDai contract.
     * 4. Stop the prank.
     *
     * @param prank The address that will be impersonated.
     * @param to The address to receive the shares.
     * @param amount The amount of DAI to deposit.
     * @return sharesReceived The amount of shares received.
     */
    function depositDaiToDSR(address prank, address to, uint256 amount) external returns (uint256 sharesReceived) {
        // Start pranking with the ShutterGnosis
        vm.startPrank(prank);
        // Approve SavingsDai to spend DAI {ERC20-approve}
        DAI.approve(address(SavingsDai), amount * decimalsDAI);
        // Deposit DAI to SavingsDai {SavingsDai-deposit}
        sharesReceived = SavingsDai.deposit(amount * decimalsDAI, to);
        // Stop the prank
        vm.stopPrank();
    }
}
