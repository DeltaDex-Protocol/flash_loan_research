#### Fork Mainnet:

```sh
npx hardhat node --fork https://mainnet.infura.io/v3/d234aacbaae64bfc8a7c0ba9821045e9
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
