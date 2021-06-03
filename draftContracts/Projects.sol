//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/drafts/Counters.sol";
import './ChangeMakers.sol';
// import "./IChangeMakers.sol";


contract Projects {
  using Counters for Counters.Counter;
  //This structure holds the data for a single project created by a changeMaker
  struct Project {
    bytes32 name;
    uint256 creationTime;
    address changeMaker;
  }

  //References all of the project ids of a particular changeMaker
  mapping (address => uint256[]) changeMakerProjectIds;
  //References a Project struct based on its id
  mapping (uint256 => Project) projectIds;

  uint256 totalProjects;
  Counters.Counter _latestProjectId;
  ChangeMakers changeMakers;

  constructor(address _changeMakers) {
    changeMakers = _changeMakers;
  }

  //An authorized changeMaker calls this function to create a new project
  function addProject(
    bytes32 _name,
    uint256 _creationTime,
    address _changeMaker
  )
    public
  {
    require(changeMakers.checkAuthorization(msg.sender), 'Not authorized to create a project');
    _latestProjectId.increment();
  }
}
