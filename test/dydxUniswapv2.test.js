const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const USDC = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";

// DAI_WHALE must be an account, not contract
const WHALE = "0x2093b4281990a568c9d588b8bce3bfd7a1557ebd";

describe("Deploy flashloan contract and send USDC", () => {
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

  it("flashloan", async () => {
    signers = await ethers.getSigners();

    const DYDX = await ethers.getContractFactory("TestDyDxSoloMargin");
    const dydx = await DYDX.deploy();
    await dydx.deployed();

    const amount = await erc20.balanceOf(WHALE);
    console.log("DAI balance of whale", await erc20.balanceOf(WHALE));
    // expect(await erc20.balanceOf(WHALE)).to.gte(amount);

    await erc20.connect(whale).transfer(dydx.address, amount);

    console.log("DYDX flashloan contract: ", dydx.address);

    const dydxBalance = await erc20.balanceOf(dydx.address);

    console.log("flashloan contract balance: ", dydxBalance);

    const flashAmount = ethers.utils.parseUnits("100");
    const balance = await dydx.testSwap(WETH, flashAmount);

    console.log("balance", balance);

    // const flashAmount = ethers.utils.parseUnits("100");

    // const tx = await dydx.initiateFlashLoan(WETH, flashAmount);
  });
  /*
  it("instantiate flashloan", async function () {
    const tx = await dydx.initiateFlashLoan(USDC, AMOUNT);

    console.log("tx of flashloan", tx);
  });
  */
});
