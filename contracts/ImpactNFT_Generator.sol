//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import './Projects.sol';

abstract contract ImpactNFT_Generator is ERC721URIStorage, Projects {
  using Counters for Counters.Counter;
  Counters.Counter tokenCount;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  // function createToken(address recipient, string memory tokenURI) public returns (uint256) {
  //   tokenCount.increment();
  //   uint256 current = tokenCount.current();
  //
  //   _mint(recipient, current);
  //   _setTokenURI(current, tokenURI);
  //   return current;
  // }


  struct SponsorTokenData {
    address sponsorAddress;
    string sponsorTokenURI;
  }

  ///@notice ChangeMaker calls this function to generate NFTs for all the sponsors of a specific project
  function createToken(SponsorTokenData[] memory sponsorArray, uint256 _projectId) public returns (uint256) {
    Project storage project = projects[_projectId];
    require(!project.hasMinted, "NFTs for this project have already been minted");
    project.hasMinted = true;

    uint256 current;

    for(uint256 i; i < sponsorArray.length; i++) {
      tokenCount.increment();
      current = tokenCount.current();

      _mint(sponsorArray[i].sponsorAddress, current);
      _setTokenURI(current, sponsorArray[i].sponsorTokenURI);
    }

    return current;
  }
}
