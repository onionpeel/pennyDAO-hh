//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Project.sol";

contract ChangeMaker is ERC721, Ownable, Initializable {
  using Counters for Counters.Counter;
  Counters.Counter public projectTokenId;

  address public changeMakerCloneOwner;
  address public changeDaoContract;
  address immutable projectImplementation;

  /// @notice Maps NFT project token id to project clone
  mapping (uint256 => address) public projectClones;

  constructor(address _changeDaoContract) ERC721('ChangeMaker', 'CHNMKR') {
    changeDaoContract = _changeDaoContract;
    projectImplementation = address(new Project());
  }

  /// @notice This replaces a constructor in clones
  /// @dev This function is called immediately after the changeMaker clone is created
  /// @param _changeMakerCloneOwner The address of the changeMaker that created the clone
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
      address(this) // Address of the changeMaker clone that is creating this project
    );
  }

  /// @notice Receives donations in ETH, DAI or USDC
  function donate(address _token, uint256 _amount) public payable {
    require(_token == DAI || _token == USDC || _token == ETH);

    if (_token == DAI || _token == USDC) {
      IERC20(_token).safeTransferFrom(msg.sender, owner(), _amount);
    }
  }

  /* @notice Only changeMaker clone owner can withdraw the ETH balance from the contract */
  function withdrawEth() public {
    require(msg.sender == changeMakerCloneOwner, "Not authorized to withdraw ETH");

    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success, "Failed to withdraw ETH");
  }
}
