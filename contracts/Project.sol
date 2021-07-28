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
  uint mintPrice;
  uint mintTotal;

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
  /// @param _owner The changeMaker address that is the owner of the project clone
  function initialize(
    uint mintPrice,
    uint mintTotal,
    address _changeDao,
    address _owner
  )
    public
    initializer
  {
    mintPrice = _mintPrice;
    mintTotal = _mintTotal;
    changeDao = _changeDao;
    owner = _owner;
    /// @notice Set the project's withdrawal percentages
    changeMakerPercentage = IChangeDao(changeDao).changeMakerPercentage();
    changeDaoPercentage = IChangeDao(changeDao).changeDaoPercentage();
    communityFundPercentage = IChangeDao(changeDao).getCommunityFundPercentage();
  }


  // Direct funding model
  /* Flow within fund()
  1. receive amount:
  a) erc20 stablecoin
  b) eth
  2. Check that the mintTotal set by the changemaker is greater than the number of NFTs that have been minted.
  3. Check that the amount is greater than the mintPrice set by the changemaker.
  3. Divide the amount based on percentages for changemaker, changedao, and community fund
  4. Distribute the divided amounts to those three parties
  5. Mint NFT for the address that sent the funds
  */

  function fund() public {

  }

  function mint() public{

  }

  function terminateProject() public {
    
  }

}
