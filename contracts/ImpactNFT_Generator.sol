//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
// import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol';
import './Projects.sol';

contract ImpactNFT_Generator is ERC721URIStorageUpgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  CountersUpgradeable.Counter tokenCount;
  Sponsors sponsors;

  ///@notice This contract is upgradeable, so this function takes the place of the constructor
  function initialize(
    string memory name,
    string memory symbol,
    Sponsors _sponsors
  )
    public
    initializer
  {
    __ERC721_init(name, symbol);
    sponsors = _sponsors;
  }

  // function initialize(string memory name, string memory symbol) public initializer {
  //   ERC721(name, symbol);
  // }

  // constructor(string memory name, string memory symbol) ERC721(name, symbol) {}


  ///@notice This function is called by Project: createTokens() and it mints all the NFTs for a project
  function mintTokens(sponsors.SponsorTokenData[] memory sponsorArray) public {
     uint256 current;
      for(uint256 i; i < sponsorArray.length; i++) {
        tokenCount.increment();
        current = tokenCount.current();

        _mint(sponsorArray[i].sponsorAddress, current);
        _setTokenURI(current, sponsorArray[i].sponsorTokenURI);
      }
  }
}
