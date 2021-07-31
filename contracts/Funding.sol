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

  /// @notice Funding contract initialization
  /// @param _changeMakerClone Address of the changeMaker clone that created this project
  /// @param _changeMakerCloneOwner Owner of _changeMakerClone
  function initialize(address _changeMakerClone, address _changeMakerCloneOwner) public initializer {
    changeMakerClone = _changeMakerClone; // Set the project clone as the owner
    changeMakerCloneOwner = _changeMakerCloneOwner; // the changeMaker that created the project
    /// @notice Retrieve the changeDao contract address to be used for returning withdrawal percentages
    changeDaoContract = IChangeMaker(_changeMakerClone).changeDaoContract();
    /// @notice Set the project's withdrawal percentages
    changeMakerPercentage = IChangeDao(changeDaoContract).changeMakerPercentage();
    changeDaoPercentage = IChangeDao(changeDaoContract).changeDaoPercentage();
    communityFundPercentage = IChangeDao(changeDaoContract).getCommunityFundPercentage();
  }


  /// @notice Check whether the funding amount is greater or equal to mintPrice
  /// @param _token Token for funding the project
  /// @param _amount Amount in DAI, USDC or ETH
  /// @param _mintPrice The minimum amount that a sponsor must send to fund the project
  function _isSufficientFunding(address _token, uint256 _amount, uint256 _mintPrice)
    private
    view
    returns (bool)
  {
    /// @notice If token is DAI or USDC, check the amount
    if ((_token == DAI || _token == USDC) && _amount >= _mintPrice) return true;
    /// @notice Check amount if ETH is sent
    (, int256 eth_to_usd, , , ) = Oracle(ETH_USD_ORACLE).latestRoundData();
    uint256 amountInUsd = msg.value * uint256(eth_to_usd) * 10**10;
    if ((_token == ETH_ADDRESS) && amountInUsd >= _mintPrice) return true;
    /// @notice Return false if the token is not DAI, USDC or ETH
    return false;
  }

  /* @notice Called by Project.sol directFund(). Divides the sponsor amount into the three distribution percentages*/
  function fund(address _token, uint256 _amount, uint256 _mintPrice, address _sponsor)
    external
    payable
    returns (bool)
  {
    /// @notice Check that the function is called by its project clone
    require(msg.sender == changeMakerClone, "Only the project clone can call fund()");
    /// @notice Check that the funding amount is equal or greater than the required minimum
    require(_isSufficientFunding(_token, _amount, _mintPrice), "Insufficient funding amount");
    /// @notice If ETH, calculate percentages and store them in ethBalances
    if (_token == ETH_ADDRESS) {
      ethBalances[changeMakerCloneOwner] += msg.value * changeMakerPercentage;
      ethBalances[changeDaoOwner] += msg.value * changeDaoPercentage;
      ethBalances[communityFundAddress] += msg.value * communityFundPercentage;
    } else {
      /// @notice If DAI or USDC, calculate percentages
      uint256 changeMakerCloneOwnerAmount = _amount * changeMakerPercentage;
      uint256 changeDaoAmount = _amount * changeDaoPercentage;
      uint256 communityFundAmount = _amount * communityFundPercentage;
      /// @notice Retrieve addresses
      address changeDaoOwner = IChangeDao(changeDaoContract).owner();
      address communityFundAddress = IChangeDao(changeDaoContract).communityFundAddress();
      /// @notice Store amounts in ethBalances based on percentages
      IERC20(_token).safeTransferFrom(_sponsor, changeMakerCloneOwner, changeMakerCloneOwnerAmount);
      IERC20(_token).safeTransferFrom(_sponsor, changeDaoOwner, changeDaoAmount);
      IERC20(_token).safeTransferFrom(_sponsor, communityFundAddress, communityFundAmount);
    }
  }

  /* @notice changeMakerCloneOwner, changeDaoOwner and communityFundAddress can withdraw their ETH balance from the contract */
  function withdrawEth() public {
    require(msg.sender == changeMakerCloneOwner || msg.sender == changeDaoOwner ||
      msg.sender = communityFundAddress, "Not authorized to withdraw ETH");

    ethBalances[msg.sender] = 0;

    (bool success,) = msg.sender.call{value: ethBalances[msg.sender]}("");
    require(success, "Failed to withdraw ETH");
  }
}
