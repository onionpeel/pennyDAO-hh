//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import './Projects.sol';

/*@title This contract controls the holding of funds until a project's funding threshold is reached*/
abstract contract Escrow is Projects, Ownable {
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

    projectSponsorIds[_projectId].push(currentSponsorId);
    sponsors[currentSponsorId] = newSponsor;

    //TRANSFERFROM(MSG.SENDER, ADDRESS(THIS), _AMOUNT);
  }

  ///@notice Retrieves the current funding for a specific project
  function currentProjectFunding(uint256 _projectId) public view returns (uint256) {
    Project storage project = projects[_projectId];
    return project.currentFunding;
  }

  ///@notice ChangeDao can return funds to sponsors of a specific project in extraordinary circumstances
  function returnFundsToAllSponsors(uint256 _projectId) public onlyOwner {
    Project storage project = projects[_projectId];
    require(project.currentFunding > 0, "Project has no funds to return");

    uint256[] storage _projectSponsorIds = projectSponsorIds[_projectId];
    for(uint256 i = 0; i < _projectSponsorIds.length; i++) {
      Sponsor storage sponsor = sponsors[i];
      //dai_contract_address.transfer(sponsor.sponsorAddress, sponsor.fundingAmount);
    }
  }
}
