// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

interface SuperToken {
    error SF_TOKEN_AGREEMENT_ALREADY_EXISTS();
    error SF_TOKEN_AGREEMENT_DOES_NOT_EXIST();
    error SF_TOKEN_BURN_INSUFFICIENT_BALANCE();
    error SF_TOKEN_MOVE_INSUFFICIENT_BALANCE();
    error SF_TOKEN_ONLY_HOST();
    error SF_TOKEN_ONLY_LISTED_AGREEMENT();
    error SUPER_TOKEN_APPROVE_FROM_ZERO_ADDRESS();
    error SUPER_TOKEN_APPROVE_TO_ZERO_ADDRESS();
    error SUPER_TOKEN_BURN_FROM_ZERO_ADDRESS();
    error SUPER_TOKEN_CALLER_IS_NOT_OPERATOR_FOR_HOLDER();
    error SUPER_TOKEN_INFLATIONARY_DEFLATIONARY_NOT_SUPPORTED();
    error SUPER_TOKEN_MINT_TO_ZERO_ADDRESS();
    error SUPER_TOKEN_NFT_PROXY_ADDRESS_CHANGED();
    error SUPER_TOKEN_NOT_ERC777_TOKENS_RECIPIENT();
    error SUPER_TOKEN_NO_UNDERLYING_TOKEN();
    error SUPER_TOKEN_ONLY_ADMIN();
    error SUPER_TOKEN_ONLY_GOV_OWNER();
    error SUPER_TOKEN_ONLY_SELF();
    error SUPER_TOKEN_TRANSFER_FROM_ZERO_ADDRESS();
    error SUPER_TOKEN_TRANSFER_TO_ZERO_ADDRESS();

    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);
    event AgreementCreated(address indexed agreementClass, bytes32 id, bytes32[] data);
    event AgreementLiquidated(
        address indexed agreementClass,
        bytes32 id,
        address indexed penaltyAccount,
        address indexed rewardAccount,
        uint256 rewardAmount
    );
    event AgreementLiquidatedBy(
        address liquidatorAccount,
        address indexed agreementClass,
        bytes32 id,
        address indexed penaltyAccount,
        address indexed bondAccount,
        uint256 rewardAmount,
        uint256 bailoutAmount
    );
    event AgreementLiquidatedV2(
        address indexed agreementClass,
        bytes32 id,
        address indexed liquidatorAccount,
        address indexed targetAccount,
        address rewardAmountReceiver,
        uint256 rewardAmount,
        int256 targetAccountBalanceDelta,
        bytes liquidationTypeData
    );
    event AgreementStateUpdated(address indexed agreementClass, address indexed account, uint256 slotId);
    event AgreementTerminated(address indexed agreementClass, bytes32 id);
    event AgreementUpdated(address indexed agreementClass, bytes32 id, bytes32[] data);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event Bailout(address indexed bailoutAccount, uint256 bailoutAmount);
    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);
    event CodeUpdated(bytes32 uuid, address codeAddress);
    event Initialized(uint8 version);
    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);
    event PoolAdminNFTCreated(address indexed poolAdminNFT);
    event PoolMemberNFTCreated(address indexed poolMemberNFT);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );
    event TokenDowngraded(address indexed account, uint256 amount);
    event TokenUpgraded(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function CONSTANT_INFLOW_NFT() external view returns (address);
    function CONSTANT_OUTFLOW_NFT() external view returns (address);
    function POOL_ADMIN_NFT() external view returns (address);
    function POOL_MEMBER_NFT() external view returns (address);
    function allowance(address account, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function authorizeOperator(address operator) external;
    function balanceOf(address account) external view returns (uint256 balance);
    function burn(uint256 amount, bytes memory userData) external;
    function castrate() external;
    function changeAdmin(address newAdmin) external;
    function createAgreement(bytes32 id, bytes32[] memory data) external;
    function decimals() external pure returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function defaultOperators() external view returns (address[] memory);
    function downgrade(uint256 amount) external;
    function downgradeTo(address to, uint256 amount) external;
    function getAccountActiveAgreements(address account) external view returns (address[] memory);
    function getAdmin() external view returns (address);
    function getAgreementData(
        address agreementClass,
        bytes32 id,
        uint256 dataLength
    )
        external
        view
        returns (bytes32[] memory data);
    function getAgreementStateSlot(
        address agreementClass,
        address account,
        uint256 slotId,
        uint256 dataLength
    )
        external
        view
        returns (bytes32[] memory slotData);
    function getCodeAddress() external view returns (address codeAddress);
    function getHost() external view returns (address host);
    function getUnderlyingDecimals() external view returns (uint8);
    function getUnderlyingToken() external view returns (address);
    function granularity() external pure returns (uint256);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function initialize(address underlyingToken, uint8 underlyingDecimals, string memory n, string memory s) external;
    function initializeWithAdmin(
        address underlyingToken,
        uint8 underlyingDecimals,
        string memory n,
        string memory s,
        address admin
    )
        external;
    function isAccountCritical(address account, uint256 timestamp) external view returns (bool isCritical);
    function isAccountCriticalNow(address account) external view returns (bool isCritical);
    function isAccountSolvent(address account, uint256 timestamp) external view returns (bool isSolvent);
    function isAccountSolventNow(address account) external view returns (bool isSolvent);
    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);
    function makeLiquidationPayoutsV2(
        bytes32 id,
        bytes memory liquidationTypeData,
        address liquidatorAccount,
        bool useDefaultRewardAccount,
        address targetAccount,
        uint256 rewardAmount,
        int256 targetAccountBalanceDelta
    )
        external;
    function name() external view returns (string memory);
    function operationApprove(address account, address spender, uint256 amount) external;
    function operationDecreaseAllowance(address account, address spender, uint256 subtractedValue) external;
    function operationDowngrade(address account, uint256 amount) external;
    function operationDowngradeTo(address account, address to, uint256 amount) external;
    function operationIncreaseAllowance(address account, address spender, uint256 addedValue) external;
    function operationSend(address spender, address recipient, uint256 amount, bytes memory userData) external;
    function operationTransferFrom(address account, address spender, address recipient, uint256 amount) external;
    function operationUpgrade(address account, uint256 amount) external;
    function operationUpgradeTo(address account, address to, uint256 amount) external;
    function operatorBurn(address account, uint256 amount, bytes memory userData, bytes memory operatorData) external;
    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    )
        external;
    function proxiableUUID() external pure returns (bytes32);
    function realtimeBalanceOf(
        address account,
        uint256 timestamp
    )
        external
        view
        returns (int256 availableBalance, uint256 deposit, uint256 owedDeposit);
    function realtimeBalanceOfNow(address account)
        external
        view
        returns (int256 availableBalance, uint256 deposit, uint256 owedDeposit, uint256 timestamp);
    function revokeOperator(address operator) external;
    function selfApproveFor(address account, address spender, uint256 amount) external;
    function selfBurn(address account, uint256 amount, bytes memory userData) external;
    function selfMint(address account, uint256 amount, bytes memory userData) external;
    function selfTransferFrom(address holder, address spender, address recipient, uint256 amount) external;
    function send(address recipient, uint256 amount, bytes memory userData) external;
    function settleBalance(address account, int256 delta) external;
    function symbol() external view returns (string memory);
    function terminateAgreement(bytes32 id, uint256 dataLength) external;
    function toUnderlyingAmount(uint256 amount)
        external
        view
        returns (uint256 underlyingAmount, uint256 adjustedAmount);
    function totalSupply() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferAll(address recipient) external;
    function transferFrom(address holder, address recipient, uint256 amount) external returns (bool);
    function updateAgreementData(bytes32 id, bytes32[] memory data) external;
    function updateAgreementStateSlot(address account, uint256 slotId, bytes32[] memory slotData) external;
    function updateCode(address newAddress) external;
    function upgrade(uint256 amount) external;
    function upgradeTo(address to, uint256 amount, bytes memory userData) external;
}
