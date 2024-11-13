// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/V2Dex.sol";
import { ERC20 } from "@uniswap-v2/periphery/test/ERC20.sol";
import { WETH9 } from "@uniswap-v2/periphery/test/WETH9.sol";
import { IUniswapV2Pair } from "@uniswap-v2/core/interfaces/IUniswapV2Pair.sol";

contract V2DexTest is Test {
    V2Dex public v2dex;
    ERC20 public rnt;
    WETH9 public weth;

    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");

        // deploy token
        weth = new WETH9();
        rnt = new ERC20(1_000_000 ether); // 1M tokens

        // deploy V2Dex
        v2dex = new V2Dex(owner, address(weth));

        vm.startPrank(owner);
        // transfer some RNT to user
        rnt.transfer(user, 10_000 ether);
        vm.stopPrank();

        // confirm user balance
        assertEq(rnt.balanceOf(user), 10_000 ether);
    }

    function testCreateAndAddLiquidityRNTETH() public {
        vm.startPrank(user);
        vm.deal(user, 100 ether);

        // create RNT-WETH pair
        address pair = v2dex.createPair(address(rnt), address(weth));
        console.log("RNT-WETH Pair created at:", pair);

        // approve RNT to V2Dex
        rnt.approve(address(v2dex), type(uint256).max);

        uint256 rntAmount = 1000 ether;
        uint256 ethAmount = 1 ether;

        // add liquidity
        (uint256 amountRNT, uint256 amountETH, uint256 liquidity) = v2dex.addLiquidityETH{ value: ethAmount }(
            address(rnt),
            rntAmount,
            0, // minRNT
            0, // minETH
            user,
            block.timestamp + 1
        );

        console.log("Liquidity added successfully");
        console.log("RNT amount:", amountRNT);
        console.log("ETH amount:", amountETH);
        console.log("Liquidity tokens:", liquidity);

        // confirm result
        assertTrue(amountRNT > 0, "RNT amount should be greater than 0");
        assertTrue(amountETH > 0, "ETH amount should be greater than 0");
        assertTrue(liquidity > 0, "Liquidity should be greater than 0");

        vm.stopPrank();
    }

    function testSwapRNTForETH() public {
        // add liquidity first
        vm.startPrank(user);
        vm.deal(user, 100 ether);

        rnt.approve(address(v2dex), type(uint256).max);
        v2dex.addLiquidityETH{ value: 50 ether }(address(rnt), 5000 ether, 0, 0, user, block.timestamp + 1);

        // record balance before swap
        uint256 ethBalanceBefore = user.balance;

        // prepare swap params
        uint256 swapAmount = 100 ether; // use 100 RNT
        address[] memory path = new address[](2);
        path[0] = address(rnt);
        path[1] = address(weth);

        // estimate output amount
        uint256[] memory amounts = v2dex.getAmountsOut(swapAmount, path);
        uint256 amountOutMin = amounts[1] * 99 / 100; // allow 1% slippage

        // execute swap
        v2dex.swapExactTokensForETH(swapAmount, amountOutMin, path, user, block.timestamp + 1);

        // confirm result
        assertTrue(user.balance > ethBalanceBefore, "Should receive ETH");
        assertEq(user.balance - ethBalanceBefore, amounts[1], "Should receive expected amount of ETH");

        vm.stopPrank();
    }

    function testSwapETHForRNT() public {
        // add liquidity first
        vm.startPrank(user);
        vm.deal(user, 100 ether);

        rnt.approve(address(v2dex), type(uint256).max);
        v2dex.addLiquidityETH{ value: 50 ether }(address(rnt), 5000 ether, 0, 0, user, block.timestamp + 1);

        // record balance before swap
        uint256 rntBalanceBefore = rnt.balanceOf(user);

        // prepare swap params
        address[] memory path = new address[](2);
        path[0] = address(weth);
        path[1] = address(rnt);

        uint256 swapAmount = 1 ether;
        uint256[] memory amounts = v2dex.getAmountsOut(swapAmount, path);
        uint256 amountOutMin = amounts[1] * 99 / 100; // allow 1% slippage

        // execute swap
        v2dex.swapExactETHForTokens{ value: swapAmount }(amountOutMin, path, user, block.timestamp + 1);

        // confirm result
        assertTrue(rnt.balanceOf(user) > rntBalanceBefore, "Should receive RNT");
        assertEq(rnt.balanceOf(user) - rntBalanceBefore, amounts[1], "Should receive expected amount");

        vm.stopPrank();
    }

    function testRemoveLiquidityRNTETH() public {
        vm.startPrank(user);
        vm.deal(user, 100 ether);

        // add liquidity
        rnt.approve(address(v2dex), type(uint256).max);
        uint256 rntAmount = 1000 ether;
        uint256 ethAmount = 1 ether;

        (uint256 amountRNT, uint256 amountETH, uint256 liquidity) =
            v2dex.addLiquidityETH{ value: ethAmount }(address(rnt), rntAmount, 0, 0, user, block.timestamp + 1);

        // get pair address and approve
        address pair = v2dex.getPair(address(rnt), address(weth));
        IUniswapV2Pair(pair).approve(address(v2dex), liquidity);

        // record balance before remove liquidity
        uint256 rntBalanceBefore = rnt.balanceOf(user);
        uint256 ethBalanceBefore = user.balance;

        // remove liquidity
        (uint256 removeRNTAmount, uint256 removeETHAmount) =
            v2dex.removeLiquidityETH(address(rnt), liquidity, 0, 0, user, block.timestamp + 1);

        // confirm result
        assertEq(rnt.balanceOf(user) - rntBalanceBefore, removeRNTAmount, "RNT balance change should match");
        assertEq(user.balance - ethBalanceBefore, removeETHAmount, "ETH balance change should match");
        assertEq(IUniswapV2Pair(pair).balanceOf(user), 0, "Should have no LP tokens left");

        vm.stopPrank();
    }

    receive() external payable { }
}
