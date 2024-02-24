# Tstorish

A simple utility for working with the `TSTORE` opcode when available, but falling back to `SSTORE` when unavailable.

Inherit `Tstorish` on a contract, then it will:
- activate `TSTORE` on contract deployment if supported on the respective chain
- allow for post-deployment activation by calling `__activateTstore()`
- fall back to `SSTORE` if `TSTORE` is not initially available and has not been activated

Usage:
- `_setTstorish(uint256 storageSlot, uint256 value) internal`
- `_getTstorish(uint256 storageSlot) internal view returns (uint256 value)`
- `_clearTstorish(uint256 storageSlot) internal`
