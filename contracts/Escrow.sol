//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import './Projects.sol';

/*@title This contract controls the holding of funds until a project's funding threshold is reached*/
abstract contract Escrow is Projects {
  using Counters for Counters.Counter;

  Counters.Counter sponsorCount;

  ///@notice A sponsor funds a particular project
  function fundProject(
    uint256 _projectId,
    uint256 _amount,
    uint256 _percentOfProjectFunding
  )
    public
  {
    ///Retrieve the specific project
    Project storage project = projects[_projectId];

    require(project.expirationTime > block.timestamp, "Funding period has ended");
    require(!project.fullyFunded, "Project is already fully funded");

    project.currentFunding += _amount;
    project.numberOfFunders++;

    if(project.currentFunding >= project.fundingThreshold) {
      project.fullyFunded = true;
    }

    sponsorCount.increment();
    currentSponsorId = sponsorCount.current();
    projectsOfASponsor[msg.sender].push(currentSponsorId);


    ///Create a sponsor struct for the message sender
    Sponsor memory newSponsor = Sponsor({
      sponsorAddress: msg.sender,
      projectId: _projectId,
      sponsorId: currentSponsorId,
      fundingAmount: _amount,
      percentOfProjectFunding: _percentOfProjectFunding,
      fundingRank: 0
    });

    sponsors[_projectId][currentSponsorId] = newSponsor;
  }
}
