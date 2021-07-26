//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Project.sol";

/// This is for testing only
///PrCloneGenerator = ChangeMaker.sol
contract PrCloneGenerator {
  address immutable public projectImplementation;
  address public clone;


  constructor() {
    projectImplementation = address(new Project());
  }

  function createClone() public {
    clone = Clones.clone(projectImplementation);
    // address(this) is only a placeholder.  It should be the changeDao address
    Project(clone).initialize(100, 200, 300, address(this));

  }
}
