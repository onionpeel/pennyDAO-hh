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
  // struct Project {
  //   address changeMaker;
  //   string name;
  //   uint256 expirationTime;
  //   uint256 id;
  //   uint256 fundingThreshold;
  //   uint256 currentFunding;
  //   uint256 daiFunding;
  //   uint256 usdcFunding;
  //   bool isFullyFunded;
  //   bool hasMinted;
  //   bool hasWithdrawnChangeMakerShare;
  //   bool hasWithdrawnChangeDaoShare;
  //   bool hasWithdrawnCommunityFundShare;
  // }

  struct Project {
    address changeMaker;
    string name;
    uint256 expirationTime;
    uint256 id;
    bool hasMinted;
    ProjectFunding projectFunding;
  }

  struct ProjectFunding {
    uint256 fundingThreshold;
    uint256 currentFunding;
    bool isFullyFunded;
    bool hasWithdrawnChangeMakerShare;
    bool hasWithdrawnChangeDaoShare;
    bool hasWithdrawnCommunityFundShare;
    DAIFunding daiFunding;
    USDCFunding usdcFunding;
  }

  struct DAIFunding {
    uint256 daiFundingAmount;
    uint256 changeMakerDaiShare;
    uint256 changeDaoDaiShare;
    uint256 communityFundDaiShare;
  }

  struct USDCFunding {
    uint256 usdcFundingAmount;
    uint256 changeMakerUsdcShare;
    uint256 changeDaoUsdcShare;
    uint256 communityFundUsdcShare;
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
    changeMakerPercentage = 98;
    changeDaoPercentage = 1;
    communityFundPercentage = 1;
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
    // Project memory newProject = Project({
    //   changeMaker: msg.sender,
    //   // name: _name,
    //   // creationTime: block.timestamp,
    //   expirationTime: _expirationTime,
    //   id: _currentProjectId,
    //   fundingThreshold: _fundingThreshold,
    //   currentFunding: 0,
    //   daiFunding: 0,
    //   usdcFunding: 0,
    //   isFullyFunded: false,
    //   hasMinted: false,
    //   hasWithdrawnChangeMakerShare: false,
    //   hasWithdrawnChangeDaoShare: false,
    //   hasWithdrawnCommunityFundShare: false
    // });

    ///Create a new struct containing information about this project based off of changeMaker's input
    // Project memory newProject;
    // newProject.changeMaker = msg.sender;
    // newProject.name = _name;
    // newProject.expirationTime = _expirationTime;
    // newProject.id = _currentProjectId;
    //
    // ///Create a struct for this project containing funding information
    // Funding memory funding;
    // funding.id = _currentProjectId;
    // funding.fundingThreshold = _fundingThreshold;

    //Create a new struct for this project based off of changeMaker's input
    Project memory newProject;
    newProject.changeMaker = msg.sender;
    newProject.name = _name;
    newProject.expirationTime = _expirationTime;
    newProject.id = _currentProjectId;
    newProject.projectFunding.fundingThreshold = _fundingThreshold;



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
    require(!project.projectFunding.isFullyFunded, "Project is already fully funded");

    ///currentFunding is stored with 18 decimal places.  USDC amounts need to be adjusted since they are stored with only 6.
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      uint256 usdcAdjustedAmount;
      usdcAdjustedAmount = _amount * 10**12;
      project.projectFunding.currentFunding += usdcAdjustedAmount;
      project.projectFunding.usdcFunding.usdcFundingAmount += usdcAdjustedAmount;
    } else {
      project.projectFunding.currentFunding += _amount;
      project.projectFunding.daiFunding.daiFundingAmount += _amount;
    }

    if(project.projectFunding.currentFunding >= project.projectFunding.fundingThreshold) {
      project.projectFunding.isFullyFunded = true;
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
    return project.projectFunding.currentFunding;
  }

  ///@notice Returns bool based on a project's isFullyFunded property
  function isProjectFullyFunded(uint256 _projectId) public view returns (bool) {
    Project storage project = projects[_projectId];
    return project.projectFunding.isFullyFunded;
  }

  /*@notice Returns an array of projects from the changeMakerProjects mapping belonging to a specific changeMaker*/
  function getChangeMakerProjects(address _changeMaker) public view returns (uint256[] memory){
    return changeMakerProjects[_changeMaker];
  }

  // ///@notice Returns an array from the projectsSponsorIds mapping
  function getProjectSponsorIds(uint256 _projectId) public view returns (uint256[] memory) {
    return projectSponsorIds[_projectId];
  }

  ///@notice ChangeDao can return funds to sponsors of a specific project in extraordinary circumstances
  function returnFundsToAllSponsors(uint256 _projectId) public onlyOwner {
    Project storage project = projects[_projectId];
    require(project.projectFunding.currentFunding > 0, "Project has no funds to return");

    uint256[] memory _projectSponsorIds = projectSponsorIds[_projectId];
    for(uint256 i = 0; i < _projectSponsorIds.length; i++) {
      Sponsor memory sponsor = sponsors[i + 1];

      if(keccak256(abi.encodePacked(sponsor.sponsorStablecoin)) == keccak256(abi.encodePacked("dai"))) {
        ///The sponsor's DAI gets returned to the sponsor
        dai.transfer(sponsor.sponsorAddress, sponsor.sponsorFundingAmount);
      } else if(keccak256(abi.encodePacked(sponsor.sponsorStablecoin)) ==
          keccak256(abi.encodePacked("usdc"))) {
        ///The sponsor's USDC gets returned to the sponsor
        usdc.transfer(sponsor.sponsorAddress, sponsor.sponsorFundingAmount);
      }
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
    require(project.projectFunding.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    project.hasMinted = true;
    ///mint the NFT
    impactNFT_Generator.mintTokens(sponsorArray);
  }


  ///@notice ChangeDAO can change the percentage of project funding that goes to the changeMaker
  function adjustChangeMakerPercentage(uint256 _newPercentage) public onlyOwner {
    changeMakerPercentage = _newPercentage;
  }

  ///@notice ChangeDAO can change the percentage of project funding that goes to ChangeDAO
  function adjustChangeDaoPercentage(uint256 _newPercentage) public onlyOwner {
    changeDaoPercentage = _newPercentage;
  }

  ///@notice ChangeDAO can change the percentage of project funding that goes to the community fund
  function adjustCommunityFundPercentage(uint256 _newPercentage) public onlyOwner {
    communityFundPercentage = _newPercentage;
  }

  ///@notice Check that the percentage amounts are equal to 100.
  function sharePercentagesEqualOneHundred() public view returns (bool) {
    return changeMakerPercentage + changeDaoPercentage + communityFundPercentage == 100;
  }

  /*@notice The changeMaker that created a specific project can withdraw its share of the funding after minting tokens*/
  function withdrawChangemakerShare(uint256 _projectId) public {
    ///Check that percentage distributions equal 100
    require(sharePercentagesEqualOneHundred(), "Percentage distributions do not equal 100");
    ///Security check
    Project storage project = projects[_projectId];
    require(project.hasMinted, "NFTs for this project have already been minted");
    require(project.projectFunding.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    require(!project.projectFunding.hasWithdrawnChangeMakerShare,
      "The changeMaker funding has already been withdrawn");

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
    project.projectFunding.hasWithdrawnChangeMakerShare = true;

    ///Set the amount of DAI and USDC the changeMaker will receive from this project
    project.projectFunding.daiFunding.changeMakerDaiShare =
      project.projectFunding.daiFunding.daiFundingAmount * changeMakerPercentage / 100;
    project.projectFunding.usdcFunding.changeMakerUsdcShare =
      project.projectFunding.usdcFunding.usdcFundingAmount * changeMakerPercentage / 100 / 10**12;
    ///Set the amount of DAI and USDC ChangeDAO will receive from this project
    project.projectFunding.daiFunding.changeDaoDaiShare =
      project.projectFunding.daiFunding.daiFundingAmount * changeDaoPercentage / 100;
    project.projectFunding.usdcFunding.changeDaoUsdcShare =
      project.projectFunding.usdcFunding.usdcFundingAmount * changeDaoPercentage / 100 / 10**12;
    ///Set the amount of DAI and USDC the community fund will receive from this project
    project.projectFunding.daiFunding.communityFundDaiShare =
      project.projectFunding.daiFunding.daiFundingAmount -
      project.projectFunding.daiFunding.changeMakerDaiShare -
      project.projectFunding.daiFunding.changeDaoDaiShare;
    project.projectFunding.usdcFunding.communityFundUsdcShare =
      (project.projectFunding.usdcFunding.usdcFundingAmount / 10**12) -
      project.projectFunding.usdcFunding.changeMakerUsdcShare -
      project.projectFunding.usdcFunding.changeDaoUsdcShare;

    ///To save gas, check that amounts are greater than zero before attempting transfers
    if (project.projectFunding.daiFunding.changeMakerDaiShare > 0) {
      dai.transfer(msg.sender, project.projectFunding.daiFunding.changeMakerDaiShare);
    }
    if (project.projectFunding.usdcFunding.changeMakerUsdcShare > 0) {
      usdc.transfer(msg.sender, project.projectFunding.usdcFunding.changeMakerUsdcShare);
    }
  }

  ///@notice ChangeDAO can withdraw set percentage of a project's funding after its tokens have been minted
  ///@notice This function will only send funds to ChangeDAO after the changeMaker has called withdrawChangemakerShare() for this project
  function withdrawChangeDaoShare(uint256 _projectId) public onlyOwner {
    //Security check
    Project storage project = projects[_projectId];
    require(project.hasMinted, "NFTs for this project have already been minted");
    require(project.projectFunding.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    require(!project.projectFunding.hasWithdrawnChangeDaoShare,
      "ChangeDAO share has already been withdrawn from this project");

    project.projectFunding.hasWithdrawnChangeDaoShare = true;

    ///To save gas, check that amounts are greater than zero before attempting transfers
    if (project.projectFunding.daiFunding.changeDaoDaiShare > 0) {
      dai.transfer(msg.sender, project.projectFunding.daiFunding.changeDaoDaiShare);
    }
    if (project.projectFunding.usdcFunding.changeDaoUsdcShare > 0) {
      usdc.transfer(msg.sender, project.projectFunding.usdcFunding.changeDaoUsdcShare);
    }
  }


  ///!!!!!!!!!!!!!!!!THE PERMISSION NEEDS TO BE SET SO ONLY THE COMMUNITY FUND ADDRESS CAN CALL THIS FUNCTION
  ///@notice The community fund can withdraw set percentage of a project's funding after its tokens have been minted
  ///@notice This function will only send funds to the community fund after the changeMaker has called withdrawChangemakerShare() for this project
  function withdrawCommunityFundShare(uint256 _projectId) public  {
    //Security check
    Project storage project = projects[_projectId];
    require(project.hasMinted, "NFTs for this project have already been minted");
    require(project.projectFunding.isFullyFunded, "Project needs to be fully funded before NFTs are minted");
    require(!project.projectFunding.hasWithdrawnCommunityFundShare,
      "ChangeDAO share has already been withdrawn from this project");

    project.projectFunding.hasWithdrawnCommunityFundShare = true;

    ///To save gas, check that amounts are greater than zero before attempting transfers
    if (project.projectFunding.daiFunding.communityFundDaiShare > 0) {
      dai.transfer(msg.sender, project.projectFunding.daiFunding.communityFundDaiShare);
    }
    if (project.projectFunding.usdcFunding.communityFundUsdcShare > 0) {
      usdc.transfer(msg.sender, project.projectFunding.usdcFunding.communityFundUsdcShare);
    }
  }
}
