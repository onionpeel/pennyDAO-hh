//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

contract ChangeMakers is Ownable {
  //This structure holds data about a registered changeMaker
  struct ChangeMaker {
    address organization;
    string name;
    uint256 registrationTime;
  }

  //Retrieve a specific ChangeMaker struct based on the changeMaker's address
  mapping (address => ChangeMaker) public changeMakers;
  //Retrieves whether or not a particular changeMaker is authenticated
  mapping (address => bool) isAuthorized;
  //?????? is an array a good way to store a reference to the changeMakers????
  ChangeMaker[] public changeMakerArray;

  event AddedChangeMaker(
    address _organization,
    string _name
  );

  event ChangeMakerAuthorized(
    address _organization,
    string _name
  );

  event ChangeMakerAuthorizationRemoved(
    address _organization,
    string _name
  );

  //This is called by the changeMaker only after their registration has been reviewed and ChangeDAO has called authorize() to authorize the changeMaker.
  function becomeChangeMaker(
    string memory _name,
    uint256 _registrationTime
  )
    public
    authorized
    returns (bool)
  {
    //create struct from input data
    ChangeMaker memory newChangeMaker = ChangeMaker(
      msg.sender,
      _name,
      _registrationTime
    );
    //add changeMaker to mapping
    changeMakers[msg.sender] = newChangeMaker;
    //add changeMaker to array
    changeMakerArray.push(newChangeMaker);

    emit AddedChangeMaker(msg.sender, _name);
    return true;
  }

  //Check whether a changeMaker is authenticated
  modifier authorized() {
    require(isAuthorized[msg.sender]);
    _;
  }

  //ChangeDAO calls this function to give a changeMaker permission to create a ChangeMaker struct
  function authorize(address _changeMaker) public onlyOwner returns (bool) {
    isAuthorized[_changeMaker] = true;
    return true;
  }

  //ChangeDAO can check a changeMaker's authentication status
  function checkAuthorization(address _changeMaker) public view returns (bool){
    return isAuthorized[_changeMaker];
  }

  //ChangeDAO can remove a changeMaker's authentication
  function removeAuthorization(address _changeMaker) public onlyOwner returns (bool) {
    isAuthorized[_changeMaker] = false;
    return true;
  }
}
