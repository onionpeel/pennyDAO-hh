//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

///@title Create and retrieve data about sponsors
///@dev Project.sol inherits this contract
abstract contract Sponsors {
  ///This holds the data about a sponsor
  struct Sponsor {
    address sponsorAddress;
    uint256 projectId;
    uint256 fundingAmount;
    uint256 percentOfProjectFunding;
    uint256 fundingRank;
  }

  event CreatedSponsor(
    address sponsorAddress,
    uint256 projectId,
    uint256 fundingAmount
  );

  ///@notice Holds an array of the project ids of a specific sponsor
  mapping (address => uint256[]) projectsOfASponsor;

  ///@notice Function to create a new sponsor for a project
  ///@dev This function is called by Escrow:sponsorProject()
  function createSponsor() internal {

    //emit CreatedSponsor()
  }

  ///@notice Frontend can retrieve data about a particular sponsor
  function getSponsorInformation() public view {

  }
}
