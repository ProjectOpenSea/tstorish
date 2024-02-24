// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Tstorish } from "./Tstorish.sol";

contract Counter is Tstorish {
    event NumberSet(uint256 number);

    uint256 numberSlot = 0x5;

    function number() public view returns (uint256) {
        return _getTstorish(numberSlot);
    }

    function setNumber(uint256 newNumber) public {
        _setTstorish(numberSlot, newNumber);

        emit NumberSet(newNumber);
    }

    function increment() public {
        uint256 currentNumber = _getTstorish(numberSlot);

        uint256 newNumber = currentNumber + 1;

        _setTstorish(numberSlot, newNumber);

        emit NumberSet(newNumber);
    }
}
