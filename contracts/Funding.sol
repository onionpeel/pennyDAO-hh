//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20";


interface Oracle {
    function latestRoundData()
        external
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        );
}

interface IChangeDao {
  function changeDaoPercentage() external view returns (uint16);
  function changeMakerPercentage() external view returns (uint16);
  function getCommunityFundPercentage() external view returns (uint16);
  function owner() external view returns (address); //returns address that deployed ChangeDAO.sol
  function communityFundAddress() external view returns (address);
}

interface IChangeMaker {
  function getChangeDaoAddress() external view returns (address);
}


contract Funding is Initializable {
  using SafeERC20 for IERC20;

  address changeMakerClone; // owner = project clone
  address changeMakerCloneOwner; // changemaker that created the project
  address changeDaoContract;

  uint16 changeMakerPercentage; // funding withdrawal
  uint16 changeDaoPercentage; // funding withdrawal
  uint16 communityFundPercentage; // funding withdrawal

  address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address constant ETH_USD_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  // EnumerableSet.AddressSet permittedTokens;
  mapping (address => uint256) public ethBalances;

  fallback() external payable {}


  function initialize(address _changeMakerClone, address _changeMakerCloneOwner) public initializer {
    changeMakerClone = _changeMakerClone; // Set the project clone as the owner
    changeMakerCloneOwner = _changeMakerCloneOwner; // the changeMaker that created the project
    /// @notice Create a set of tokens that are approved to be used for funding
    // for (uint256 idx = 0; idx < _permittedTokens.length; idx++) {
    //   permittedTokens.push(_permittedTokens[idx]);
    // }

    /// @notice Retrieve the changeDao contract address to be used for returning withdrawal percentages
    changeDaoContract = IChangeMaker(_changeMakerClone).changeDaoContract();
    /// @notice Set the project's withdrawal percentages
    changeMakerPercentage = IChangeDao(changeDaoContract).changeMakerPercentage();
    changeDaoPercentage = IChangeDao(changeDaoContract).changeDaoPercentage();
    communityFundPercentage = IChangeDao(changeDaoContract).getCommunityFundPercentage();
  }


  /// @notice Check whether the funding amount is greater or equal to mintPrice
  function _isSufficientFunding(address _token, uint256 _amount, uint256 _mintPrice)
    private
    view
    returns (bool)
  {
    if ((_token == DAI || _token == USDC) && _amount >= _mintPrice) return true;

    (, int256 eth_to_usd, , , ) = Oracle(ETH_USD_ORACLE).latestRoundData();
    uint256 amountInUsd = msg.value * uint256(eth_to_usd) * 10**10;
    if ((_token == ETH_ADDRESS) && amountInUsd >= _mintPrice) return true;

    return false;
  }

  function fund(address _token, uint256 _amount, uint256 _mintPrice, address _sponsor)
    external
    payable
    returns (bool)
  {
    require(msg.sender == changeMakerClone, "Only the project clone can call fund()");
    /// @notice Check that the funding amount is equal or greater than the required minimum
    require(_isSufficientFunding(_token, _amount, _mintPrice), "Insufficient funding amount");

    if (_token == ETH_ADDRESS) {
      ethBalances[changeMakerCloneOwner] += msg.value * changeMakerPercentage;
      ethBalances[changeDaoOwner] += msg.value * changeDaoPercentage;
      ethBalances[communityFundAddress] += msg.value * communityFundPercentage;
    } else {
      uint256 changeMakerCloneOwnerAmount = _amount * changeMakerPercentage;
      uint256 changeDaoAmount = _amount * changeDaoPercentage;
      uint256 communityFundAmount = _amount * communityFundPercentage;

      address changeDaoOwner = IChangeDao(changeDaoContract).owner();
      address communityFundAddress = IChangeDao(changeDaoContract).communityFundAddress();

      IERC20(_token).safeTransferFrom(_sponsor, changeMakerCloneOwner, changeMakerCloneOwnerAmount);
      IERC20(_token).safeTransferFrom(_sponsor, changeDaoOwner, changeDaoAmount);
      IERC20(_token).safeTransferFrom(_sponsor, communityFundAddress, communityFundAmount);
    }
  }

  function withdrawEth() public {
    require(msg.sender == changeMakerCloneOwner || msg.sender == changeDaoOwner ||
      msg.sender = communityFundAddress, "Not authorized to withdraw ETH");

    ethBalances[msg.sender] = 0;

    (bool success,) = msg.sender.call{value: ethBalances[msg.sender]}("");
    require(success, "Failed to withdraw ETH");
  }



}
