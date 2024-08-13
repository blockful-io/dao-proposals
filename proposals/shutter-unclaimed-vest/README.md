# Shutter DAO

Some unclaimed funds are sitting in the Shutter DAO Vesting contract. Besides the unclaimed funds, the vesting contract
is currently enabledas a Safe module at the treasury. This executable proposal aims to claim the unclaimed funds,
transferring into the trasury and disable the vesting contract as a Safe module at the treasury.

See:
[Discussion](https://shutternetwork.discourse.group/t/unclaimed-vest-administrative-tasks-for-shutter-dao-0x36-treasury/467)

#### Unclaimed vest: Administrative Tasks for Shutter DAO 0x36 Treasury

- Claim $SHU tokens
- Transfer to the treasury
- Disable the vesting contract as a Safe module at the treasury

#### What's inside?

- [Shutter Token Contract](https://etherscan.io/address/0xe485E2f1bab389C08721B291f6b59780feC83Fd7#code)
- [0x36 DAO Treasury](https://etherscan.io/address/0x36bD3044ab68f600f6d3e081056F34f2a58432c4#code)
- [Airdrop Contract](https://etherscan.io/address/0x024574C4C42c72DfAaa3ccA80f73521a4eF5Ca94#code)
- [Vesting Pool Manager](https://etherscan.io/address/0xD724DBe7e230E400fe7390885e16957Ec246d716#code)

### Tests

Shutter DAO tests are strictly dependable on mainnet conditions and thus require to be initialized using forked
environment.

```sh
$ yarn test:claim-unused-tokens
$ yarn test:disable-vest-as-module
```

### Governance Test

This test will simulate the governance proposal and its execution. It will also generate the calldata for the proposal.

```shell
$ yarn calldata:claim-and-disable
```

### Fractal Calldata

```shell
##### Transaction 1 - Claim Unused Tokens
# Target: 0x024574C4C42c72DfAaa3ccA80f73521a4eF5Ca94
# Function: claimUnusedTokens
# Parameter 1 Type: address
# Parameter 1 Value: 0x36bD3044ab68f600f6d3e081056F34f2a58432c4
# Transaction Value: 0

##### Transaction 2 - Disable Vesting Contract as a Safe Module
# Target: 0x36bD3044ab68f600f6d3e081056F34f2a58432c4
# Function: disableModule
# Parameter 1 Type: address
# Parameter 1 Value: 0x0000000000000000000000000000000000000001
# Parameter 2 Type: address
# Parameter 2 Value: 0xD724DBe7e230E400fe7390885e16957Ec246d716
# Transaction Value: 0
```
