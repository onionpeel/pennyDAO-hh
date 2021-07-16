//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChangeDAO is Ownable{
  /// @notice Maintains a list of addresses that are permitted to register as changemakers
  mapping (address => bool) approvedChangeMakers;

  /// @notice The contract owner grants approval to become a changemaker
  /// @dev Only the contract owner can call this function
  /// @param
  function approveNewChangeMaker(address newChangeMaker) external onlyOwner {
    approvedChangeMakers[newChangeMaker] = true;
  }
}
