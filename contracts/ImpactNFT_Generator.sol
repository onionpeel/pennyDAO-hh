//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import './Projects.sol';

contract ImpactNFT_Generator is ERC721URIStorage, Sponsors {
  using Counters for Counters.Counter;
  Counters.Counter tokenCount;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  ///@notice This function is called by Project: createTokens() and it mints all the NFTs for a project
  function mintTokens(SponsorTokenData[] memory sponsorArray) public {
     uint256 current;
      for(uint256 i; i < sponsorArray.length; i++) {
        tokenCount.increment();
        current = tokenCount.current();

        _mint(sponsorArray[i].sponsorAddress, current);
        _setTokenURI(current, sponsorArray[i].sponsorTokenURI);
      }
  }
}
