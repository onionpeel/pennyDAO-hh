//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract Temp {
  uint public value;

  function inner() public pure returns(uint _sum) {
    _sum = 4 + 3;
  }

  function add(uint _a) public pure returns (uint) {
    return _a + 3;
  }

  function setValue() public {
    value = add(inner());
  }
}
