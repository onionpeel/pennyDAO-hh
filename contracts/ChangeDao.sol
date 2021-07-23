//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ChangeDao is Ownable {

  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) public approvedChangeMakers;

  constructor() {}

  /// @notice The ChageDao contract owner grants approval to become a changemaker
  /// @dev Only the contract owner can call this function
  /// @param newChangeMaker The address that will be added to the mapping of approved changemakers
  function approveNewChangeMaker(address newChangeMaker) external onlyOwner {
    approvedChangeMakers[newChangeMaker] = true;
  }

  /// @notice The contract owner removes a changemaker's approval status
  /// @param changeMaker Address to be set to false in approvedChangeMakers mapping
  function removeApproval(address changeMaker) external onlyOwner {
    approvedChangeMakers[changeMaker] = false;
  }

  function register() external {
    require(approvedChangeMakers[msg.sender] == true,
      "ChangeMaker needs to be approved in order to register");

    //More to come...
  }
}
