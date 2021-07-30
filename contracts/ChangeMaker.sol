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

  address public changeMakerCloneOwner;
  address public changeDaoContractAddress;
  address immutable projectImplementation;

  /// @notice Maps NFT project token id to project clone
  mapping (uint256 => address) public projectClones;

  constructor(address _changeDaoContractAddress) ERC721('ChangeMaker', 'CHNMKR') {
    changeDaoContractAddress = _changeDaoContractAddress;
    projectImplementation = address(new Project());
  }

  /// @notice This replaces a constructor in clones
  /// @dev This function is called immediately after the changeMaker clone is created
  /// @param _changeMakerCloneloneOwner The address of the changeMaker that created the clone
  /// @param _changeDaoContractAddress The address of the changeDaoContractAddress instance
  function initialize(address _changeMakerCloneOwner, address _changeDaoAddress) public initializer {
    changeMakerCloneOwner = _changeMakerCloneOwner;
  }

  /// @notice A changeMaker creates a new project
  /// @dev Only the changeMaker that is the clone owner can call this function
  /// @param _mintPrice Minimum amount to fund a project and mint a token
  /// @param _mintTotal Total number of tokens that the project will mint
  /// @param _tokenName ChangeMaker sets the token name
  /// @param _tokenSymbol ChangeMaker sets the token symbol
  /// @param _tokenCid The cid that is used for setting the token URI
  function createProject(
    uint256 _mintPrice,
    uint256 _mintTotal,
    string _tokenName,
    string _tokenSymbol,
    string _tokenCid
  )
    public
  {
    require(msg.sender == changeMakerCloneOwner, "Only clone owner can create projects");
    /// @notice Create project clone
    address projectClone = Clones.clone(projectImplementation);
    /// @notice Increment project token id
    projectTokenId.increment();
    uint256 currentToken = projectTokenId.current();
    /// @notice Mint changeMaker's new project NFT that maps to the project clone
    _safeMint(msg.sender, currentToken);
    projectClones[currentToken] = projectClone;

    Project(clone).initialize(
      _mintPrice,
      _mintTotal,
      _tokenName,
      _tokenSymbol,
      _tokenCid,
      msg.sender // EOA of a changeMaker
    );
  }

// ????????????????????????????????????
  function getChangeDaoOwnerAddress() external view returns (address) {
    return changeDaoOwnerAddress;
    /// CAN THIS BE DONE WITH:
    /// RETURN OWNER()
  }

  /// *********** EVERYTHING BELOW IS UNFINISHED **************************

  // Donation
}
