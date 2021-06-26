//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// import "@openzeppelin/contracts/utils/Counters.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import './ChangeMakers.sol';
import './Sponsors.sol';
import './ImpactNFT_Generator.sol';


///@title changeMakers create projects
contract Projects is Sponsors, OwnableUpgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  ///This structure holds the data for a single project created by a changeMaker
  struct Project {
    address changeMaker;
    string name;
    uint256 creationTime;
    uint256 expirationTime;
    uint256 id;
    uint256 fundingThreshold;
    uint256 currentFunding;
    uint256 daiFunding;
    uint256 usdcFunding;
    uint256 changeMakerShare;
    uint256 changeDaoShare;
    bool isFullyFunded;
    bool hasMinted;
    bool hasWithdrawnChangeMakerShare;
    bool hasWithdrawnChangeDaoShare;
    bool hasWithdrawnCommunityFundShare;
  }

  ///@notice References all of the project ids of a particular changeMaker
  mapping (address => uint256[]) public changeMakerProjects;
  ///@notice References a Project struct based on its id
  mapping (uint256 => Project) public projects;
  ///@notice References a project id to all of its sponsor ids
  mapping (uint256 => uint256[]) public projectSponsorIds;

  CountersUpgradeable.Counter sponsorCount;
  CountersUpgradeable.Counter projectCount;

  ///contract instances
  ChangeMakers changeMakers;
  ImpactNFT_Generator impactNFT_Generator;
  IERC20 dai;
  IERC20 usdc;
  ///share amounts for project funding; The sum of these must equal 100.
  uint256 changeMakerPercentage;
  uint256 changeDaoPercentage;
  uint256 communityFundPercentage;

  ///@notice Upgradeable contracts cannot use constructors. Once the contract is deployed, this initialize function is called to set variables that would normally be set inside of a constructor.
  function initialize(
    ChangeMakers _changeMakers,
    ImpactNFT_Generator _impactNFT_Generator,
    address daiAddress,
    address usdcAddress
  )
    public
    initializer
  {
    changeMakers = _changeMakers;
    impactNFT_Generator = _impactNFT_Generator;
    dai = IERC20(daiAddress);
    usdc = IERC20(usdcAddress);
    changeMakerShare = 98;
    changeDaoShare = 1;
    communityFundShare = 1;
    ///In the non-upgradeable version of Ownable, the constuctor in the Ownable contract is automatically called when Projects is deployed.  But constructors cannot be used with the proxy pattern, so the Ownable's initialize() function must be called manually.
    __Ownable_init();
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
      daiFunding: 0,
      usdcFunding: 0,
      changeMakerShare: 0,
      changeDaoShare: 0,
      isFullyFunded: false,
      hasMinted: false,
      hasWithdrawnChangeMakerShare: false,
      hasWithdrawnChangeDaoShare: false,
      hasWithdrawnCommunityFundShare: false
    });

    //Set the new project in the projectsIds mapping
    projects[_currentProjectId] = newProject;
    //Add the new project's id to the changeMaker's changeMakerProjects array
    changeMakerProjects[msg.sender].push(_currentProjectId);
  }

  ///@notice A user funds a particular project and becomes a sponsor
  /*@dev The sponsor must give the Projects.sol contract approval to use dai.transferFrom() before calling this function by using dai.approve()*/
  function fundProject(
    uint256 _projectId,
    uint256 _amount,
    string memory _stablecoin
  )
    public
  {
    ///Retrieve the specific project
    Project storage project = projects[_projectId];

    require(project.expirationTime > block.timestamp, "Funding period has ended");
    require(!project.isFullyFunded, "Project is already fully funded");

    ///currentFunding is stored with 18 decimal places.  USDC amounts need to be adjusted since they are stored with only 6.
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      uint256 usdcAdjustedAmount;
      usdcAdjustedAmount = _amount * 10**12;
      project.currentFunding += usdcAdjustedAmount;
      project.usdcFunding += usdcAdjustedAmount;
    } else {
      project.currentFunding += _amount;
      project.daiFunding += _amount;
    }

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
      sponsorFundingAmount: _amount,
      sponsorStablecoin: _stablecoin
    });
    ///The sponsor information gets stored
    projectSponsorIds[_projectId].push(currentSponsorId);
    sponsors[currentSponsorId] = newSponsor;

    ///Transfer the sponsor's stablecoin to Project.sol
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("dai"))) {
      ///The sponsor's DAI get transferred to the Projects.sol contract
      dai.transferFrom(msg.sender, address(this), _amount);
    } else if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      ///The sponsor's USDC get transferred to the Projects.sol contract
      usdc.transferFrom(msg.sender, address(this), _amount);
    }
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

    uint256[] memory _projectSponsorIds = projectSponsorIds[_projectId];
    for(uint256 i = 0; i < _projectSponsorIds.length; i++) {
      Sponsor memory sponsor = sponsors[i + 1];
      dai.transfer(sponsor.sponsorAddress, sponsor.sponsorFundingAmount);
    }
  }

  /*@notice The changeMaker reponsible for a given project calls this function when the project is fully funded*/
  function createTokens(
    SponsorTokenData[] memory sponsorArray,
    uint256 _projectId
  )
    public
  {
    ///check that only the changeMaker responsible for this specific project is calling this function
    bool isMsgSenderProjectOwner;
    uint256[] memory msgSenderProjectsArray = changeMakerProjects[msg.sender];
    for(uint256 i = 0; i < msgSenderProjectsArray.length; i++) {
      if(msgSenderProjectsArray[i] == _projectId) {
        isMsgSenderProjectOwner = true;
      }
    }
    require(isMsgSenderProjectOwner, "Only the authorized changeMaker can call createTokens()");
    ///security checks for the project; prevent re-minting by setting hasMinted to true
    Project storage project = projects[_projectId];
    require(!project.hasMinted, "NFTs for this project have already been minted");
    require(project.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    project.hasMinted = true;
    ///mint the NFT
    impactNFT_Generator.mintTokens(sponsorArray);
  }

  ///@notice Check that the percentage amounts are equal to 100.
  modifier sharePercentagesEqualOneHundred {
    require(changeMakerPercentage + changeDaoPercentage + communityFundPercentage == 100,
      "The share percentages must have a sum of 100");
    _;
  }

  /*@notice The changeMaker that created a specific project can withdraw its share of the funding after minting tokens*/
  function withdrawChangemakerShare(uint256 _projectId) publicsharePercentagesEqualOneHundred {
    ///Security check
    Project storage project = projects[_projectId];
    require(project.hasMinted, "NFTs for this project have already been minted");
    require(project.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    require(!project.hasWithdrawnNinetyEightPercent, "The 98% of project funding has already been withdrawn");

    ///check that only the changeMaker responsible for this specific project is calling this function
    bool isMsgSenderProjectOwner;
    uint256[] memory msgSenderProjectsArray = changeMakerProjects[msg.sender];
    for(uint256 i = 0; i < msgSenderProjectsArray.length; i++) {
      if(msgSenderProjectsArray[i] == _projectId) {
        isMsgSenderProjectOwner = true;
      }
    }
    require(isMsgSenderProjectOwner, "Only the authorized changeMaker can call withdrawChangemakerShare()");

    ///Update state on the project to prevent funding from being withdrawn more than once
    project.hasWithdrawnChangeMakerShare = true;
    //Calculate 98% of final project funding
    project.changeMakerShare = project.currentFunding * changeMakerPercentage / 100;
    ///Transfer 98% of the project funding to the changeMaker that created this project
    dai.transfer(msg.sender, project.changeMakerShare);

    uint256 changeMakerDaiShare = project.daiFunding * changeMakerPercentage / 100;
    uint256 changeMakerUsdcShare = project.usdcFunding * changeMakerPercentage / 100 / 10**12;

    project.changeDaoDaiShare = project.daiFunding * changeDaoPercentage / 100;
    project.changeDaoUsdcShare = project.usdcFunding * changeDaoPercentage / 100 / 10**12;

    project.communityFundDaiShare =
      project.daiFunding - changeMakerDaiShare - project.changeDaoDaiShare;

    project.communityFundUsdcShare =
      (project.usdcFunding / 10**12) - changeMakerUsdcShare - project.changeDaoUsdcShare;

    ///To save gas, check that amounts are greater than zero before attempting transfers
    if (changeMakerDaiShare > 0) {
      dai.transfer(msg.sender, changeMakerDaiShare);
    }
    if (changeMakerUsdcShare > 0) {
      usdc.transfer(msg.sender, changeMakerUsdcShare);
    }
  }

  ///@notice ChangeDAO can withdraw 2% of a project's funding after its tokens have been minted
  function withdrawTwoPercent(uint256 _projectId) public onlyOwner {
    //Security check
    Project storage project = projects[_projectId];
    require(project.hasMinted, "NFTs for this project have already been minted");
    require(project.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    require(!project.hasWithdrawnTwoPercent, "2% has already been withdrawn from this project");

    ///Change state of the project to prevent 2% from being withdrawn more than once
    project.hasWithdrawnTwoPercent = true;
    ///Calculate 2% of the received funding for this project
    uint256 twoPercent = project.currentFunding - (project.currentFunding * 98 / 100);
    ///Transfer the 2% to changeDAO
    dai.transfer(msg.sender, twoPercent);
  }
}
