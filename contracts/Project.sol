//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Funding.sol";


contract Project is ERC721URIStorage, Initializable {
  using Counters for Counters.counter;

  uint256 mintPrice; // changeMaker sets price; expressed in DAI
  uint256 mintTotal; // changeMaker sets total mints
  address public owner; // access control
  address fundingClone; // Address of clone
  string tokenCid; // NFT minting
  Counters sponsorId; // NFT minting


  ///WILL SOMETHING LIKE THIS BE NEEDED?
  // constructor() {
  //     // prevent the implementation contract from being initialized
  //     goalAmount = uint256(-1);
  // }

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the project clone is created
  /// @param _mintPrice Minimum amount to fund a project and mint a token
  /// @param _mintTotal Total number of tokens that the project will mint
  /// @param _tokenName ChangeMaker sets the token name
  /// @param _tokenSymbol ChangeMaker sets the token symbol
  /// @param _tokenCid The cid that is used for setting the token URI
  /// @param _owner The changeMaker address that is the owner of the project clone
  function initialize(
    uint256 public _mintPrice,
    uint256 public _mintTotal,
    string _tokenName,
    string _tokenSymbol,
    string _tokenCid,
    address _owner
    address[] memory _permittedTokens,

  )
    public
    initializer
  {
    /// SHOULD NAME/SYMBOL BE CUSTOMIZABLE????
    ERC721(_tokenName, _tokenSymbol);

    require(_mintPrice > 0, "Mint price must be larger than zero");
    require(_mintTotal > 0), "Mint total must be larger than zero)";
    mintPrice = _mintPrice;
    mintTotal = _mintTotal;

    tokenCid = _tokenCid;
    owner = _owner;

    address fundingImplementation = address(new Funding());
    fundingClone = Clones.clone(fundingImplementation);
    Funding(fundingClone).initialize(msg.sender, _owner, _permittedTokens);
  }


  // Direct funding model
  /* Flow within directFund()
  1. receive amount:
  a) erc20 stablecoin
  b) eth
  *2. Check that the mintTotal set by the changemaker is greater than the number of NFTs that have been minted.
  3. Check that the amount is greater than the mintPrice set by the changemaker. This will require conversions to DAI? from other stablecoins and eth
  3. Divide the amount based on percentages for changemaker, changedao, and community fund
  4. Distribute the divided amounts to those three parties
  5. Mint NFT for the address that sent the funds
  */

  /// @notice Sponsors send funds to the project and receive an NFT
  function directFund(address _token, uint256 _amount) public {
    /// @notice Check that project NFTs remain to be minted
    require(mintTotal > sponsorId, "Unable to fund. All tokens have already been minted");
    /// @notice Checks that funding was successful
    require(projectClone.fund(_token, _amount, mintPrice, msg.sender));
    /// @notice Update sponsorId
    sponsorId.increment();
    uint currentToken = sponsorId.current();
    /// @notice Mint project NFT to msg.sender
    _safeMint(msg.sender, currentToken);
    _setTokenURI(currentToken, tokenCid);
  }

  /* @notice The changeMaker and ChangeDao are authorized to terminate the project so it will no longer receive funding */
  function terminateProject() public {
    require(msg.sender == changeDao || msg.sender == owner, "Not authorized to terminate project");
    /// @notice Setting the value to zero causes fund() to revert
    mintTotal = 0;
  }
}
