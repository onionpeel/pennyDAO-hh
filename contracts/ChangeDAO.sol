//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./ChangeMaker.sol";

contract ChangeDAO is ERC721, Ownable {
  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) approvedChangeMakers;

  /// @notice The contract owner grants approval to become a changemaker
  /// @dev Only the contract owner can call this function
  /// @param newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address newChangeMaker) public onlyOwner {
    approvedChangeMakers[newChangeMaker] = true;
  }

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



  using Counters for Counters.Counter;
  Counters.Counter public changeMakerTokenId;
  address immutable changeMakerImplementation;
  mapping (uint256 => address) public changeMakerTokenIdToChangeMakerContract;

  constructor() ERC721('ChangeDAO', 'CHNDv1IMPL') {
    changeMakerImplementation = address(new ChangeMaker());
  }





  uint256 public changeMakerPercentage;
  uint256 public changeDaoPercentage;
  uint256 public communityFundPercentage;

  function adjustPercentageDistributions(
    uint256 _changeMakerPercentage,
    uint256 _changeDaoPercentage,
    uint256 _communityFundPercentage
  )
    public onlyOwner
  {
    require(_changeMakerPercentage + _changeDaoPercentage + _communityFundPercentage == 100,
      "The sum of the distribution percentages must equal 100");
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
    changeMakerTokenIdToChangeMakerContract[currentToken] = clone;

    ChangeMaker(clone).initialize();
  }
}
