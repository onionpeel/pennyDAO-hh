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
  }

  ///@notice References all of the project ids of a particular changeMaker
  mapping (address => uint256[]) changeMakerProjects;
  ///@notice References a Project struct based on its id
  mapping (uint256 => Project) projects;
  ///@notice References a project id to all of its sponsor ids
  mapping (uint256 => uint256[]) projectSponsorIds;
  ///@notice Sponsor id maps to its sponsor struct
  mapping (uint256 => Sponsor) sponsors;

  Counters.Counter projectCount;
  // uint256 public currentProjectId;
  ChangeMakers changeMakers;

  constructor(ChangeMakers _changeMakers) {
    changeMakers = _changeMakers;
  }

  ///@notice An authorized changeMaker calls this function to create a new project
  function createProject(
    string memory _name,
    uint256 _expirationTime,
    uint256 _fundingThreshold
  )
    public
  {
    require(changeMakers.checkAuthorization(msg.sender), 'Msg.sender not authorized to create a project');
    //Increment and set project id
    projectCount.increment();
    uint256 _currentProjectId = projectCount.current();
    // currentProjectId = _currentProjectId;

    //Create a new struct for this project based off of changeMaker's input
    // Project memory newProject = Project(
    //   msg.sender,  //changeMaker
    //   _name,  //name
    //   block.timestamp,  //creationTime
    //   _expirationTime,  //expirationTime
    //   _currentProjectId, //id
    //   _fundingThreshold, //fundingThreshold
    //   0, //currentFunding
    //   0, //numberOfFunders
    //   false, //fullyFunded
    //   false, //hasMinted
    //   false //hasSetSponsorRanks
    // );


    //Create a new struct for this project based off of changeMaker's input
    Project memory newProject = Project({
      changeMaker: msg.sender,
      name: _name,
      creationTime: block.timestamp,
      expirationTime: _expirationTime,
      id: _currentProjectId,
      fundingThreshold: _fundingThreshold,
      currentFunding: 0,
      numberOfFunders: 0,
      fullyFunded: false,
      hasMinted: false,
      hasSetSponsorRanks: false
    });


    //Set the new project in the projectsIds mapping
    projects[_currentProjectId] = newProject;
    //Add the new project's id to the changeMaker's changeMakerProjects array
    changeMakerProjects[msg.sender].push(_currentProjectId);
  }

  ///@notice Return an array of projects belonging to a specific changeMaker
  function getChangeMakerProjects(address changeMaker) public view returns (uint256[] memory){
    return changeMakerProjects[changeMaker];
  }
}
