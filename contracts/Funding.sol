// //SPDX-License-Identifier: MIT
// pragma solidity 0.8.6;
//
// import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts/utils/EnumerableSet.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20";
//
//
// interface Oracle {
//     function latestRoundData()
//         external
//         view
//         returns (
//             uint80,
//             int256,
//             uint256,
//             uint256,
//             uint80
//         );
// }
//
// interface IChangeDao {
//   function changeDaoPercentage() external view returns (uint16);
//   function changeMakerPercentage() external view returns (uint16);
//   function getCommunityFundPercentage() external view returns (uint16);
//   function owner() external view returns (address);
// }
//
// interface IChangeMaker {
//   function getChangeDaoAddress() external view returns (address);
// }
//
//
// contract Funding is Initializable {
//   using SafeERC20 for IERC20;
//
//   address cloneOwner; // owner = project clone
//   address changeMaker; // changemaker that created the project
//
//   uint16 changeMakerPercentage; // funding withdrawal
//   uint16 changeDaoPercentage; // funding withdrawal
//   uint16 communityFundPercentage; // funding withdrawal
//
//   address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
//   address ETH_USD_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
//
//   EnumerableSet.AddressSet permittedTokens;
//   mapping (address => uint256) public ethBalances;
//
//   fallback() external payable {}
//
//
//   function initialize(address _cloneOwner, address[] memory _permittedTokens,) public initializer {
//     cloneOwner = _cloneOwner; // Set the project clone as the owner
//     changeMaker = _changeMaker; // the changeMaker that created the project
//     /// @notice Create a set of tokens that are approved to be used for funding
//     for (uint256 idx = 0; idx < _permittedTokens.length; idx++) {
//       permittedTokens.push(_permittedTokens[idx]);
//     }
//
//     /// @notice Retrieve the changeDao contract address to be used for returning withdrawal percentages
//     address changeDao = IChangeMaker(_changeMaker).getChangeDaoAddress();
//     /// @notice Set the project's withdrawal percentages
//     changeMakerPercentage = IChangeDao(changeDao).changeMakerPercentage();
//     changeDaoPercentage = IChangeDao(changeDao).changeDaoPercentage();
//     communityFundPercentage = IChangeDao(changeDao).getCommunityFundPercentage();
//
//   }
//
//
//   /// @notice Check whether the funding amount is greater or equal to mintPrice
//   function _isSufficientFunding(address _token, uint256 _amount, uint256 _mintPrice)
//     private
//     view
//     returns (bool)
//   {
//     if (_token == permittedTokens.contains(_token) && _amount >= _mintPrice) return true;
//
//     (, int256 eth_to_usd, , , ) = Oracle(ETH_USD_ORACLE).latestRoundData();
//     uint256 amountInUsd = _amount * uint256(eth_to_usd) * 10**10;
//     if (_token == permittedTokens.contains(_token) && amountInUsd >= _mintPrice) return true;
//
//     return false;
//   }
//
//   function fund(address _token, uint256 _amount, uint256 _mintPrice, address _sponsor)
//     external
//     payable
//     returns (bool)
//   {
//     require(msg.sender == cloneOwner, "Only the project clone can call fund()");
//     /// @notice Check that the funding amount is equal or greater than the required minimum
//     require(_isSufficientFunding(_token, _amount, _mintPrice), "Insufficient funding amount");
//
//     if (_token == ETH_ADDRESS) {
//       ethBalances[changeMaker] += msg.value * changeMakerPercentage;
//       ethBalances[changeDao] += msg.value * changeDaoPercentage;
//       ethBalances[communityFund] += msg.value * communityFundPercentage;
//     } else {
//       uint256 changeMakerAmount = _amount * changeMakerPercentage;
//       uint256 changeDaoAmount = _amount * changeDaoPercentage;
//       uint256 communityFundAmount = _amount * communityFundPercentage;
//
//       IERC20(_token).safeTransferFrom(_sponsor, , _amount);
//       IERC20(_token).safeTransferFrom(_sponsor, address(this), _amount);
//       IERC20(_token).safeTransferFrom(_sponsor, address(this), _amount);
//     }
//   }
//
//   function withdrawEth() public {
//     require(msg.sender);
//   }
//
//
//
// }
