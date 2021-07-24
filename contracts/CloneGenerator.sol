//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ChangeMaker.sol";

/// This is for testing only
contract CloneGenerator {
  address public cloneImplementation;
  address public clone;

  constructor() {
    cloneImplementation = address(new ChangeMaker());
  }

  function createClone() public {
    clone = Clones.clone(cloneImplementation);
  }
}
