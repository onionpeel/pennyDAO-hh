//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import './ChangeMakers.sol';
import './Sponsors.sol';
import './ImpactNFT_Generator.sol';

///@title changeMakers create projects
contract Projects is Sponsors, Ownable {
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
    bool isFullyFunded;
    bool hasMinted;
  }

  ///@notice References all of the project ids of a particular changeMaker
  mapping (address => uint256[]) public changeMakerProjects;
  ///@notice References a Project struct based on its id
  mapping (uint256 => Project) public projects;
  ///@notice References a project id to all of its sponsor ids
  mapping (uint256 => uint256[]) public projectSponsorIds;

  Counters.Counter sponsorCount;
  Counters.Counter projectCount;

  ChangeMakers changeMakers;
  ImpactNFT_Generator impactNFT_Generator;

  constructor(ChangeMakers _changeMakers, ImpactNFT_Generator _impactNFT_Generator) {
    changeMakers = _changeMakers;
    impactNFT_Generator = _impactNFT_Generator;
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

    //Create a new struct for this project based off of changeMaker's input
    Project memory newProject = Project({
      changeMaker: msg.sender,
      name: _name,
      creationTime: block.timestamp,
      expirationTime: _expirationTime,
      id: _currentProjectId,
      fundingThreshold: _fundingThreshold,
      currentFunding: 0,
      isFullyFunded: false,
      hasMinted: false
    });

    //Set the new project in the projectsIds mapping
    projects[_currentProjectId] = newProject;
    //Add the new project's id to the changeMaker's changeMakerProjects array
    changeMakerProjects[msg.sender].push(_currentProjectId);
  }

  ///@notice A user funds a particular project and becomes a sponsor
  function fundProject(
    uint256 _projectId,
    uint256 _amount
  )
    public
  {
    ///Retrieve the specific project
    Project storage project = projects[_projectId];

    require(project.expirationTime > block.timestamp, "Funding period has ended");
    require(!project.isFullyFunded, "Project is already fully funded");

    project.currentFunding += _amount;

    if(project.currentFunding >= project.fundingThreshold) {
      project.isFullyFunded = true;
    }

    sponsorCount.increment();
    currentSponsorId = sponsorCount.current();
    projectsOfASponsor[msg.sender].push(_projectId);

    ///Create a sponsor struct for the message sender
    Sponsor memory newSponsor = Sponsor({
      sponsorAddress: msg.sender,
      projectId: _projectId,
      sponsorId: currentSponsorId,
      fundingAmount: _amount
    });

    projectSponsorIds[_projectId].push(currentSponsorId);
    sponsors[currentSponsorId] = newSponsor;

    //TRANSFERFROM(MSG.SENDER, ADDRESS(THIS), _AMOUNT);
  }

  ///@notice Retrieves the current funding for a specific project
  function currentProjectFunding(uint256 _projectId) public view returns (uint256) {
    Project storage project = projects[_projectId];
    return project.currentFunding;
  }

  ///@notice Returns bool based on a project's isFullyFunded property
  function isProjectFullyFunded(uint256 _projectId) public view returns (bool) {
    Project storage project = projects[_projectId];
    return project.isFullyFunded;
  }

  /*@notice Returns an array of projects from the changeMakerProjects mapping belonging to a specific changeMaker*/
  function getChangeMakerProjects(address _changeMaker) public view returns (uint256[] memory){
    return changeMakerProjects[_changeMaker];
  }

  ///@notice Returns an array from the projectsSponsorIds mapping
  function getProjectSponsorIds(uint256 _projectId) public view returns (uint256[] memory) {
    return projectSponsorIds[_projectId];
  }

  ///@notice ChangeDao can return funds to sponsors of a specific project in extraordinary circumstances
  function returnFundsToAllSponsors(uint256 _projectId) public onlyOwner {
    Project storage project = projects[_projectId];
    require(project.currentFunding > 0, "Project has no funds to return");

    uint256[] storage _projectSponsorIds = projectSponsorIds[_projectId];
    for(uint256 i = 0; i < _projectSponsorIds.length; i++) {
      Sponsor storage sponsor = sponsors[i];
      //dai_contract_address.transfer(sponsor.sponsorAddress, sponsor.fundingAmount);
    }
  }

  /*@notice The changeMaker reponsible for a given project calls this function when the project is fully funded*/
  function createToken(
    SponsorTokenData[] memory sponsorArray,
    uint256 _projectId
  )
    public
  {
    Project storage project = projects[_projectId];
    require(!project.hasMinted, "NFTs for this project have already been minted");
    require(project.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    project.hasMinted = true;

    impactNFT_Generator.mintTokens(sponsorArray);
  }
}
