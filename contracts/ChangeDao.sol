//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ChangeMaker.sol";

contract ChangeDao is Ownable, ERC721 {
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;
  Counters.Counter public changeMakerTokenId;
  address immutable public changeMakerImplementation;
  ///Percentages are stored as basis points
  uint16 public changeMakerPercentage = 9800;
  uint16 public changeDaoPercentage = 100;

  address payable public changeDaoWallet;
  address payable public communityFundWallet;

  address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;
  /// @notice Maps NFT token id to clone contract address
  mapping (uint256 => address) public changeMakerClones;

  /// @notice ChangeDao is deployed as an ERC721 contract
  /// @param _communityFundWallet Address that controls funds for the community fund wallet
  /// @param _changeDaoWallet Address that controls funds for the changeDao wallet
  constructor(address payable _communityFundWallet, address payable _changeDaoWallet)
    ERC721('ChangeDAO', 'CHNDv1IMPL')
  {
    changeDaoWallet = _changeDaoWallet;
    communityFundWallet = _communityFundWallet;
    changeMakerImplementation = address(new ChangeMaker(address(this)));
  }

  /// @notice Contract accepts ETH sent directly to it
  receive() external payable {}

  /// @notice The ChangeDao contract owner must first grant approval to become a changemaker
  /// @dev Only the contract owner (changeDao) can call this function
  /// @param _newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address _newChangeMaker) public onlyOwner {
    approvedChangeMakers[_newChangeMaker] = true;
  }

  /// @notice The changeDao contract owner removes a changemaker's approval status
  /// @param _changeMaker Address to be set to false in the approvedChangeMakers mapping
  function removeApproval(address _changeMaker) public onlyOwner {
    approvedChangeMakers[_changeMaker] = false;
  }

  /* @notice In order to save on storage, there is no communityFundPercentage variable.  Instead, it is calculated whenever it is needed based on the other two percentages.*/
  function getCommunityFundPercentage() external view returns (uint16){
    return 10000 - (changeMakerPercentage + changeDaoPercentage);
  }

  /// @notice All percentages must be expressed as basis points (96.75% => 9675)
  /// @param _changeMakerPercentage changeMakerCloneOwner share
  /// @param _changeDaoPercentage changeDaoWallet share
  /// @param _communityFundPercentage communityFundWallet share
  function setPercentageDistributions(
    uint16 _changeMakerPercentage,
    uint16 _changeDaoPercentage,
    uint16 _communityFundPercentage
  )
    public onlyOwner
  {
    require(_changeMakerPercentage + _changeDaoPercentage + _communityFundPercentage == 10000,
      "The sum of the distribution percentages must be equal to 100000");
    changeMakerPercentage = _changeMakerPercentage;
    changeDaoPercentage = _changeDaoPercentage;
  }

  /// @notice Only approved changeMakers can register
  /* @dev A clone is created using the changeMakerImplementation. An NFT is minted for the changeMaker's address.  The clone is mapped to the changeMaker's NFT token id.  Then the clone is initialized.*/
  function registerChangeMaker() public {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");
    /// @notice A clone is created using the changeMakerImplementation
    address payable changeMakerClone = payable(Clones.clone(changeMakerImplementation));

    changeMakerTokenId.increment();
    uint256 currentToken = changeMakerTokenId.current();
    /* @notice An NFT is minted for the changeMaker's address and is mapped to the changeMaker's NFT token id */
    _safeMint(msg.sender, currentToken);
    changeMakerClones[currentToken] = changeMakerClone;
    /// @notice Initialize changeMakerClone
    ChangeMaker(changeMakerClone).initialize(msg.sender);
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
  /// @param _token Token for funding
  /// @param _amount Funding amount
  function donate(address _token, uint256 _amount) public payable {
    require(_isTokenAccepted(_token), "Donations must be in ETH, DAI or USDC");

    IERC20(_token).safeTransferFrom(msg.sender, owner(), _amount);
  }

  /* @notice Only changeMaker clone owner can withdraw the ETH balance from the contract */
  function withdrawEth() public {
    require(msg.sender == changeDaoWallet, "Not authorized to withdraw ETH");

    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success, "Failed to withdraw ETH");
  }

  /// @notice Change the wallet address for the communityFund or changeDao
  ///*****************CREATE THIS FUNCTION
  // function changeWallet() public {
  //
  // }
}
