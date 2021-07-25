//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Project is Ownable, Initializable {
  uint256 expirationTime;
  uint256 fundingGoal;
  uint256 minimumSponsorship;
  uint16 changeMakerPercentage;
  uint16 changeDaoPercentage;
  uint16 communityFundPercentage;

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the project clone is created
  /// @param _expirationTime Project cannot receive funding after expiration
  /// @param _fundingGoal Amount required to complete the project funding
  /// @param _minimumSponsorship Sponsors must fund above the minimum amount
  /// @param _changeMakerPercentage Sets changeMaker withdrawl percentage
  /// @param _changeDaoPercentage Sets changeDao withdrawal percentage
  /// @param _communityFundPercentage Sets communityFund withdrawal percentage
  function initialize(
    uint256 _expirationTime,
    uint256 _fundingGoal,
    uint256 _minimumSponsorship,
    uint16 _changeMakerPercentage,
    uint16 _changeDaoPercentage,
    uint16 _communityFundPercentage
  ) public initializer {
    expirationTime = _expirationTime;
    fundingGoal = _fundingGoal;
    minimumSponsorship = _minimumSponsorship;
    changeMakerPercentage = _changeMakerPercentage;
    changeDaoPercentage = _changeDaoPercentage;
    communityFundPercentage = _communityFundPercentage;
  }

  // FUND

  // WITHDRAW

  // REFUND => THIS WILL REQUIRE CHANGEDAO ADMIN ACCESS CONTROL
}
