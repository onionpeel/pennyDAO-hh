//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import './ChangeMakers.sol';
// import "./IChangeMakers.sol";


contract Projects {
  using Counters for Counters.Counter;
  //This structure holds the data for a single project created by a changeMaker
  struct Project {
    address changeMaker;
    string name;
    uint256 creationTime;
  }

  //References all of the project ids of a particular changeMaker
  mapping (address => Project[]) changeMakerProjects;
  //References a Project struct based on its id
  mapping (uint256 => Project) projectIds;

  uint256 totalProjects;
  Counters.Counter latestProjectId;
  ChangeMakers changeMakers;

  constructor(ChangeMakers _changeMakers) {
    changeMakers = _changeMakers;
  }

  //An authorized changeMaker calls this function to create a new project
  function createProject(
    string memory _name,
    uint256 _creationTime
  )
    public
    returns (bool)
  {
    require(changeMakers.checkAuthorization(msg.sender), 'Not authorized to create a project');
    latestProjectId.increment();
    uint256 currentId = latestProjectId.current();

    Project memory newProject = Project(
      msg.sender,
      _name,
      _creationTime
    );

    projectIds[currentId] = newProject;
    changeMakerProjects[msg.sender].push(newProject);
    return true;
  }

  function getChangeMakerProjects(address _changeMaker) public view returns (Project[] memory){
    return changeMakerProjects[_changeMaker];
  }
}
