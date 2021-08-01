//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Funding.sol";

interface IFunding {
  function fund(address, uint256, uint256, address) external payable returns (bool);
}


contract Project is ERC721URIStorage, Initializable {
  using Counters for Counters.Counter;
  Counters.Counter sponsorId; // NFT minting

  uint256 mintPrice; // changeMaker sets price; expressed in DAI
  uint256 mintTotal; // changeMaker sets total mints
  address public changeMakerCloneOwner; // access control; changeMaker clone that created the project
  address payable fundingClone; // Address of clone
  address changeDaoContractOwner; // Address of ChangeDao contract owner
  string tokenCid; // NFT minting

  constructor(address _changeDaoContractOwner) ERC721("Project", "PRJT") {
    changeDaoContractOwner = _changeDaoContractOwner;
  }

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the project clone is created
  /// @param _mintPrice Minimum amount to fund a project and mint a token
  /// @param _mintTotal Total number of tokens that the project will mint
  /// @param _tokenName ChangeMaker sets the token name
  /// @param _tokenSymbol ChangeMaker sets the token symbol
  /// @param _tokenCid The cid that is used for setting the token URI
  /// @param _changeMakerCloneOwner The changeMaker address that is the owner of the project clone
  function initialize(
    uint256 _mintPrice,
    uint256 _mintTotal,
    string memory _tokenName,
    string memory _tokenSymbol,
    string memory _tokenCid,
    address _changeMakerCloneOwner //the changeMaker clone that is creating this project
  )
    public
    initializer
  {
    require(_mintPrice > 0, "Mint price must be larger than zero");
    require(_mintTotal > 0, "Mint total must be larger than zero");
    mintPrice = _mintPrice;
    mintTotal = _mintTotal;

    tokenCid = _tokenCid;
    changeMakerCloneOwner = _changeMakerCloneOwner;

    address fundingImplementation = address(new Funding());
    fundingClone = payable(Clones.clone(fundingImplementation));
    // Funding(fundingClone).initialize(msg.sender, _changeMakerCloneOwner);
  }


  /// @notice Sponsors send funds to the project and receive an NFT
  // function directFund(address _token, uint256 _amount) public {
  //   /// @notice Check that project NFTs remain to be minted
  //   require(mintTotal > sponsorId.current(), "Unable to fund. All tokens have already been minted");
  //   /// @notice Checks that funding was successful
  //   require(IFunding(fundingClone).fund(_token, _amount, mintPrice, msg.sender));
  //   /// @notice Update sponsorId
  //   sponsorId.increment();
  //   uint currentToken = sponsorId.current();
  //   /// @notice Mint project NFT to msg.sender
  //   _safeMint(msg.sender, currentToken);
  //   _setTokenURI(currentToken, tokenCid);
  // }

  /* @notice The changeMaker and ChangeDao are authorized to terminate the project so it will no longer receive funding */
  function terminateProject() public {
    require(msg.sender == changeDaoContractOwner || msg.sender == changeMakerCloneOwner,
      "Not authorized to terminate project");
    /// @notice Setting the value to zero causes fund() to revert
    mintTotal = 0;
  }
}
