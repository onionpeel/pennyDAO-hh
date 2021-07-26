//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./ChangeMaker.sol";

contract ChangeDao is Ownable, ERC721 {
  using Counters for Counters.Counter;
  Counters.Counter public changeMakerTokenId;
  address immutable public changeMakerImplementation;
  ///Percentages are stored as basis points
  uint16 public changeMakerPercentage = 9800;
  uint16 public changeDaoPercentage = 100;

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;
  /// @notice Maps NFT token id to clone contract address
  mapping (uint256 => address) public changeMakerClones;

  /// @notice ChangeDao is deployed as an ERC721 contract
  constructor() ERC721('ChangeDAO', 'CHNDv1IMPL') {
    changeMakerImplementation = address(new ChangeMaker());
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
  function register() public {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");

    address clone = Clones.clone(changeMakerImplementation);

    changeMakerTokenId.increment();
    uint256 currentToken = changeMakerTokenId.current();
    _safeMint(msg.sender, currentToken);
    changeMakerClones[currentToken] = clone;

    ChangeMaker(clone).initialize(msg.sender, address(this));
  }

  /// *********** EVERYTHING BELOW IS UNFINISHED **************************

  ///DONATION

}
