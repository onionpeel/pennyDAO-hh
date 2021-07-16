//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";

///@title Create and manage information about the organizations that register as changeMakers
contract ChangeMakers is OwnableUpgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  ///@notice This structure holds data about a registered changeMaker
  struct ChangeMaker {
    address organization;
    string name;
    uint256 changeMakerId;
  }

  ///@notice Id of the most recently created changeMaker
  CountersUpgradeable.Counter changeMakerCount;
  ///@notice Retrieve a changeMaker address based on the changeMaker's id
  mapping (uint256 => address) public changeMakerAddress;
  ///@notice Retrieve a specific ChangeMaker struct based on the changeMaker's address
  mapping (address => ChangeMaker) public changeMakers;
  ///@notice Retrieves whether or not a particular changeMaker is authorized by ChangeDAO
  mapping (address => bool) isAuthorized;

  ///@notice Emitted when an organization becomes a changeMaker
  event AddedChangeMaker(
    address indexed organization,
    string indexed name,
    uint256 id
  );
  ///@notice Emitted when ChangeDao approves an organization's registration
  event AuthorizedChangeMaker(
    address indexed organization
  );
  ///@notice Emitted when ChangeDao revokes an organization's status as a changeMaker
  event RemovedChangeMakerAuthorization(
    address indexed organization
  );

  ///@notice Upgradeable contracts cannot use constructors. Once the contract is deployed, this initialize function is called to set variables that would normally be set inside of a constructor.
  function initialize() public initializer {
    __Ownable_init();
  }

  /*@notice This is called by the changeMaker only after their registration has been reviewed and ChangeDAO has called authorize() to authorize the changeMaker.*/
  function becomeChangeMaker(
    string memory _name
  )
    public
    authorized
  {
    changeMakerCount.increment();
    uint256 _currentId = changeMakerCount.current();

    ChangeMaker memory newChangeMaker = ChangeMaker(
      msg.sender,
      _name,
      _currentId
    );
    //add changeMaker to mapping
    changeMakers[msg.sender] = newChangeMaker;
    emit AddedChangeMaker(msg.sender, _name, _currentId);
  }

  /*@notice ChangeDAO calls this function to give a changeMaker permission to create a ChangeMaker struct*/
  function authorize(address _changeMaker) public onlyOwner {
    isAuthorized[_changeMaker] = true;
    emit AuthorizedChangeMaker(_changeMaker);
  }

  ///@notice Check whether a changeMaker is authorized
  modifier authorized() {
    require(isAuthorized[msg.sender], "Organization must be authorized to register as changeMaker");
    _;
  }

  ///@notice Check a changeMaker's authorized status
  function checkAuthorization(address _changeMaker) public view returns (bool){
    return isAuthorized[_changeMaker];
  }

  ///@notice ChangeDAO can remove a changeMaker's authorization
  function removeAuthorization(address _changeMaker) public onlyOwner {
    isAuthorized[_changeMaker] = false;
    emit RemovedChangeMakerAuthorization(_changeMaker);
  }
}
