//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import './Sponsors.sol';

contract ImpactNFT_Generator2 is ERC721URIStorageUpgradeable, Sponsors {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  CountersUpgradeable.Counter tokenCount;

  ///@notice This is a new storage value that has been added to test upgradability
  uint256 public storageValue;

  function setStorageValue(uint256 _storageValue) public {
    storageValue = _storageValue;
  }

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
