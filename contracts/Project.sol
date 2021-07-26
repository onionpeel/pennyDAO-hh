//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

interface IChangeDao {
  function changeDaoPercentage() external view returns (uint16);
  function changeMakerPercentage() external view returns (uint16);
  function getCommunityFundPercentage() external view returns (uint16);
  function owner() external view returns (address);
}

contract Project is Initializable {
  uint256 expirationTime;
  uint256 fundingGoal;
  uint256 minimumSponsorship;
  address changeDao;
  address public owner;

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
    address _changeDao,
    address _owner
  )
    public
    initializer
  {
    expirationTime = _expirationTime;
    fundingGoal = _fundingGoal;
    minimumSponsorship = _minimumSponsorship;
    changeDao = _changeDao;
    owner = _owner;
    /// @notice Set the project's withdrawal percentages
    changeMakerPercentage = IChangeDao(changeDao).changeMakerPercentage();
    changeDaoPercentage = IChangeDao(changeDao).changeDaoPercentage();
    communityFundPercentage = IChangeDao(changeDao).getCommunityFundPercentage();
  }



  /// *********** EVERYTHING BELOW IS NOT FINISHED **************************

  modifier onlyChangeDao() {
    require(msg.sender == IChangeDao(changeDao).owner(),
      "Only changeDao owner can call this function");
    _;
  }

  /// @notice ChangeDao owner can return all funds to sponsors
  function refund() public onlyChangeDao {

  }

  /// @notice The owner of the changeMaker clone calls to receive funding share
  function withdrawChangemakerShare() public {
    require(msg.sender == owner, "Only changeMaker project owner can call function");

  }

  /// @notice The owner of the changeDao instance calls to receive funding share
  function withdrawChangeDaoShare() public onlyChangeDao {

  }

  /// @notice The owner of the changeDao instance calls to receive funding share
  function withdrawCommunityFundShare() public onlyChangeDao {

  }

  // FUND => fund()

  // MINT (1155) => mintProjectTokens()

  // DATA STRUCTURE FOR SPONSORS => USED FOR REFUNDS
}
