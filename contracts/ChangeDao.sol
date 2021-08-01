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
  address payable public communityFundAddress;

  address constant USDC_ADDRESS = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;
  /// @notice Maps NFT token id to clone contract address
  mapping (uint256 => address) public changeMakerClones;

  /// @notice ChangeDao is deployed as an ERC721 contract
  constructor(address payable _communityFundAddress) ERC721('ChangeDAO', 'CHNDv1IMPL') {
    communityFundAddress = _communityFundAddress;
    changeMakerImplementation = address(new ChangeMaker(address(this)));
  }

  /// @notice The ChangeDao contract owner grants approval to become a changemaker
  /// @dev Only the contract owner (changeDao) can call this function
  /// @param _newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address _newChangeMaker) public onlyOwner {
    approvedChangeMakers[_newChangeMaker] = true;
  }

  /// @notice The contract owner removes a changemaker's approval status
  /// @param _changeMaker Address to be set to false in approvedChangeMakers mapping
  function removeApproval(address _changeMaker) public onlyOwner {
    approvedChangeMakers[_changeMaker] = false;
  }

  /* @notice In order to save on storage, the communityFundPercentage is not a variable.  Instead, it is calculated whenever it is needed based on the other two percentages.*/
  function getCommunityFundPercentage() external view returns (uint16){
    return 10000 - (changeMakerPercentage + changeDaoPercentage);
  }

  /// @notice All percentages must be expressed as basis points (96.75% => 9675)
  /// @param _changeMakerPercentage changeMaker share
  /// @param _changeDaoPercentage changeDao share
  /// @param _communityFundPercentage communityFund share
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


  /// @notice Approved changeMakers can register
  /* @dev A clone from the changeMakerImplementation is created. An NFT is minted for the changeMaker's address.  The clone is mapped to the changeMaker's NFT token id.  Then the clone is initialized.*/
  function registerChangeMaker() public {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");

    address changeMakerClone = Clones.clone(changeMakerImplementation);

    changeMakerTokenId.increment();
    uint256 currentToken = changeMakerTokenId.current();

    _safeMint(msg.sender, currentToken);
    changeMakerClones[currentToken] = changeMakerClone;

    ChangeMaker(changeMakerClone).initialize(msg.sender);
  }

  /// @notice Receives donations in ETH, DAI or USDC
  function donate(address _token, uint256 _amount) public payable {
    require(_token == DAI_ADDRESS || _token == USDC_ADDRESS || _token == ETH_ADDRESS);

    if (_token == DAI_ADDRESS || _token == USDC_ADDRESS) {
      IERC20(_token).safeTransferFrom(msg.sender, owner(), _amount);
    }
  }

  /* @notice Only changeDao owner can withdraw the ETH balance from the contract */
  function withdrawEth(uint256 _amount) public {
    require(msg.sender == owner(), "Not authorized to withdraw ETH");
    require(_amount <= address(this).balance, "Amount exceeds balance");
    (bool success,) = msg.sender.call{value: _amount}("");
    require(success, "Failed to withdraw ETH");
  }
}
