//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ChangeMaker.sol";

/// This is for testing only
contract CloneGenerator {
  address immutable public changeMakerImplementation;
  address public clone;

  constructor() {
    changeMakerImplementation = address(new ChangeMaker());
  }

  function createClone() public {
    clone = Clones.clone(changeMakerImplementation);
    ChangeMaker(clone).initialize(msg.sender, address(this));
  }
}
