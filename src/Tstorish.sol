// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Tstorish {
    bool private immutable _tstoreInitialSupport;

    bool private _tstoreSupport;

    error TStoreAlreadyActivated();
    error TStoreNotSupported();

    constructor() {
        try new TstoreTest() returns (TstoreTest) {
            _tstoreInitialSupport = true;
        } catch {
            _tstoreInitialSupport = false;
        }
    }

    function __activateTstore() public {
        if (_tstoreInitialSupport || _tstoreSupport) {
            revert TStoreAlreadyActivated();
        }

        try new TstoreTest() returns (TstoreTest) {
            _tstoreSupport = true;
        } catch {
            revert TStoreNotSupported();
        }
    }

    function _setTstorish(uint256 storageSlot, uint256 value) internal {
        if (_tstoreInitialSupport || _tstoreSupport) {
            assembly {
                tstore(storageSlot, value)
            }
        } else {
            assembly {
                sstore(storageSlot, value)
            }
        }
    }

    function _getTstorish(uint256 storageSlot) internal view returns (uint256 value) {
        if (_tstoreInitialSupport || _tstoreSupport) {
            assembly {
                value := tload(storageSlot)
            }
        } else {
            assembly {
                value := sload(storageSlot)
            }
        }
    }

    function _clearTstorish(uint256 storageSlot) internal {
        if (_tstoreInitialSupport || _tstoreSupport) {
            assembly {
                tstore(storageSlot, 0)
            }
        } else {
            assembly {
                sstore(storageSlot, 0)
            }
        }
    }
}

contract TstoreTest {
    constructor() {
        assembly {
            pop(tload(0))
        }
    }
}