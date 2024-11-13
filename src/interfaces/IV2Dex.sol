// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IV2Dex {
    /**
     * @dev Sell ETH for buyToken
     * @param buyToken The token address to buy
     * @param minBuyAmount Minimum amount of buyToken to receive
     * @param deadline Transaction deadline timestamp
     * @return amounts Array of amounts [ETH amount, buyToken amount]
     */
    function sellETH(
        address buyToken,
        uint256 minBuyAmount,
        uint256 deadline
    )
        external
        payable
        returns (uint256[] memory amounts);

    /**
     * @dev Buy ETH with sellToken
     * @param sellToken The token address to sell
     * @param sellAmount Amount of sellToken to sell
     * @param minBuyAmount Minimum amount of ETH to receive
     * @param deadline Transaction deadline timestamp
     * @return amounts Array of amounts [sellToken amount, ETH amount]
     */
    function buyETH(
        address sellToken,
        uint256 sellAmount,
        uint256 minBuyAmount,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts);

    /**
     * @dev Add liquidity for ETH and token pair
     * @param token The token address
     * @param amountTokenDesired Desired amount of token to add
     * @param amountTokenMin Minimum amount of token to add
     * @param amountETHMin Minimum amount of ETH to add
     * @param to Address to receive LP tokens
     * @param deadline Transaction deadline timestamp
     * @return amountToken Actual token amount added
     * @return amountETH Actual ETH amount added
     * @return liquidity Amount of LP tokens minted
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    /**
     * @dev Remove liquidity from ETH and token pair
     * @param token The token address
     * @param liquidity Amount of LP tokens to burn
     * @param amountTokenMin Minimum token amount to receive
     * @param amountETHMin Minimum ETH amount to receive
     * @param to Address to receive the tokens
     * @param deadline Transaction deadline timestamp
     * @return amountToken Amount of token received
     * @return amountETH Amount of ETH received
     */
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amountToken, uint256 amountETH);

    /**
     * @dev Calculate output amount for a given input amount and path
     * @param amountIn Input amount
     * @param path Array of token addresses representing the swap path
     * @return amounts Array of amounts for each step in the path
     */
    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    )
        external
        view
        returns (uint256[] memory amounts);

    /**
     * @dev Get the pair address for two tokens
     * @param tokenA First token address
     * @param tokenB Second token address
     * @return pair The pair contract address
     */
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    /**
     * @dev Create a new pair for two tokens
     * @param tokenA First token address
     * @param tokenB Second token address
     * @return pair The newly created pair contract address
     */
    function createPair(address tokenA, address tokenB) external returns (address pair);
}
