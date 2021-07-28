//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Project.sol";

contract ChangeMaker is ERC721, Ownable, Initializable {
  using Counters for Counters.Counter;
  Counters.Counter public projectTokenId;

  address public cloneOwner;
  address public changeDao;
  address immutable projectImplementation;

  /// @notice Maps NFT project token id to project clone
  mapping (uint256 => address) public projectClones;

  constructor() ERC721('ChangeMaker', 'CHNMKR') {
    projectImplementation = address(new Project());
  }

  /// @notice This replaces a constructor in clones
  /// @dev This function is called immediately after the changeMaker clone is created
  /// @param _cloneOwner The address of the changeMaker that created the clone
  /// @param _changeDao The address of the changeDao instance
  function initialize(address _cloneOwner, address _changeDao) public initializer {
    cloneOwner = _cloneOwner;
    changeDao = _changeDao;
  }

  /// @notice A changeMaker creates a new project
  /// @dev Only the changeMaker that is the clone owner can call this function
  /// @param _expirationTime Project cannot receive funding after expiration
  /// @param _fundingGoal Amount required to complete the project funding
  /// @param _minimumSponsorship Sponsors must fund above the minimum amount
  function createProject(
    uint256 _mintPrice,
    uint256 _mintTotal,
    string _tokenName,
    string _tokenSymbol,
    string _tokenCid
  )
    public
  {
    require(msg.sender == cloneOwner, "Only clone owner can create projects");
    /// @notice Create project clone
    address clone = Clones.clone(projectImplementation);
    /// @notice Increment project token id
    projectTokenId.increment();
    uint256 currentToken = projectTokenId.current();
    /// @notice Mint changeMaker's new project NFT that maps to the project clone
    _safeMint(msg.sender, currentToken);
    projectClones[currentToken] = clone;

    Project(clone).initialize(
      _mintPrice,
      _mintTotal,
      _tokenName,
      _tokenSymbol,
      _tokenCid,
      changeDao,
      msg.sender
    );
  }


  function getChangeDaoAddress() external view returns (address) {
    return changeDao;
    /// CAN THIS BE DONE WITH:
    /// RETURN OWNER()
  };

  /// *********** EVERYTHING BELOW IS UNFINISHED **************************

  // Donation
}
