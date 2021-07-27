//SPDX-License-Identifier: MIT;
pragma solidity 0.8.0;

// This contract will be used to create clones
contract V2Funding {
  /// @notice Funding system options
  enum FundingSystem { DirectFunding, Auction, CrowdFunding }

  FundingSystem public fundingSystem;

  /// @notice The project will set up the funding system based on the changeMaker's preference
  /// @notice The type of funding system cannot be changed once it has been initialized
  function initialize(uint _fundingSystem) public {
    if (_fundingSystem == 0) {
      fundingSystem = FundingSystem.DirectFunding;
    } else if (_fundingSystem == 1) {
      fundingSystem = FundingSystem.Auction;
    } else {
      fundingSystem = FundingSystem.CrowdFunding;
    }
  }

  /* @notice fund() routes calls to the appropriate funding implementation function based on the funding system that was set using initialize() */
  function fund() public {
    if (fundingSystem == FundingSystem.DirectFunding) {
      _directFund();
    } else if (fundingSystem == FundingSystem.Auction) {
      _makeAuctionBid();
    } else {
      _crowdFund();
    }
  }

  /// @notice A sponsor gives directly to the project
  function _directFund() private {

  }

  /// @notice Participants send in an auction bid
  function _makeAuctionBid() private {

  }

  /// @notice A sponsor contributes toward a fundraising goal
  function _crowdFund() private {

  }
}
