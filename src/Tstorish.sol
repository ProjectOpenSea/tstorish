// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Tstorish {
    // Declare a storage variable indicating if TSTORE support has been
    // activated post-deployment.
    bool private _tstoreSupport;

    /*
     * ------------------------------------------------------------------------+
     * Opcode      | Mnemonic         | Stack              | Memory            |
     * ------------------------------------------------------------------------|
     * 60 0x02     | PUSH1 0x02       | 0x02               |                   |
     * 60 0x1e     | PUSH1 0x1e       | 0x1e 0x02          |                   |
     * 61 0x3d5c   | PUSH2 0x3d5c     | 0x3d5c 0x1e 0x02   |                   |
     * 3d          | RETURNDATASIZE   | 0 0x3d5c 0x1e 0x02 |                   |
     *                                                                         |
     * :: store deployed bytecode in memory: (3d) RETURNDATASIZE (5c) TLOAD :: |
     * 52          | MSTORE           | 0x1e 0x02          | [0..0x20): 0x3d5c |
     * f3          | RETURN           |                    | [0..0x20): 0x3d5c |
     * ------------------------------------------------------------------------+
     */
    uint256 constant _TLOAD_TEST_PAYLOAD = 0x6002_601e_613d5c_3d_52_f3;
    uint256 constant _TLOAD_TEST_PAYLOAD_LENGTH = 0x0a;
    uint256 constant _TLOAD_TEST_PAYLOAD_OFFSET = 0x16;

    // Declare an immutable variable to store the initial TSTORE support status.
    bool private immutable _tstoreInitialSupport;

    // Declare an immutable variable to store the tstore test contract address.
    address private immutable _tloadTestContract;

    // Declare a few custom revert error types.
    error TStoreAlreadyActivated();
    error TStoreNotSupported();
    error TloadTestContractDeploymentFailed();
    error OnlyDirectCalls();

    /**
     * @dev Determine TSTORE availability during deployment. This involves
     *      attempting to deploy a contract that utilizes TLOAD as part of the
     *      contract construction bytecode, and configuring initial support for
     *      using TSTORE in place of SSTORE based on the result.
     */
    constructor() {
        // Deploy the contract testing TLOAD support and store the address.
        address tloadTestContract = _prepareTloadTest();

        // Ensure the deployment was successful.
        if (tloadTestContract == address(0)) {
            revert TloadTestContractDeploymentFailed();
        }

        // Determine if TSTORE is supported.
        bool tstoreInitialSupport = _testTload(tloadTestContract);

        // Store the result as an immutable.
        _tstoreInitialSupport = tstoreInitialSupport;

        // Set the address of the deployed TLOAD test contract as an immutable.
        _tloadTestContract = tloadTestContract;
    }

    /**
     * @dev External function to activate TSTORE usage. Does not need to be
     *      called if TSTORE is supported from deployment, and only needs to be
     *      called once. Reverts if TSTORE has already been activated or if the
     *      opcode is not available. Note that this must be called directly from
     *      an externally-owned account to avoid potential reentrancy issues.
     */
    function __activateTstore() external {
        // Ensure this function is triggered from an externally-owned account.
        if (msg.sender != tx.origin) {
            revert OnlyDirectCalls();
        }

        // Determine if TSTORE can potentially be activated.
        if (_tstoreInitialSupport || _tstoreSupport) {
            revert TStoreAlreadyActivated();
        }

        // Determine if TSTORE can be activated and revert if not.
        if (!_testTload(_tloadTestContract)) {
            revert TStoreNotSupported();
        }

        // Mark TSTORE as activated.
        _tstoreSupport = true;
    }

    /**
     * @dev Internal function to set a TSTORISH value.
     *
     * @param storageSlot The slot to write the TSTORISH value to.
     * @param value       The value to write to the given storage slot.
     */
    function _setTstorish(uint256 storageSlot, uint256 value) internal {
        if (_tstoreInitialSupport) {
            assembly {
                tstore(storageSlot, value)
            }
        } else if (_tstoreSupport) {
            assembly {
                tstore(storageSlot, value)
            }
        } else {
            assembly {
                sstore(storageSlot, value)
            }
        }
    }

    /**
     * @dev Internal function to read a TSTORISH value.
     *
     * @param storageSlot The slot to read the TSTORISH value from.
     *
     * @return value The TSTORISH value at the given storage slot.
     */
    function _getTstorish(
        uint256 storageSlot
    ) internal view returns (uint256 value) {
        if (_tstoreInitialSupport) {
            assembly {
                value := tload(storageSlot)
            }
        } else if (_tstoreSupport) {
            assembly {
                value := tload(storageSlot)
            }
        } else {
            assembly {
                value := sload(storageSlot)
            }
        }
    }

    /**
     * @dev Internal function to clear a TSTORISH value.
     *
     * @param storageSlot The slot to clear the TSTORISH value for.
     */
    function _clearTstorish(uint256 storageSlot) internal {
        if (_tstoreInitialSupport) {
            assembly {
                tstore(storageSlot, 0)
            }
        } else if (_tstoreSupport) {
            assembly {
                tstore(storageSlot, 0)
            }
        } else {
            assembly {
                sstore(storageSlot, 0)
            }
        }
    }

    /**
     * @dev Private function to deploy a test contract that utilizes TLOAD as
     *      part of its fallback logic.
     */
    function _prepareTloadTest() private returns (address contractAddress) {
        // Utilize assembly to deploy a contract testing TLOAD support.
        assembly {
            // Write the contract deployment code payload to scratch space.
            mstore(0, _TLOAD_TEST_PAYLOAD)

            // Deploy the contract.
            contractAddress := create(
                0,
                _TLOAD_TEST_PAYLOAD_OFFSET,
                _TLOAD_TEST_PAYLOAD_LENGTH
            )
        }
    }

    /**
     * @dev Private view function to determine if TSTORE/TLOAD are supported by
     *      the current EVM implementation by attempting to call the test
     *      contract, which utilizes TLOAD as part of its fallback logic.
     */
    function _testTload(
        address tloadTestContract
    ) private view returns (bool ok) {
        // Call the test contract, which will perform a TLOAD test. If the call
        // does not revert, then TLOAD/TSTORE is supported. Do not forward all
        // available gas, as all forwarded gas will be consumed on revert.
        (ok, ) = tloadTestContract.staticcall{ gas: gasleft() / 10 }("");
    }
}