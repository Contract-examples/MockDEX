# MockDEX-UniswapV2


## Test
```
forge test -vv
```

## Logs
```
Ran 6 tests for test/V2Dex.t.sol:V2DexTest
[PASS] testBuyETH() (gas: 2477161)
Logs:
  RNT sold: 100000000000000000000
  ETH received: 977508480891032805

[PASS] testCreateAndAddLiquidityRNTETH() (gas: 2408290)
Logs:
  RNT-WETH Pair created at: 0xd00a4056aFc8b7aFA46C6aA3aB45783da26d429B
  Liquidity added successfully
  RNT amount: 1000000000000000000000
  ETH amount: 1000000000000000000
  Liquidity tokens: 31622776601683792319

[PASS] testRemoveLiquidityRNTETH() (gas: 2459775)
[PASS] testSellETH() (gas: 2475228)
Logs:
  ETH sold: 1000000000000000000
  RNT received: 97750848089103280585

[PASS] testSwapETHForRNT() (gas: 2470609)
[PASS] testSwapRNTForETH() (gas: 2470008)
Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 2.78ms (7.20ms CPU time)

Ran 1 test suite in 10.22ms (2.78ms CPU time): 6 tests passed, 0 failed, 0 skipped (6 total tests)

Ran 1 test suite in 9.59ms (2.45ms CPU time): 4 tests passed, 0 failed, 0 skipped (4 total tests)
```


## References
- https://github.com/Contract-examples/UniswapV2-clone
