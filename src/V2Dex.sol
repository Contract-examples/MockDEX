// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

contract V2Dex is Ownable, ReentrancyGuardTransient, Pausable {
    address public admin;

    constructor(address initialAdmin) Ownable(initialAdmin) {
        admin = initialAdmin;
    }

    // Receive ETH
    receive() external payable { }
}
