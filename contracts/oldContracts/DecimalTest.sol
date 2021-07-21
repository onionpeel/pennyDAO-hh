//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract DecimalTest {
  uint256 public a;

  function setA() public {
    // a = 999999 * 125;
    a = uint256(124999875) / uint256(10000);
  }

  function divide() public pure returns (uint256) {
    return uint256(7) / uint256(2);
  }

}
