# Shutter DAO

A recent Shutter Forum post raised a discussion of treasury management, specifically regarding the opportunity to
allocate part of Shutter DAO 0x36’s long term stablecoin assets to earn yield and generate additional resources / runway
for the project.

See: [Discussion](https://shutterdao.discourse.group/t/shutter-dao-0x36-discussion-regarding-treasury-management/367)
and
[Snapshot](https://snapshot.org/#/shutterdao0x36.eth/proposal/0xb4a8f52edb23311c78c9523331e778578ef03ecf70255a6d6ad1eb3f437725dd)

#### TEMP CHECK: Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract

- Convert 3M USDC to DAI
- Deposit 3M DAI in the Dai Savings Rate (DSR) Contract
- Generate additional 120K DAI per annum (likely more temporarily) for Shutter DAO 0x36

#### What's inside?

- [DssPsm - Maker's Peg-Stability Module (PSM) Contract](https://etherscan.io/address/0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A)
- [Azorius - Governor Contract](https://etherscan.io/address/0xAA6BfA174d2f803b517026E93DBBEc1eBa26258e)
- [LinearERC20Voting - Vote and Strategy Contract](https://etherscan.io/address/0x4b29d8B250B8b442ECfCd3a4e3D91933d2db720F)
- [ShutterToken - ERC20Vote Token Contract](https://etherscan.io/address/0xe485E2f1bab389C08721B291f6b59780feC83Fd7)
- [ShutterDAO 0x36 Treasury - Gnosis Safe Contract](https://etherscan.io/address/0x36bD3044ab68f600f6d3e081056F34f2a58432c4)
- [Convert 3M USDC to DAI Savings Rate (DSR) Token](https://github.com/blockful-io/dao-proposals/blob/f00a6ed1a5c6fd74a6e1470310954ec63dc93905/proposals/shutter-dsr-allocation/tests/DepositUSDCtoDSR.t.sol) 
- [Submit and execute the proposal to ShutterDAO 0x36 to allocate 3M DAI to the DSR Contract](https://github.com/blockful-io/dao-proposals/blob/efdb685cf4551c1938c22a4d4dad2d729c77de17/proposals/shutter-dsr-allocation/tests/CalldataGovernance.t.sol#L82)

### Tests

Shutter DAO tests are strictly dependable on mainnet conditions and thus require to be initialized using forked
environment.

```sh
$ yarn test:dsr-allocation
```

### Calldata

```shell
##### Tx[ 0 ] USDC Approval
# Target:     0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
# Value:      0
# Operation:  CALL
# Data:       0x095ea7b30000000000000000000000000a59649758aa4d66e25f08dd01271e891fe52199000000000000000000000000000000000000000000000000000002ba7def3000

##### Tx[ 1 ] DssPsm (swap USDC to DAI)
# Target:     0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A
# Value:      0
# Operation:  CALL
# Data:       0x9599127600000000000000000000000036bd3044ab68f600f6d3e081056f34f2a58432c4000000000000000000000000000000000000000000000000000002ba7def3000

##### Tx[ 2 ] DAI Approval
# Target:     0x6B175474E89094C44Da98b954EedeAC495271d0F
# Value:      0
# Operation:  CALL
# Data:       0x095ea7b300000000000000000000000083f20f44975d03b1b09e64809b757c47f942beea000000000000000000000000000000000000000000027b46536c66c8e3000000

##### Tx[ 3 ] SavingsDai (deposit DAI to DSR)
# Target:     0x83F20F44975D03b1b09e64809B757c47f942BEeA
# Value:      0
# Operation:  CALL
# Data:       0x6e553f65000000000000000000000000000000000000000000027b46536c66c8e300000000000000000000000000000036bd3044ab68f600f6d3e081056f34f2a58432c4
```
