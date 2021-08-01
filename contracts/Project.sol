//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Funding.sol";

interface IFunding {
  function fund(address, uint256, uint256, address) external payable returns (bool);
}


contract Project is ERC721, Initializable {

  constructor() ERC721("Project", "PRJTv1") {}

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

    address fundingImplementation = address(new Funding());
    address payable fundingClone = payable(Clones.clone(fundingImplementation));

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
