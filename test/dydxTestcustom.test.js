const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

// DAI_WHALE must be an account, not contract
const WHALE = "0xaD0135AF20fa82E106607257143d0060A7eB5cBf";

const DYDX = "0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e";

describe("Deploy flashloan contract and send weth", () => {
  let accounts;
  let erc20;
  let whale;

  let dydx;

  before(async () => {
    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [WHALE],
    });

    whale = await ethers.getSigner(WHALE);
    erc20 = await ethers.getContractAt("IERC20", DAI);

    accounts = await ethers.getSigners();
  });

  it("Deploy flashloan contract", async () => {
    // deploy flashloan contract
    const DYDX = await ethers.getContractFactory("TestDyDxSoloMargin");
    dydx = await DYDX.deploy();
    await dydx.deployed();

    console.log("DYDX flashloan contract: ", dydx.address);

    // get test weth
    console.log("DAI balance of whale", await erc20.balanceOf(WHALE));

    // send 1 weth from whale to account
    const amount = ethers.utils.parseUnits("1");
    await erc20.connect(whale).transfer(accounts[0].address, amount);

    console.log("user balance", await erc20.balanceOf(accounts[0].address));

    await erc20.connect(accounts[0]).approve(dydx.address, amount);

    // send weth to flashloan contract
    await dydx.connect(accounts[0]).deposit(DAI, amount);

    console.log(
      "balance of flashloan contract",
      await erc20.balanceOf(dydx.address)
    );
  });

  it("flashloan", async () => {
    // get max amount of dydx dex contract
    const flashAmount = await erc20.balanceOf(DYDX);
    console.log("flashAmount", flashAmount);

    // flashloan inside of flashloan contract
    const dydxBalance = await erc20.balanceOf(dydx.address);
    console.log("flashloan contract balance: ", dydxBalance);

    const tx = await dydx.initiateFlashLoan(DAI, flashAmount);

    console.log("tx of flashloan", tx);
  });
  /*
  it("instantiate flashloan", async function () {
    const tx = await dydx.initiateFlashLoan(USDC, AMOUNT);

    console.log("tx of flashloan", tx);
  });
  */
});
