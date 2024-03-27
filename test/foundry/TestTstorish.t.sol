// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {Tstorish} from "../../src/Tstorish.sol";

contract TestTstorish is Test {
    Tstorish tstorish;

    function setUp() public {
        _deployTstorish();
    }

    function _deployTstorish() private {
        tstorish = new Tstorish();
    }

    function testActivateTstore() public {
        vm.expectRevert(abi.encodeWithSignature("TStoreAlreadyActivated()"));
        tstorish.__activateTstore();
    }
}
