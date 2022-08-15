const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

// DAI_WHALE must be an account, not contract
const WHALE = "0xF885BDD59E5652Fe4940Ca6B8c6ebB88e85A5a40";

const DYDX = "0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e";

describe("Deploy flashloan contract and send weth", () => {
  let accounts;
  let usdc;
  let usdt;
  let whale;

  let curve;

  before(async () => {
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [WHALE],
    });

    whale = await ethers.getSigner(WHALE);
    usdc = await ethers.getContractAt("IERC20", USDC);
    usdt = await ethers.getContractAt("IERC20", USDT);

    accounts = await ethers.getSigners();
  });

  it("Deploy curve swap contract", async () => {
    // deploy flashloan contract
    const CURVE = await ethers.getContractFactory("CurveSwap");
    curve = await CURVE.deploy();
    await curve.deployed();

    console.log("curve swap contract: ", curve.address);

    // get test weth
    console.log("DAI balance of whale", await usdc.balanceOf(WHALE));

    // send 1 weth from whale to account
    const amount = ethers.utils.parseUnits("1");
    await usdc.connect(whale).transfer(accounts[0].address, amount);

    console.log("user balance", await usdc.balanceOf(accounts[0].address));

    await usdc.connect(accounts[0]).approve(curve.address, amount);

    // send weth to flashloan contract
    await curve.connect(accounts[0]).deposit(USDC, amount);

    console.log(
      "balance of flashloan contract",
      await usdc.balanceOf(curve.address)
    );

    /*     await erc20.connect(accounts[0]).approve(curve.address, amount);

    // send weth to flashloan contract
    await curve.connect(accounts[0]).deposit(USDC, amount);

    console.log(
      "balance of flashloan contract",
      await erc20.balanceOf(curve.address)
    ); */
  });

  it("swap", async () => {
    // TOKENS = [DAI,USDC,USDT];

    const tokenIn = ethers.utils.parseUnits("1", 0);
    const tokenOut = ethers.utils.parseUnits("2", 0);

    // swaps total balance of contract
    await curve.swap(tokenIn, tokenOut);

    const curveBalanceUSDC = await usdc.balanceOf(curve.address);
    console.log("curve contract balance USDC: ", curveBalanceUSDC);

    const curveBalanceUSDT = await usdt.balanceOf(curve.address);
    console.log("curve contract balance USDT: ", curveBalanceUSDT);
  });
});
