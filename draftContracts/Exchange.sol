//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import './ImpactToken.sol';

contract Exchange {
  constructor() ImpactToken() {}

  // function sponsorProject(uint256 projectId, uint256 amount) public {
  //   dai.transfer(address(this), amount);
  //   impact.transfer(msg.sender, amount);
  // }
  //
  // function depositWithoutSponsoring() public {}
  //
  // function sendFundsToProject() {}
  //
  // function sponsorAnotherProject() {}
  //
  // function withdrawDeposit() public {}
  //
  // CREATE FALLBACK FUNCTION--to transfer any value to community fund
}
