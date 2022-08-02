#### Fork Mainnet:

```sh
npx hardhat node --fork https://mainnet.infura.io/v3/4914b54dc7684fa7b2c0154761c57939
```

#### Deploy :

```sh
npx hardhat --network localhost test test/uniswapv2test.test.js
```

#### To get ABI

```sh
npx hardhat clean
npx hardhat compile
```

#### @dev notes:

Any file marked with ending .sol(x) is currently in development.
These files will be integrated in future commits.
