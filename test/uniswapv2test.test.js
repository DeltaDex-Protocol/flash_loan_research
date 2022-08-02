const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

// WETH WHALE must be an account, not contract
const WHALE = "0x2093b4281990a568c9d588b8bce3bfd7a1557ebd";

describe("Deploy Uniswap V2 swapper contract and implement swap", () => {
  let accounts;
  let erc20;
  let whale;

  before(async () => {
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [WHALE],
    });

    whale = await ethers.getSigner(WHALE);
    erc20 = await ethers.getContractAt("IERC20", WETH);

    accounts = await ethers.getSigners();
  });

  it("Swaps WETH for DAI", async () => {
    signers = await ethers.getSigners();

    // @dev deploy swapper contract
    const V2 = await ethers.getContractFactory("UniswapV2Swap");
    const v2 = await V2.deploy();
    await v2.deployed();
    console.log("v2 swap contract: ", v2.address);

    const amount = await erc20.balanceOf(WHALE);
    console.log("WETH balance of whale", await erc20.balanceOf(WHALE));
    // expect(await erc20.balanceOf(WHALE)).to.gte(amount);

    await erc20.connect(whale).transfer(v2.address, amount);

    const v2Balance = await erc20.balanceOf(v2.address);
    console.log("v2 swap contract balance: ", v2Balance);

    // @dev price of token on uniswap V2
    const amountOutMin = await v2.getAmountOutMin(WETH, DAI);
    console.log("Price of WETH in DAI on V2:", amountOutMin);

    // @dev function params solidity
    /*
    swapV2(
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _amountOutMin,
    address _to
  )
    */
    const amountIn = await ethers.utils.parseUnits("1");
    const minOut = await ethers.utils.parseUnits("1");
    console.log("amount In", amountIn);

    const tx = await v2.swapV2(WETH, DAI, amountIn, minOut);
    await tx.wait();

    erc20_DAI = await ethers.getContractAt("IERC20", DAI);

    const DAIbalance = await erc20_DAI.balanceOf(v2.address);
    console.log("dai balance", DAIbalance);
  });
});
