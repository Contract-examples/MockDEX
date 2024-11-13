// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { UniswapV2Factory } from "@uniswap-v2/core/UniswapV2Factory.sol";
import { UniswapV2Router02 } from "@uniswap-v2/periphery/UniswapV2Router02.sol";

contract V2Dex is Ownable, ReentrancyGuardTransient, Pausable {
    UniswapV2Factory public immutable factory;
    UniswapV2Router02 public immutable router;
    address public immutable weth;
    address public immutable admin;

    constructor(address initialAdmin, address _weth) Ownable(initialAdmin) {
        admin = initialAdmin;
        weth = _weth;

        factory = new UniswapV2Factory(initialAdmin);
        router = new UniswapV2Router02(address(factory), weth);
    }

    // get pair
    function getPair(address tokenA, address tokenB) external view returns (address) {
        return factory.getPair(tokenA, tokenB);
    }

    // create pair
    function createPair(address tokenA, address tokenB) external returns (address) {
        return factory.createPair(tokenA, tokenB);
    }

    // Receive ETH
    receive() external payable { }
}
