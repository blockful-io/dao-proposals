# Shutter DAO

A recent Shutter Forum post raised a discussion of treasury management, specifically regarding the opportunity to allocate part of Shutter DAO 0x36’s long term stablecoin assets to earn yield and generate additional resources / runway for the project.

See: [Discussion](https://shutterdao.discourse.group/t/shutter-dao-0x36-discussion-regarding-treasury-management/367) and [Snapshot](https://snapshot.org/#/shutterdao0x36.eth/proposal/0xb4a8f52edb23311c78c9523331e778578ef03ecf70255a6d6ad1eb3f437725dd)

#### TEMP CHECK: Treasury Management Temporary Solution: Deposit 3M DAI in the DSR Contract

-  Convert 3M USDC to DAI
-  Deposit 3M DAI in the Dai Savings Rate (DSR) Contract
-  Generate additional 120K DAI per annum (likely more temporarily) for Shutter DAO 0x36


#### What's inside?

- [USDC](https://etherscan.io/address/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48) ERC20 Token Contract 
- [DAI](https://etherscan.io/address/0x6B175474E89094C44Da98b954EedeAC495271d0F) ERC20 Token Contract
- [ShutterToken](https://etherscan.io/address/0xe485E2f1bab389C08721B291f6b59780feC83Fd7) ERC20Vote Token Contract
- [SavingsDai](https://etherscan.io/address/0x83F20F44975D03b1b09e64809B757c47f942BEeA) ERC4626 Vault Contract
- [DssPsm](https://etherscan.io/address/0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A) Maker's Peg-Stability Module (PSM) Contract
- [AuthGemJoin5](https://etherscan.io/address/0x0A59649758aa4d66E25f08Dd01271e891fe52199) Maker's Peg-Stability Module (PSM) Contract
- [Azorius](https://etherscan.io/address/0xAA6BfA174d2f803b517026E93DBBEc1eBa26258e) Governor Contract
- [LinearERC20Voting](https://etherscan.io/address/0x4b29d8B250B8b442ECfCd3a4e3D91933d2db720F) Voting and Strategy Contract
- [Shutter Treasury](https://etherscan.io/address/0x36bD3044ab68f600f6d3e081056F34f2a58432c4) Gnosis Safe Contract

### Tests

Shutter DAO tests are strictly dependable on mainnet conditions and thus require to be initialized using forked environment.

```sh
$ yarn test:fork
```
