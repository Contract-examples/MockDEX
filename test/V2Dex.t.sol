// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "src/V2Dex.sol";

contract V2DexTest is Test {
    // V2Dex public dex;

    function setUp() public {
        // bank = new Bank(address(this));

        // // get code size
        // uint256 codeSize;
        // address bankAddr = address(bank);
        // assembly {
        //     codeSize := extcodesize(bankAddr)
        // }
        // console2.log("[before]: codeSize", codeSize);
    }

    // receive function to receive ETH
    receive() external payable { }
}
