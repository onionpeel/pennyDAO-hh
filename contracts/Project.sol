//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Funding.sol";


contract Project is ERC721, Initializable {
  using Counters for Counters.Counter;
  Counters.Counter public fundingCloneTokenId;

  address immutable fundingCloneImplementation;

  /// @notice Maps NFT fundingClone token id to funding clone
  mapping (uint256 => address) public fundingClones;

  /// @notice Creates implementation for the funding clone 
  constructor() ERC721("Project", "PRJTv1") {
    fundingCloneImplementation = address(new Funding());
  }

  /// @notice Initialize a project clone
  /* @dev This function is called immediately after the project clone is created by a changeMaker clone */
  /// @param _mintPrice Minimum amount to fund a project and mint a token
  /// @param _mintTotal Total number of tokens that the project will mint
  /// @param _tokenCid The cid that is used for setting the token URI
  /// @param _changeMakerCloneOwner The changeMaker address that is the owner of the project clone
  function initialize(
    uint256 _mintPrice,
    uint256 _mintTotal,
    string memory _tokenCid,
    address _changeMakerCloneOwner, //the changeMaker clone that is creating this project
    address[] memory _permittedTokens
  )
    public
    initializer
  {
    require(_mintPrice > 0, "Mint price must be larger than zero");
    require(_mintTotal > 0, "Mint total must be larger than zero");

    address payable fundingClone = payable(Clones.clone(fundingCloneImplementation));

    /// @notice Increment fundingClone token id
    fundingCloneTokenId.increment();
    uint256 currentToken = fundingCloneTokenId.current();
    /// @notice Mint changeMaker's new project NFT that maps to the project clone
    _safeMint(msg.sender, currentToken);
    fundingClones[currentToken] = fundingClone;

    Funding(fundingClone).initialize(
      _mintPrice,
      _mintTotal,
      _tokenCid,
      msg.sender,
      _changeMakerCloneOwner,
      _permittedTokens
    );
  }
}
