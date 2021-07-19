//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

contract Project {
  address public owner;
  // using Counters for Counters.Counter;
  // Counters.Counter public projectTokenId;
  // address immutable projectImplementation;
  // mapping (uint256 => address) public projectIdToProjectContract;

  uint256 public expirationTime;
  bool public hasMinted;
  uint256 public fundingThreshold;
  uint256 public currentFunding;
  bool public isFullyFunded;
  bool public hasWithdrawnChangeMakerShare;
  bool public hasWithdrawnChangeDaoShare;
  bool public hasWithdrawnCommunityFundShare;


  function initialize(address _owner) public {
    owner = _owner;
    // projectImplementation = address(new Project());
  }

  function fundProject() public {

  }

  function returnFundsToAllSponsors() public {

  }

  function createProjectNFTs() public {

  }
}
