//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Project.sol";

contract ChangeMaker is ERC721, Ownable, Initializable {
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;
  Counters.Counter public projectTokenId;

  address public changeMakerCloneOwner;
  address public changeDaoContract;
  address immutable projectImplementation;

  address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  /// @notice Maps NFT project token id to project clone
  mapping (uint256 => address) public projectClones;

  /// @notice Sets changeDaoContract address and creates Project implementation contract
  /// @param _changeDaoContract Address of the changeDao contract that called this constructor
  constructor(address _changeDaoContract) ERC721('ChangeMaker', 'CHMKRv1') {
    changeDaoContract = _changeDaoContract;
    projectImplementation = address(new Project());
  }

  /// @notice Contract accepts ETH sent directly to it
  receive() external payable {}

  /// @notice This replaces a constructor in clones
  /// @dev This function is called immediately after the changeMaker clone is created
  /// @param _changeMakerCloneOwner The address of the changeMaker that created the clone
  function initialize(address _changeMakerCloneOwner) public initializer {
    changeMakerCloneOwner = _changeMakerCloneOwner;
  }

  /// @notice A changeMaker creates a new project
  /// @dev Only the changeMaker that is the clone owner can call this function
  /// @param _mintPrice Minimum amount to fund a project and mint a token
  /// @param _mintTotal Total number of tokens that the project will mint
  /// @param _tokenCid The cid that is used for setting the token URI
  function createProject(
    uint256 _mintPrice,
    uint256 _mintTotal,
    string memory _tokenCid,
    address[] memory _permittedTokens
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

    Project(projectClone).initialize(
      _mintPrice,
      _mintTotal,
      _tokenCid,
      address(this), // Address of the changeMaker clone that is creating this project
      _permittedTokens
    );
  }

  /// @notice Retrieve the address of the changeDao contract
  function getChangeDaoAddress() public view returns (address) {
    return owner();
  }

  //????????????????????????
  /* Donation can be changed to accomodate a list of permitted tokens.  Is this needed in v1 since it only accepts ETH, DAI and USDC?  Constants would be cheaper than creating an enumerable set of permitted tokens */

  /// @notice Check that the token is either DAI or USDC
  /// @param _token Token for funding
  function _isTokenAccepted(address _token) private pure returns (bool) {
    if (_token == DAI_ADDRESS) {
      return true;
    } else if (_token == USDC_ADDRESS) {
      return true;
    } else return false;
  }

  /// @notice Receives donations in ETH, DAI or USDC
  /// @param _changeMakerCloneOwner The owner of the changeMaker clone
  /// @param _token Token for funding
  /// @param _amount Funding amount
  function donate(address _changeMakerCloneOwner, address _token, uint256 _amount) public payable {
    require(_isTokenAccepted(_token), "Donations must be in ETH, DAI or USDC");

    IERC20(_token).safeTransferFrom(msg.sender, _changeMakerCloneOwner, _amount);
  }

  /* @notice Only changeMaker clone owner can withdraw the ETH balance from the contract */
  function withdrawEth() public {
    require(msg.sender == changeMakerCloneOwner, "Not authorized to withdraw ETH");

    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success, "Failed to withdraw ETH");
  }
}
