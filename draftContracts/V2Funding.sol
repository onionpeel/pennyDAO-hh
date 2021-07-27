//SPDX-License-Identifier: MIT;
pragma solidity 0.8.0;

// This contract will be used to create clones
contract V2Funding {
  enum FundingSystem { UnSet, DirectFunding, Auction, CrowdFunding }

  FundingSystem public fundingSystem;

  function initialize(uint _fundingSystem) {
    fundingSystem = _fundingSystem;
  }

  function directFund() public {
    require(fundingSystem == 1, "Funding system must be DirectFunding");
  }

  function makeAuctionBid() public {
    require(fundingSystem == 2, "Funding system must be Auction");
  }

  function crowdFund() public {
    require(fundingSystem == 3, "Funding system must be CrowdFunding");
  }
}
