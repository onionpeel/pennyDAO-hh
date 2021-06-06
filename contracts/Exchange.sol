//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Exchange {
  mapping (address => uint256) pointsBalances;
  uint8 borrowPercentage;

  constructor() {}

  //use case #1
  //Sponsor/ChangeDao directly funds a project
  function directlyFundProject(uint256 projectId, uint256 amount) public {
    
  }


  //use case #2
  //Sponsor/ChangeDao deposits to Alchemix and then borrows against that deposit.  The sponsor sends /////the borrowed amount to a project of the sponsor's choosing
  function sponsorProject(uint256 projectId, uint256 amount) public {
    transferFundsToAlchemix();
  }


  // use case #3
  //Sponsor/ChangeDao wants to have funds held in Alchemix without choosing to fund a project
  function depositInAlchemix() external {
    transferFundsToAlchemix();
  }


  //use case #4
  //???Is this needed?
  //Deposit to the Exchange.sol contract without transferring the funds to either Alchemix or a project
  function depositInExchange() external payable {}


  //Functions for managing Alchemix interactions
  //ChangeDao can set the percentage amount for any amount that is borrowed from Alchemix
  function changeBorrowPercentage(uint256 percentage) public onlyOwner returns(bool) {}
  function transferFundsToAlchemix() internal {}
  function transferFundsFromAlchemix() internal {}


  //Functions to manage points held in pointsBalances
  function checkPointsBalance(address pointsHolder) public returns (uint256) {
    return pointsBalances[pointsHolder];
  }

  function increasePointsBalance(address pointsHolder, uint256 increasePointsAmount) private {
    pointsBalances[pointsHolder] += increasePointsAmount;
  }

  function decreasePointsBalance(address pointsHolder, uint256 decreasePointsAmount) private {
    uint256 newPointsBalance = pointsBalances[pointsHolder] -= decreasePointsAmount;
    require(newPointsBalance >= 0, "Points balance cannot be overdrawn");
  }

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
