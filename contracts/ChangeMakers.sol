//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

contract ChangeMakers is Ownable {
  //This structure holds data about a registered changeMaker
  struct ChangeMaker {
    address organization;
    bytes32 name;
    uint256 registrationTime;
  }

  //Retrieve a specific ChangeMaker struct based on the changeMaker's address
  mapping (address => ChangeMaker) public changeMakers;
  //Retrieves whether or not a particular changeMaker is authenticated
  mapping (address => bool) isAuthenticated;
  //?????? is an array a good way to store a reference to the changeMakers????
  ChangeMaker[] public changeMakerArray;

  //This is called by the changeMaker only after their registration has been reviewed and ChangeDAO has called authorize() to authorize the changeMaker.
  function addChangeMaker(
    address _organization,
    bytes32 _name,
    uint256 _registrationTime
  )
    public
    authorized
  {}

  //Check whether a changeMaker is authenticated
  modifier authorized() {
    require(isAuthenticated[msg.sender]);
    _;
  }

  //ChangeDAO calls this function to give a changeMaker permission to create a ChangeMaker struct
  function authorize(address _changeMaker) public onlyOwner {
    isAuthenticated[_changeMaker] = true;
  }

  //ChangeDAO can check a changeMaker's authentication status
  function checkAuthentication(address _changeMaker) public onlyOwner returns (bool){
    return isAuthenticated[_changeMaker];
  }

  //ChangeDAO can remove a changeMaker's authentication
  function removeAuthorization(address _changeMaker) public onlyOwner {
    isAuthenticated[_changeMaker] = false;
  }
}
