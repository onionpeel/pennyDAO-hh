//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "hardhat/console.sol";

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ChangeMaker.sol";

/// This is for testing only
/// CMCloneGenerator = ChangeDao.sol
contract CMCloneGenerator {
  address immutable public changeMakerImplementation;
  address public clone;
  uint16 public changeMakerPercentage = 9800;
  uint16 public changeDaoPercentage = 100;

  constructor() {
    changeMakerImplementation = address(new ChangeMaker());
  }

  function createClone() public {
    clone = Clones.clone(changeMakerImplementation);
    ChangeMaker(clone).initialize(msg.sender, address(this));
  }

  function getCommunityFundPercentage() external view returns (uint16){
    return 10000 - (changeMakerPercentage + changeDaoPercentage);
  }
}
