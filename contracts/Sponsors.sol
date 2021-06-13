//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

///@title Create and retrieve data about sponsors
///@dev Project.sol and ImpactNFT_Generator.sol inherit this contract
contract Sponsors {
  ///@notice This holds the data about a sponsor
  struct Sponsor {
    address sponsorAddress;
    uint256 projectId;
    uint256 sponsorId;
    uint256 sponsorFundingAmount;
  }
  ///@notice An array of this type of struct is passed into createTokens() in order to mint the NFTs
  struct SponsorTokenData {
    address sponsorAddress;
    string sponsorTokenURI;
  }

  event CreatedSponsor(
    address sponsorAddress,
    uint256 projectId,
    uint256 sponsorFundingAmount
  );

  ///@notice Holds an array of the project ids of a specific sponsor
  mapping (address => uint256[]) public projectsOfASponsor;
  ///@notice Sponsor id maps to its sponsor struct
  mapping (uint256 => Sponsor) sponsors;
  ///@notice Holds the id value of the most recently created sponsor
  uint256 public currentSponsorId;

  ///@notice Returns an array from the projectsOfASponsor mapping
  function getProjectsOfASponsor(address _sponsor) public view returns (uint256[] memory) {
    return projectsOfASponsor[_sponsor];
  }
}
