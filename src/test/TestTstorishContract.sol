// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Tstorish} from "../Tstorish.sol";

contract TestTstorishContract is Tstorish {
    constructor() Tstorish() {}

    function setTstorish(uint256 storageSlot, uint256 value) public {
        _setTstorish(storageSlot, value);
    }

    function getTstorish(uint256 storageSlot) public view returns (uint256) {
        return _getTstorish(storageSlot);
    }

    function clearTstorish(uint256 storageSlot) public {
        _clearTstorish(storageSlot);
    }
}
