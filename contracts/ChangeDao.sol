//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ChangeDao is Ownable {
  ///Percentages are stored using basis points
  uint16 public changeMakerPercentage = 9800;
  uint16 public changeDaoPercentage = 100;

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;

  constructor() {}

  /// @notice In order to save on storage, the communityFundPercentage is not a variable like the others.  Instead, it is calculated whenever it is needed based on the other two percentages.
  function getCommunityFundPercentage() public view returns (uint16){
    return 10000 - (changeMakerPercentage + changeDaoPercentage);
  }

  /// @notice The ChangeDao contract owner grants approval to become a changemaker
  /// @dev Only the contract owner can call this function
  /// @param _newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address _newChangeMaker) public onlyOwner {
    approvedChangeMakers[_newChangeMaker] = true;
  }

  /// @notice The contract owner removes a changemaker's approval status
  /// @param _changeMaker Address to be set to false in approvedChangeMakers mapping
  function removeApproval(address _changeMaker) public onlyOwner {
    approvedChangeMakers[_changeMaker] = false;
  }

  /// @notice All percentages must be expressed as basis points (9675 => 96.75%)
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

  function register() public {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");

    //More to come...
  }
}
