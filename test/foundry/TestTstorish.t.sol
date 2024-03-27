// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {TestTstorishContract} from "../../src/test/TestTstorishContract.sol";

contract TestTstorish is Test {
    TestTstorishContract tstorishcontract;

    function setUp() public {
        _deployTstorishContract();
    }

    function _deployTstorishContract() private {
        tstorishcontract = new TestTstorishContract();
    }

    function test_fail_activateTstore_alreadyActivated() public {
        vm.expectRevert(abi.encodeWithSignature("TStoreAlreadyActivated()"));
        vm.prank(address(this), address(this));
        tstorishcontract.__activateTstore();
    }

    function test_fail_activateTstore_onlyDirectCalls() public {
        vm.expectRevert(abi.encodeWithSignature("OnlyDirectCalls()"));
        tstorishcontract.__activateTstore();
    }

    function testSetTstorish() public {
        uint256 storageSlot = 0x1337;
        uint256 value = 500;
        // Set the value in the storage slot
        tstorishcontract.setTstorish(storageSlot, value);
        // Get the value from the storage slot
        uint256 result = tstorishcontract.getTstorish(storageSlot);
        // Assert that the value is equal to the value we set
        assertEq(result, value);
    }

    function testClearTstorish() public {
        uint256 storageSlot = 0x1337;
        uint256 value = 500;
        // Set the value in the storage slot
        tstorishcontract.setTstorish(storageSlot, value);
        // Clear the value in the storage slot
        tstorishcontract.clearTstorish(storageSlot);
        // Get the value from the storage slot
        uint256 result = tstorishcontract.getTstorish(storageSlot);
        // Assert that the value is equal to 0
        assertEq(result, 0);
    }
}
