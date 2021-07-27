//SPDX-License-Identifier: MIT;
pragma solidity 0.8.0;

// This contract will be used to create clones
contract V2Funding {
  enum FundingSystem { UnSet, DirectFunding, Auction, CrowdFunding }

  FundingSystem public fundingSystem;

  function initialize(uint _fundingSystem) {
    fundingSystem = _fundingSystem;
  }

  function fund() public {
    if(fundingSystem == FundingSystem.DirectFunding) {
      _directFund();
    } else if {
      if(fundingSystem == FundingSystem.Auction) {
        _makeAuctionBid()();
    } else {
      _crowdFund();
    }
  }


  function _directFund() private {
    require(fundingSystem == 1, "Funding system must be DirectFunding");
  }

  function _makeAuctionBid() private {
    require(fundingSystem == 2, "Funding system must be Auction");
  }

  function _crowdFund() private {
    require(fundingSystem == 3, "Funding system must be CrowdFunding");
  }
}
