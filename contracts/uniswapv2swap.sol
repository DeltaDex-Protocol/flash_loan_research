// SPDX-License-Identifier: MIT
pragma solidity =0.8.15;

import "./dependencies/openzeppelin/IERC20.sol";
import "./interfaces/IUniswap.sol";

contract TestUniswap {
  address private constant UNISWAP_V2_ROUTER =
    0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
  address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

  function swapV2(
    address _tokenIn,
    address _tokenOut,
    uint _amountIn,
    uint _amountOutMin,
    address _to
  ) internal {
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }

    IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
      _amountIn,
      _amountOutMin,
      path,
      _to,
      block.timestamp
    );
  }

  function getAmountOutMin(
    address _tokenIn,
    address _tokenOut,
    uint _amountIn
  ) external view returns (uint) {
    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }

    // same length as path
    uint[] memory amountOutMins =
      IUniswapV2Router(UNISWAP_V2_ROUTER).getAmountsOut(_amountIn, path);

    return amountOutMins[path.length - 1];
  }
}