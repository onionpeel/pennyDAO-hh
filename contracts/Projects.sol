//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import './ChangeMakers.sol';
import './Sponsors.sol';

///@title changeMakers create projects
contract Projects is Sponsors {
  using Counters for Counters.Counter;
  ///This structure holds the data for a single project created by a changeMaker
  struct Project {
    address changeMaker;
    string name;
    uint256 creationTime;
    uint256 expirationTime;
    uint256 id;
    uint256 fundingThreshold;
    uint256 currentFunding;
    uint256 numberOfFunders;
    bool fullyFunded;
    bool hasMinted;
    bool hasSetSponsorRanks;
    Sponsor[] sponsors;
  }

  ///@notices References all of the project ids of a particular changeMaker
  mapping (address => uint256[]) changeMakerProjects;
  ///@notice References a Project struct based on its id
  mapping (uint256 => Project) projectIds;

  Counters.Counter projectCount;
  uint256 public currentProjectId;
  ChangeMakers changeMakers;

  constructor(ChangeMakers _changeMakers) {
    changeMakers = _changeMakers;
  }

  ///@notice An authorized changeMaker calls this function to create a new project
  function createProject(
    string memory name,
    uint256 expirationTime,
    uint256 fundingThreshold,
  )
    public
  {
    require(changeMakers.checkAuthorization(msg.sender), 'Not authorized to create a project');
    projectCount.increment();
    uint256 _currentId = projectCount.current();
    currentProjectId = _currentId;

    Project memory newProject = Project(
      msg.sender,  //changeMaker
      name,  //name
      block.timestamp,  //creationTime
      expirationTime,  //expirationTime
      _currentId, //id
      fundingThreshold, //fundingThreshold
      0, //currentFunding
      0, //numberOfFunders
      false, //fullyFunded
      false, //hasMinted
      false, //hasSetSponsorRanks
      Sponsor[] //array of sponsors
    );

    projectIds[_currentId] = newProject;
    changeMakerProjects[msg.sender].push(_currentId);
  }

  ///@notice Return an array of projects belonging to a specific changeMaker
  function getChangeMakerProjects(address changeMaker) public view returns (Project[] memory){
    return changeMakerProjects[changeMaker];
  }
}
