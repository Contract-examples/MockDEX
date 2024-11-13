# MockDEX-UniswapV2


## Test
```
forge test -vv
```

## Logs
```
Ran 4 tests for test/V2Dex.t.sol:V2DexTest
[PASS] testCreateAndAddLiquidityRNTETH() (gas: 2405656)
Logs:
  RNT-WETH Pair created at: 0xd00a4056aFc8b7aFA46C6aA3aB45783da26d429B
  Liquidity added successfully
  RNT amount: 1000000000000000000000
  ETH amount: 1000000000000000000
  Liquidity tokens: 31622776601683792319

[PASS] testRemoveLiquidityRNTETH() (gas: 2456629)
[PASS] testSwapETHForRNT() (gas: 2466994)
[PASS] testSwapRNTForETH() (gas: 2466533)
Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 2.45ms (3.24ms CPU time)

Ran 1 test suite in 9.59ms (2.45ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```


## References
- https://github.com/Contract-examples/UniswapV2-clone
