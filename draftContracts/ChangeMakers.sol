//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

contract ChangeMakers {
  struct ChangeMaker {
    address organization;
    bytes32 name;
    uint256 registrationTime;
  }

  mapping (address => ChangeMaker) public changeMakers;
  mapping (address => bool) isAuthenticated;
  //??????
  ChangeMaker[] public changeMakerArray;

  function addChangeMaker(address _organization, bytes32 _name, uint256 _registrationTime) public {
  }

  function authorize(address _changeMaker) public onlyOwner {
    isAuthenticated[_changeMaker] = true;
  }

  function checkAuthentication(address _changeMaker) public onlyOwner {
    return isAuthenticated[_changeMaker];
  }

  function removeAuthorization(address _changeMaker) public onlyOwner {
    isAuthenticated[_changeMaker] = false;
  }
}
