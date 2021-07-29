//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";


interface IChangeDao {
  function changeDaoPercentage() external view returns (uint16);
  function changeMakerPercentage() external view returns (uint16);
  function getCommunityFundPercentage() external view returns (uint16);
  function owner() external view returns (address);
}

interface IChangeMaker {
  function getChangeDaoAddress() external view returns (address);
}


contract Funding is Initializable {
  address owner; // owner = project clone
  uint16 changeMakerPercentage; // funding withdrawal
  uint16 changeDaoPercentage; // funding withdrawal
  uint16 communityFundPercentage; // funding withdrawal
  address constant DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  EnumerableSet.AddressSet permittedTokens;


fallback() external payable {}


function initialize(address _owner, address[] memory _permittedTokens,) public initializer {
  owner = _owner; // Set the project clone as the owner
  /// @notice Create a set of tokens that are approved to be used for funding
  for (uint256 idx = 0; idx < _permittedTokens.length; idx++) {
    permittedTokens.push(_permittedTokens[idx]);
  }
  require(permittedTokens.contains(DAI), "DAI must be in the list of available funding tokens");
  /// @notice Retrieve the changeDao contract address to be used for returning withdrawal percentages 
  address changeDao = IChangeMaker(_owner).getChangeDaoAddress();
  /// @notice Set the project's withdrawal percentages
  changeMakerPercentage = IChangeDao(changeDao).changeMakerPercentage();
  changeDaoPercentage = IChangeDao(changeDao).changeDaoPercentage();
  communityFundPercentage = IChangeDao(changeDao).getCommunityFundPercentage();
}



  function fund(address _token, uint256 _amount, uint256 mintPrice)
    external
    payable
    returns (bool)
  {
    require(msg.sender == owner, "Only the project can call fund()");
    /// @notice Check that the funding amount is equal or greater than the required minimum

  }
}
