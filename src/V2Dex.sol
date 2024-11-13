// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { UniswapV2Factory } from "@uniswap-v2/core/UniswapV2Factory.sol";
import { UniswapV2Router02 } from "@uniswap-v2/periphery/UniswapV2Router02.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract V2Dex is Ownable, ReentrancyGuardTransient, Pausable {
    UniswapV2Factory public immutable factory;
    UniswapV2Router02 public immutable router;
    address public immutable weth;
    address public immutable admin;

    constructor(address _initialAdmin, address _weth) Ownable(_initialAdmin) {
        admin = _initialAdmin;
        weth = _weth;

        factory = new UniswapV2Factory(_initialAdmin);
        router = new UniswapV2Router02(address(factory), weth);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amountA, uint256 amountB, uint256 liquidity)
    {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);

        IERC20(tokenA).approve(address(router), amountADesired);
        IERC20(tokenB).approve(address(router), amountBDesired);

        return router.addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin, to, deadline);
    }

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
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        IERC20(token).approve(address(router), amountTokenDesired);

        return router.addLiquidityETH{ value: msg.value }(
            token, amountTokenDesired, amountTokenMin, amountETHMin, to, deadline
        );
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = factory.getPair(tokenA, tokenB);
        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
        IERC20(pair).approve(address(router), liquidity);

        return router.removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        returns (uint256 amountToken, uint256 amountETH)
    {
        address pair = factory.getPair(token, weth);
        IERC20(pair).transferFrom(msg.sender, address(this), liquidity);
        IERC20(pair).approve(address(router), liquidity);

        return router.removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (uint256 amountA, uint256 amountB)
    {
        return router.removeLiquidityWithPermit(
            tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline, approveMax, v, r, s
        );
    }

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (uint256 amountToken, uint256 amountETH)
    {
        return router.removeLiquidityETHWithPermit(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline, approveMax, v, r, s
        );
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts)
    {
        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(address(router), amountIn);

        return router.swapExactTokensForTokens(amountIn, amountOutMin, path, to, deadline);
    }

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts)
    {
        amounts = router.getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, "V2Dex: EXCESSIVE_INPUT_AMOUNT");

        IERC20(path[0]).transferFrom(msg.sender, address(this), amounts[0]);
        IERC20(path[0]).approve(address(router), amounts[0]);

        return router.swapTokensForExactTokens(amountOut, amountInMax, path, to, deadline);
    }

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256[] memory amounts)
    {
        require(path[0] == weth, "V2Dex: INVALID_PATH");
        return router.swapExactETHForTokens{ value: msg.value }(amountOutMin, path, to, deadline);
    }

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == weth, "V2Dex: INVALID_PATH");
        amounts = router.getAmountsIn(amountOut, path);
        require(amounts[0] <= amountInMax, "V2Dex: EXCESSIVE_INPUT_AMOUNT");

        IERC20(path[0]).transferFrom(msg.sender, address(this), amounts[0]);
        IERC20(path[0]).approve(address(router), amounts[0]);

        return router.swapTokensForExactETH(amountOut, amountInMax, path, to, deadline);
    }

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts)
    {
        require(path[path.length - 1] == weth, "V2Dex: INVALID_PATH");

        IERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        IERC20(path[0]).approve(address(router), amountIn);

        return router.swapExactTokensForETH(amountIn, amountOutMin, path, to, deadline);
    }

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256[] memory amounts)
    {
        require(path[0] == weth, "V2Dex: INVALID_PATH");
        amounts = router.getAmountsIn(amountOut, path);
        require(amounts[0] <= msg.value, "V2Dex: EXCESSIVE_INPUT_AMOUNT");

        amounts = router.swapETHForExactTokens{ value: msg.value }(amountOut, path, to, deadline);

        // Return excess ETH
        if (msg.value > amounts[0]) {
            (bool success,) = msg.sender.call{ value: msg.value - amounts[0] }("");
            require(success, "V2Dex: ETH_TRANSFER_FAILED");
        }

        return amounts;
    }

    function quote(uint256 amountA, uint256 reserveA, uint256 reserveB) external view returns (uint256 amountB) {
        return router.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    )
        external
        view
        returns (uint256 amountOut)
    {
        return router.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    )
        external
        view
        returns (uint256 amountIn)
    {
        return router.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    )
        external
        view
        returns (uint256[] memory amounts)
    {
        return router.getAmountsOut(amountIn, path);
    }

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    )
        external
        view
        returns (uint256[] memory amounts)
    {
        return router.getAmountsIn(amountOut, path);
    }

    function getPair(address tokenA, address tokenB) external view returns (address) {
        return factory.getPair(tokenA, tokenB);
    }

    function createPair(address tokenA, address tokenB) external returns (address) {
        return factory.createPair(tokenA, tokenB);
    }

    receive() external payable { }
}
