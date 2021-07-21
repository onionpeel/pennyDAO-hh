//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ChangeMaker.sol";

contract ChangeDAO is ERC721, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter public changeMakerTokenId;
  address immutable changeMakerImplementation;
  ///Percentages are stored using basis points
  uint256 public changeMakerPercentage = 9800;
  uint256 public changeDaoPercentage = 100;
  uint256 public communityFundPercentage = 100;

  mapping (uint256 => address) public tokenIdToChangeMaker;

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;

  constructor() ERC721('ChangeDAO', 'CHNDv1IMPL') {
    changeMakerImplementation = address(new ChangeMaker());
  }

  /// @notice The contract owner grants approval to become a changemaker
  /// @dev Only the contract owner can call this function
  /// @param newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address newChangeMaker) public onlyOwner {
    approvedChangeMakers[newChangeMaker] = true;
  }

  //THIS FUNCTION ISN'T NECESSARY SINCE approvedChangeMakers IS PUBLIC. SHOULD IT BE REMOVED?
  /// @notice Check if an address has been approved as a changeMaker
  /// @param changeMaker Address to be checked for approval status
  /// @return true = approved
  function checkChangeMakerApproval(address changeMaker) public view returns (bool) {
    return approvedChangeMakers[changeMaker];
  }

  /// @notice The contract owner removes a changemaker's approval status
  /// @param changeMaker Address to be set to false in approvedChangeMakers mapping
  function removeApproval(address changeMaker) public onlyOwner {
    approvedChangeMakers[changeMaker] = false;
  }

  /// @notice All percentages must be expressed as basis points
  function adjustPercentageDistributions(
    uint256 _changeMakerPercentage,
    uint256 _changeDaoPercentage,
    uint256 _communityFundPercentage
  )
    public onlyOwner
  {
    require(_changeMakerPercentage + _changeDaoPercentage + _communityFundPercentage == 10000,
      "The sum of the distribution percentages must be less than or equal to 100000");
    changeMakerPercentage = _changeMakerPercentage;
    changeDaoPercentage = _changeDaoPercentage;
    communityFundPercentage = _communityFundPercentage;
  }

  function register() public {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");

    address clone = Clones.clone(changeMakerImplementation);

    changeMakerTokenId.increment();
    uint256 currentToken = changeMakerTokenId.current();

    _safeMint(msg.sender, currentToken);
    tokenIdToChangeMaker[currentToken] = clone;

    ChangeMaker(clone).initialize();
  }
}
