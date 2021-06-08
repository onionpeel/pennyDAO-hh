//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';

contract ImpactNFT_Generator is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter tokenCount;

  constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

  function createToken(address recipient, string memory tokenURI) public returns (uint256) {
    tokenCount.increment();
    uint256 current = tokenCount.current();

    _mint(recipient, current);
    _setTokenURI(current, tokenURI);
    return current;
  }
}
