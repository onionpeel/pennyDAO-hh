//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

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
  function communityFundWallet() external view returns (address);
}

interface IChangeMaker {
  function getChangeDaoAddress() external view returns (address);
}


contract Funding is ERC721URIStorage, Initializable {
  using SafeERC20 for IERC20;

  using EnumerableSet for EnumerableSet.AddressSet;
  EnumerableSet.AddressSet permittedTokens;

  using Counters for Counters.Counter;
  Counters.Counter sponsorId; // NFT minting

  address changeDaoContract;
  address changeMakerCloneOwner; // changemaker that created the project

  uint16 changeMakerPercentage;
  uint16 changeDaoPercentage;
  uint16 communityFundPercentage;

  uint256 mintPrice; // changeMaker sets price; expressed in DAI
  uint256 mintTotal; // changeMaker sets total mints
  string tokenCid; // NFT minting

  address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address constant ETH_USD_ORACLE = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  // EnumerableSet.AddressSet permittedTokens;
  mapping (address => uint256) public ethBalances;

  fallback() external payable {}

  constructor() ERC721("Funding", "FNDv1") {}

  /// @notice Funding contract initialization
  /// @param _changeMakerClone Address of the changeMaker clone that created this project
  /// @param _changeMakerCloneOwner Owner of _changeMakerClone
  function initialize(
    uint256 _mintPrice,
    uint256 _mintTotal,
    string memory _tokenCid,
    address _changeMakerClone,
    address _changeMakerCloneOwner,
    address[] memory _permittedTokens
  )
    public
    initializer
  {
    mintPrice = _mintPrice;
    mintTotal = _mintTotal;
    tokenCid = _tokenCid;
    changeMakerCloneOwner = _changeMakerCloneOwner; // the changeMaker that created the project
    /// @notice Populate permittedTokens
    for (uint256 idx; idx < _permittedTokens.length; idx++) {
      permittedTokens.add(_permittedTokens[idx]);
    }
    /// @notice Retrieve the changeDao contract address to be used for returning withdrawal percentages
    changeDaoContract = IChangeMaker(_changeMakerClone).getChangeDaoAddress();
    /// @notice Set the project's withdrawal percentages
    changeMakerPercentage = IChangeDao(changeDaoContract).changeMakerPercentage();
    changeDaoPercentage = IChangeDao(changeDaoContract).changeDaoPercentage();
    communityFundPercentage = IChangeDao(changeDaoContract).getCommunityFundPercentage();
  }


  /// @notice Check whether the funding amount is greater or equal to mintPrice
  /// @param _fundingToken Token for funding the project
  /// @param _amount Amount in DAI, USDC or ETH
  /// @param _mintPrice The minimum amount that a sponsor must send to fund the project
  function _isSufficientFunding(
    address _fundingToken,
    uint256 _amount,
    uint256 _mintPrice
  )
    private
    view
    returns (bool)
  {
    address token;

    for (uint256 idx; idx < permittedTokens.length(); idx++) {
      token = permittedTokens.at(idx);
      /// @notice If _fundingToken is ETH, convert to USD to compare with _amount
      if (token == ETH_ADDRESS) {
        (, int256 eth_to_usd, , , ) = Oracle(ETH_USD_ORACLE).latestRoundData();
        uint256 amountInUsd = msg.value * uint256(eth_to_usd) * 10**10;
        if (amountInUsd >= _mintPrice) return true;
      /// @notice If _fundingToken is DAI or USDC, check the amount
      } else if (token == _fundingToken && _amount >= _mintPrice) return true;
    }

    return false;
  }

  /// @notice Splits funding amount and allocates it based on ChangeDAO contract percentages
  function _setPercentageAmounts(
    address _token,
    uint256 _amount,
    uint256 _ethAmount,
    address _sponsor
  )
    private
  {
    /// @notice Retrieve addresses
    address changeDaoWallet = IChangeDao(changeDaoContract).changeDaoWallet();
    address communityFundWallet = IChangeDao(changeDaoContract).communityFundWallet();

    /// @notice If ETH, calculate percentages and store them in ethBalances
    if (_token == ETH_ADDRESS) {
      /// @notice Set ethBalances based on the percentages
      ethBalances[changeMakerCloneOwner] += _ethAmount * changeMakerPercentage;
      ethBalances[changeDaoWallet] += _ethAmount * changeDaoPercentage;
      ethBalances[communityFundWallet] += _ethAmount * communityFundPercentage;
    } else {
      /// @notice If DAI or USDC, calculate percentages
      uint256 changeMakerCloneOwnerAmount = _amount * changeMakerPercentage;
      uint256 changeDaoAmount = _amount * changeDaoPercentage;
      uint256 communityFundAmount = _amount * communityFundPercentage;

      /// @notice Store amounts in ethBalances based on percentages
      IERC20(_token).safeTransferFrom(_sponsor, changeMakerCloneOwner, changeMakerCloneOwnerAmount);
      IERC20(_token).safeTransferFrom(_sponsor, changeDaoWallet, changeDaoAmount);
      IERC20(_token).safeTransferFrom(_sponsor, communityFundWallet, communityFundAmount);
    }
  }

  /// @notice Mint sponsor NFT
  /// @param _sponsor Address of sponsor that is funding the project
  function _mintTokens(address _sponsor) private {
    /// @notice Check that there are still project NFTs remaining to be minted
    require(mintTotal > sponsorId.current(), "Unable to fund. All tokens have already been minted");
    /// @notice Update sponsorId
    sponsorId.increment();
    uint256 currentToken = sponsorId.current();
    /// @notice Mint project NFT to msg.sender
    _safeMint(_sponsor, currentToken);
    _setTokenURI(currentToken, tokenCid);
  }

  /* @notice Called by Project.sol directFund(). Divides the sponsor amount into the three distribution percentages*/
  /// @param _token Token for funding
  /// @param _amount Amount of funding
  /// @param _mintPrice Minimum amount of funding needed to mint an NFT
  /// @param _sponsor Address of sponsor funding the project
  function directFund(address _token, uint256 _amount, uint256 _mintPrice, address _sponsor)
    external
    payable
    returns (bool)
  {
    /// @notice Check that the funding amount is equal or greater than the required minimum
    require(_isSufficientFunding(_token, _amount, _mintPrice), "Insufficient funding amount");
    /// @notice Allocate funding amount based on ChangeDAO percentages
    _setPercentageAmounts(_token, _amount, msg.value, _sponsor);
    /// @notice Mint sponsor's NFT
    _mintTokens(_sponsor);
  }

  /* @notice changeMakerCloneOwner, changeDaoWallet and communityFundWallet can withdraw their ETH balance from the contract */
  function withdrawEth() public {
    /// @notice Retrieve addresses
    ///////////////// FIX THIS *****************************
    // address changeDaoWallet = IChangeDao(changeDaoContract).changeDaoWallet();
    // address communityFundWallet = IChangeDao(changeDaoContract).communityFundWallet();
    //
    // require(permittedTokens.contains(msg.sender), "Not authorized to withdraw ETH");
    //
    // ethBalances[msg.sender] = 0;
    //
    // (bool success,) = msg.sender.call{value: ethBalances[msg.sender]}("");
    // require(success, "Failed to withdraw ETH");
  }


  /// @notice Check that msg.sender is authorized contract owner
  function _isAuthorizedOwner(address _msgSender) private returns (bool) {
    address changeDaoContractOwner = IChangeDao(changeDaoContract).owner();

    if (_msgSender == changeDaoContractOwner) {
      return true;
    } else if(_msgSender == changeMakerCloneOwner) {
      return true;
    } else return false;
  }

  /* @notice The changeMaker and changeDaoContractOwner are authorized to terminate the project so it will no longer receive funding or mint*/
  function terminateProject() public {
    require(_isAuthorizedOwner(msg.sender), "Not authorized to terminate project");
    /// @notice Setting the value to zero causes fund() to revert
    mintTotal = 0;
  }
}
