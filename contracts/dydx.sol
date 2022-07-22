// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;
pragma experimental ABIEncoderV2;

import "./interfaces/dydxFlashloanBase.sol";
import "./interfaces/ICallee.sol";

import "./uniswapV3swap.sol";
import "./uniswapv2swap.sol";


contract TestDyDxSoloMargin is ICallee, DydxFlashloanBase, Swapper, TestUniswap {
  address private constant SOLO = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;


  address USDC = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;


  struct MyCustomData {
    address token;
    uint repayAmount;
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

  uint public balance1 = 0;
  uint public repay = 0;
  int public balance2 = 0;


  function callFunction(
    address sender,
    Account.Info memory account,
    bytes memory data
  ) public override {
    require(msg.sender == SOLO, "!solo");
    require(sender == address(this), "!this contract");

    MyCustomData memory mcd = abi.decode(data, (MyCustomData));
    uint repayAmount = mcd.repayAmount;

    uint bal = IERC20(mcd.token).balanceOf(address(this));
    require(bal >= repayAmount, "bal < repay");

    // log balances

    balance1 = bal;
    repay = repayAmount;
    balance2 = int(bal) - int(repayAmount);

    // CUSTOM CODE //

    uint loanAmount = repayAmount + 2;
    uint minAmount = 1801e18;

    

    uint usdcV3 = swapExactInputSingle(WETH, USDC, loanAmount);

    swapV2(USDC,WETH,usdcV3,minAmount,address(this));

  }
}
// Solo margin contract mainnet - 0x1e0447b19bb6ecfdae1e4ae1694b0c3659614e4e
// payable proxy - 0xa8b39829cE2246f89B31C013b8Cde15506Fb9A76

// https://etherscan.io/tx/0xda79adea5cdd8cb069feb43952ea0fc510e4b6df4a270edc8130d8118d19e3f4