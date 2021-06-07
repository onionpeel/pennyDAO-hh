//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

///@title Create and manage information about the organizations that register as changeMakers
contract ChangeMakers is Ownable {
  ///This structure holds data about a registered changeMaker
  struct ChangeMaker {
    address organization;
    string name;
    uint256 changeMakerId;
  }

  ///@notice Id of the most recently created changeMaker
  uint256 public changeMakerCount;
  ///@notice Retrieve a changeMaker address based on the changeMaker's address
  mapping (uint256 => address) public changeMakerAddress;
  ///@notice Retrieve a specific ChangeMaker struct based on the changeMaker's address
  mapping (address => ChangeMaker) public changeMakers;

  ///@notice Retrieves whether or not a particular changeMaker is authorized
  mapping (address => bool) isAuthorized;

  ///@notice Emitted when an organization becomes a changeMaker
  event AddedChangeMaker(
    address indexed organization,
    string indexed name
  );
  ///@notice Emitted when ChangeDao approves an organization's registration
  event AuthorizedChangeMaker(
    address indexed organization,
    string indexed name
  );
  ///@notice Emitted when ChangeDao revokes an organization's status as a changeMaker
  event RemovedChangeMakerAuthorization(
    address indexed organization,
    string indexed name
  );

  /*@notice This is called by the changeMaker only after their registration has been reviewed and ChangeDAO has called authorize() to authorize the changeMaker.*/
  function becomeChangeMaker(
    string memory name,
  )
    public
    authorized
  {
    changeMakerCount++;
    ChangeMaker memory newChangeMaker = ChangeMaker(
      msg.sender,
      name,
      changeMakerCount
    );
    //add changeMaker to mapping
    changeMakers[msg.sender] = newChangeMaker;
    emit AddedChangeMaker(msg.sender, _name);
  }

  ///@notice Check whether a changeMaker is authorized
  modifier authorized() {
    require(isAuthorized[msg.sender], "Organization must be authorized to register as changeMaker");
    _;
  }

  /*@notice ChangeDAO calls this function to give a changeMaker permission to create a ChangeMaker struct*/
  function authorize(address _changeMaker) public onlyOwner {
    isAuthorized[_changeMaker] = true;
  }

  ///@notice ChangeDAO can check a changeMaker's authorized status
  function checkAuthorization(address _changeMaker) public view returns (bool){
    return isAuthorized[_changeMaker];
  }

  ///@notice ChangeDAO can remove a changeMaker's authorized
  function removeAuthorization(address _changeMaker) public onlyOwner {
    isAuthorized[_changeMaker] = false;
  }
}
