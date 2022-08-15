const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

// WETH WHALE must be an account, not contract
const WHALE = "0xaD0135AF20fa82E106607257143d0060A7eB5cBf";

describe("Deploy curve swapper contract and implement swap", () => {
  let accounts;
  let erc20;
  let usdt;
  let whale;
  let curve;

  before(async () => {
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [WHALE],
    });

    whale = await ethers.getSigner(WHALE);
    erc20 = await ethers.getContractAt("IERC20", DAI);

    accounts = await ethers.getSigners();
  });

  it("Swaps DAI for USDT", async () => {
    signers = await ethers.getSigners();

    // @dev deploy swapper contract
    const CURVE = await ethers.getContractFactory("CurveSwap");
    curve = await CURVE.deploy();
    await curve.deployed();
    console.log("curve swap contract: ", curve.address);

    console.log("WETH balance of whale", await erc20.balanceOf(WHALE));

    const amount = ethers.utils.parseUnits("1000000");
    await erc20.connect(whale).transfer(accounts[0].address, amount);

    await erc20.connect(accounts[0]).approve(curve.address, amount);

    // send weth to flashloan contract
    await curve.connect(accounts[0]).deposit(DAI, amount);

    const curveBalance = await erc20.balanceOf(curve.address);
    console.log("curve swap contract balance: ", curveBalance);
  });

  it("swap", async () => {
    // TOKENS = [DAI,USDC,USDT];

    const tokenIn = ethers.utils.parseUnits("0", 0);
    const tokenOut = ethers.utils.parseUnits("2", 0);

    const curveBalanceDAI = await erc20.balanceOf(curve.address);
    console.log("curve contract balance DAI: ", curveBalanceDAI);

    // swaps total balance of contract
    await curve.swap(tokenIn, tokenOut);

    usdt = await ethers.getContractAt("IERC20", USDT);

    const curveBalanceUSDT = await usdt.balanceOf(curve.address);
    console.log("curve contract balance USDT: ", curveBalanceUSDT);
  });
});
