// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;
pragma experimental ABIEncoderV2;

import "./interfaces/dydxFlashloanBase.sol";
import "./interfaces/ICallee.sol";

import "./uniswapV3swap.sol";
import "./UniswapV2swap.sol";
import "./curveSwapper.sol";

import "hardhat/console.sol";

contract TestDyDxSoloMargin is ICallee, DydxFlashloanBase, UniswapV2Swap, UniswapV3Swap, CurveSwapper {
  address private constant SOLO = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;

  // address USDC = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  address private owner;

  // token to initial balance in contract
  mapping(address => uint) public balances;

  constructor () {
    owner = msg.sender;
  }

  struct MyCustomData {
    address token;
    uint repayAmount;
  }

  function deposit(address _token, uint _amount) external {
    IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    balances[_token] = _amount;
  }

  function withdraw(address _token, uint _amount) external {
    IERC20(_token).transfer(owner, _amount);
  }


  function initiateFlashLoan(address _token, uint _amount) external {
    ISoloMargin solo = ISoloMargin(SOLO);

    // Get marketId from token address
    /*
    0	WETH
    1	SAI
    2	USDC
    3	DAI
    */
    uint marketId = _getMarketIdFromTokenAddress(SOLO, _token);

    // Calculate repay amount (_amount + (2 wei))
    uint repayAmount = _getRepaymentAmountInternal(_amount);
    IERC20(_token).approve(SOLO, repayAmount);

    /*
    1. Withdraw
    2. Call callFunction()
    3. Deposit back
    */

    Actions.ActionArgs[] memory operations = new Actions.ActionArgs[](3);

    operations[0] = _getWithdrawAction(marketId, _amount);
    operations[1] = _getCallAction(
      abi.encode(MyCustomData({token: _token, repayAmount: repayAmount}))
    );
    operations[2] = _getDepositAction(marketId, repayAmount);

    Account.Info[] memory accountInfos = new Account.Info[](1);
    accountInfos[0] = _getAccountInfo();

    solo.operate(accountInfos, operations);
  }


  function callFunction(
    address sender,
    Account.Info memory account,
    bytes memory data
  ) public override {
    require(msg.sender == SOLO, "!solo");
    require(sender == address(this), "!this contract");

    MyCustomData memory mcd = abi.decode(data, (MyCustomData));

    // @dev flashloan balance]
    console.log("line 91");
    uint bal = IERC20(mcd.token).balanceOf(address(this)) - balances[WETH];
    console.log("flashloan balance");
    console.logUint(bal);

    // @dev required amount to repay
    uint repayAmount = mcd.repayAmount;
    console.log("repayAmount");
    console.logUint(repayAmount);

    require(IERC20(mcd.token).balanceOf(address(this)) >= repayAmount, "bal > repay");

    // arbitrage code //

    // swap on v3
    swapExactInputSingle(DAI, USDC, bal);
    console.log("usdc balance swap 1");
    uint usdc_val = IERC20(USDC).balanceOf(address(this));
    console.logUint(usdc_val);

    // curve swap 
    // TOKENS = [DAI,USDC,USDT];
    swap(1,0);
    /* 
    // swap on v2
    uint minAmount = 1e18;
    swapV2(USDC,WETH,usdc_bal,minAmount);
    */
    uint dai_val = IERC20(DAI).balanceOf(address(this));
    console.log("dai balance swap 2");
    console.logUint(dai_val);

  }
}
// Solo margin contract mainnet - 0x1e0447b19bb6ecfdae1e4ae1694b0c3659614e4e
// payable proxy - 0xa8b39829cE2246f89B31C013b8Cde15506Fb9A76




