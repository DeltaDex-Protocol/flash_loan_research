#### Fork Mainnet:

```sh
npx hardhat node --fork https://mainnet.infura.io/v3/4914b54dc7684fa7b2c0154761c57939
```

#### Unlock DAI on mainnet fork:

```sh
npx hardhat --network localhost test test/unlock-account.test.js
```

#### Deploy v1-core to mainnet fork:

```sh
npx hardhat run --network localhost test/deploy.js
```

#### To get ABI of OptionMaker.sol:

```sh
npx hardhat clean
npx hardhat compile
```

#### @dev notes:

Any file marked with ending .sol(x) is currently in development.
These files will be integrated in future commits.
