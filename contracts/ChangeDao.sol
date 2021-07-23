//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ChangeDao is Ownable {
  ///Percentages are stored using basis points
  uint16 public changeMakerPercentage = 9800;
  uint16 public changeDaoPercentage = 1000;
  uint16 public communityFundPercentage = 1000;

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;

  constructor() {}

  /// @notice The ChageDao contract owner grants approval to become a changemaker
  /// @dev Only the contract owner can call this function
  /// @param newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address _newChangeMaker) external onlyOwner {
    approvedChangeMakers[_newChangeMaker] = true;
  }

  /// @notice The contract owner removes a changemaker's approval status
  /// @param changeMaker Address to be set to false in approvedChangeMakers mapping
  function removeApproval(address _changeMaker) external onlyOwner {
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
    communityFundPercentage = _communityFundPercentage;
  }

  function register() external {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");

    //More to come...
  }
}
