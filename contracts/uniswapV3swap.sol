// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.8.15;
pragma abicoder v2;

import "./dependencies/uniswap-0.8/TransferHelper.sol";
import "./dependencies/uniswap-0.8/ISwapRouter.sol";

import "./UniswapV3Oracle.sol";

contract UniswapV3Swap is UniswapV3oracle {
    // NOTE: Does not work with SwapRouter02
    ISwapRouter public constant swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);


    // @dev gets price of token0 in terms of token1 
    // @dev calling estimateAmountOut() in /oracles/UniswapV3Oracle.sol
    function getPrice(address token0, address token1) public view returns (int) {
        address pool = getPool(token0,token1,3000);
        require(pool != address(0), "Pool does not exist on Uniswap V3");
        int price = int(estimateAmountOut(token0, 1e18, 500, token1));
        return price;   
    }


    // @dev Swaps a fixed amount of WETH for a maximum possible amount of DAI
    function swapExactInputSingle(address token0, address token1, uint amountIn) internal returns (uint amountOut) {
        
        TransferHelper.safeTransferFrom(
            token0,
            address(this),
            address(this),
            amountIn
        );
        TransferHelper.safeApprove(token0, address(swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
        .ExactInputSingleParams({
            tokenIn: token0,
            tokenOut: token1,
            // pool fee 0.3%
            fee: 3000,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            // NOTE: In production, this value can be used to set the limit
            // for the price the swap will push the pool to,
            // which can help protect against price impact
            sqrtPriceLimitX96: 0
        });
        amountOut = swapRouter.exactInputSingle(params);
    }

    /*
    // @dev not working yet....
    /// @notice swaps a minimum possible amount of WETH for a fixed amount of DAI.
    function swapExactOutputSingle(uint amountOut, uint amountInMaximum)
        external
        returns (uint amountIn)
    {
        TransferHelper.safeTransferFrom(
            WETH9,
            msg.sender,
            address(this),
            amountInMaximum
        );
        TransferHelper.safeApprove(WETH9, address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter
            .ExactOutputSingleParams({
                tokenIn: WETH9,
                tokenOut: DAI,
                fee: 3000,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        amountIn = swapRouter.exactOutputSingle(params);

        if (amountIn < amountInMaximum) {
            // Reset approval on router
            TransferHelper.safeApprove(WETH9, address(swapRouter), 0);
            // Refund WETH to user
            TransferHelper.safeTransfer(
                WETH9,
                msg.sender,
                amountInMaximum - amountIn
            );
        }
    }*/
}