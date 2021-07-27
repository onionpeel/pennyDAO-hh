//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

// Clones are not unique contracts.  This is only to create a diagram of the logic
contract ProjectClone is ERC1155 {
  uint256 public constant PROJECT = 0;
  uint256 public constant SPONSOR = 1;

  constructor() ERC1155('some URI to fetch info about the tokens'){
    _mint(address(this), 0, 1, "");
  }


  struct Sponsor {
    address sponsorAddress;
    uint256 sponsorFundingAmount;
    string sponsorStablecoin;
  }

  Sponsor[] public sponsors;

  /* A sponsor will call fund() and the data gets saved as a new struct in the sponsors array */
  function fund() public {
    Sponsor memory newSponsor = Sponsor({
      sponsorAddress: msg.sender,
      sponsorFundingAmount: amount,
      sponsorStablecoin: stablecoin
    });

    sponsors.push(newSponsor);
  }

  /* When the project is fully funded, the changeMaker that controls this project clone calls this function */
  function mintSponsorTokens() {
    for(uint i = 0; i < sponsors.length; i++) {
      Sponsor memory sponsor = sponsors[i];

      _mint(sponsor.sponsorAddress, 1, 1, "");
    }
  }
}

Ah, ok.  I'm trying to connect the overall architecture with what you are describing.

Right now the contracts are set up like this:
ChangeDao.sol deploys a ChangeMaker.sol instance and then that instance deploys a Project.sol instance.

When an organization becomes a changemaker, it makes a clone of the deployed ChangeMaker contract. Each clone is assigned a token id, and those token ids are stored in a mapping in the ChangeDao contract.

Then when a changemaker wants to create a project, it creates a clone of the deployed Project contract.  This project clone is given a token id, and this id is put in a mapping in the changemaker clone.

So, basically:
ChangeDao holds the references to the changemaker clones.
Each changemaker clone holds the references to all of its project clones.

The mappings that are in the ChangeDao contract and in the changemaker clones are created by using ERC721.  So technically, this makes all of the clone contracts into NFTs.  It isn't necessary to use ERC721.  We could just create a mapping ourselves and avoid ERC721.  The result is the same because we use mappings to structure the between changedao and the changemaker clones and the project clones.

This means that ChangeMaker.sol is an ERC721 only for the purpose of creating structure. It doesn't have any connection to issuing tokens.

That is why I was trying to put the logic of tokens into the project clones.

Your suggestion is to make ChangeMaker.sol an ERC1155, so it will have to be used in creating structure.  Then there will need to be a mapping in each changemaker clone that keeps track of all of its project clones that are created.  So, each changemaker clone has: mapping(tokenId => project clone).  Does this mean that each of these token ids would then be used as in the ERC1155 token?

_mint(sponsor.address, projectID, 1, "");
Would projectID come from this mapping?
*****************************************************************
ChangeDao.sol
set withdrawal percentages used by project clones
approve organizations to become changemakers
deploy ChangeMaker.sol
organizations create their changemaker clones

ChangeMaker.sol
deploy Project.sol
a changemaker creates project clones

Project.sol
fund project
refund
withdraw funds based on set percentages
mint
