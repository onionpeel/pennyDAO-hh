//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

interface IChangeDao {
  function changeDaoPercentage() external view returns (uint16);
  function changeMakerPercentage() external view returns (uint16);
  function getCommunityFundPercentage() external view returns (uint16);
  function owner() external view returns (address);
}

interface IChangeMaker {
  function getChangeDaoAddress() external view returns (address);
}

contract Project is ERC721URIStorage, Initializable {
  using Counters for Counters.counter;

  uint mintPrice;
  uint mintTotal;
  address public owner;
  string tokenCid;
  uint16 changeMakerPercentage;
  uint16 changeDaoPercentage;
  uint16 communityFundPercentage;

  Counters sponsorId;

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the project clone is created
  /// @param _expirationTime Project cannot receive funding after expiration
  /// @param _fundingGoal Amount required to complete the project funding
  /// @param _minimumSponsorship Sponsors must fund above the minimum amount
  /// @param _changeDao The address of the changeDao contract
  /// @param _owner The changeMaker address that is the owner of the project clone
  function initialize(
    uint _mintPrice,
    uint _mintTotal,
    string _tokenName,
    string _tokenSymbol,
    string _tokenCid,
    address _owner
  )
    public
    initializer
  {
    /// SHOULD NAME/SYMBOL BE CUSTOMIZABLE????
    ERC721(_tokenName, _tokenSymbol);

    mintPrice = _mintPrice;
    mintTotal = _mintTotal;
    tokenCid = _tokenCid;
    owner = _owner;

    address changeDao = IChangeMaker(msg.sender).getChangeDaoAddress();
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
  3. Check that the amount is greater than the mintPrice set by the changemaker. This will require conversions to DAI? from other stablecoins and eth
  3. Divide the amount based on percentages for changemaker, changedao, and community fund
  4. Distribute the divided amounts to those three parties
  5. Mint NFT for the address that sent the funds
  */

  function fund() public {

  }

  function _mint() private {
    sponsorId.increment();
    uint currentToken = sponsorId.current();
    _safeMint(msg.sender, currentToken);
    _setTokenURI(currentToken, tokenCid);
  }

  function terminateProject() public {
    require(msg.sender == changeDao || msg.sender == owner, "Not authorized to terminate project");
    /// @notice Setting the value to zero causes fund() to revert
    mintTotal = 0;
  }
}
