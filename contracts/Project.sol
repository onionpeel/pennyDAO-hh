//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IChangeDao {
  function changeDaoPercentage() external view returns (uint16);
  function changeMakerPercentage() external view returns (uint16);
  function getCommunityFundPercentage() external view returns (uint16);
}

contract Project is Ownable, Initializable {
  uint256 expirationTime;
  uint256 fundingGoal;
  uint256 minimumSponsorship;
  address changeDao;

  uint16 changeMakerPercentage;
  uint16 changeDaoPercentage;
  uint16 communityFundPercentage;

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the project clone is created
  /// @param _expirationTime Project cannot receive funding after expiration
  /// @param _fundingGoal Amount required to complete the project funding
  /// @param _minimumSponsorship Sponsors must fund above the minimum amount
  /// @param _changeDao The address of the changeDao contract
  function initialize(
    uint256 _expirationTime,
    uint256 _fundingGoal,
    uint256 _minimumSponsorship,
    address _changeDao
  ) public initializer {
    expirationTime = _expirationTime;
    fundingGoal = _fundingGoal;
    minimumSponsorship = _minimumSponsorship;
    changeDao = _changeDao;
    /// @notice Set the project's withdrawal percentages
    changeMakerPercentage = IChangeDao(changeDao).changeMakerPercentage();
    changeDaoPercentage = IChangeDao(changeDao).changeDaoPercentage();
    communityFundPercentage = IChangeDao(changeDao).getCommunityFundPercentage();
  }

  // FUND

  // MINT (1155)

  // WITHDRAW => REQUIRE ACCESS CONTROL FOR CHANGEMAKER AND CHANGEDAO

  // REFUND => THIS WILL REQUIRE CHANGEDAO ADMIN ACCESS CONTROL

  // DATA STRUCTURE FOR SPONSORS => USED FOR REFUNDS
}
