//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ChangeDAO";

contract Project {
  address public owner;

  // using Counters for Counters.Counter;
  // Counters.Counter public projectTokenId;
  // address immutable projectImplementation;
  // mapping (uint256 => address) public projectIdToProjectContract;

  uint256 public expirationTime;
  uint256 public fundingThreshold;
  uint256 public currentFunding;
  bool public isFullyFunded;
  bool public hasMinted;
  bool public hasWithdrawnChangeMakerShare;
  bool public hasWithdrawnChangeDaoShare;
  bool public hasWithdrawnCommunityFundShare;

  IERC20 dai;
  IERC20 usdc;
  ChangeDao changeDAO;

  function initialize(
    address _owner,
    uint256 _expirationTime,
    uint256 _fundingThreshold,
    address changeDAOAddress
  )
    public
  {
    owner = _owner;
    expirationTime = _expirationTime;
    fundingThreshold = _fundingThreshold;
    dai = IERC20(0x6b175474e89094c44da98b954eedeac495271d0f);
    usdc = IERC20(0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48);
    changeDAO = ChangeDAO(changeDAOAddress);
  }


  struct Sponsor {
    address sponsorAddress;
    uint256 sponsorFundingAmount;
    string sponsorStablecoin;
  }

  // uint256 public currentSponsorId;
  // mapping (uint256 => Sponsor) sponsors;

  Sponsor[] public sponsors;

  function fundProject(uint256 _amount, string memory _stablecoin) public {
    require(project.expirationTime > block.timestamp, "Funding period has ended");
    require(!project.projectFunding.isFullyFunded, "Project is already fully funded");

    ///currentFunding is stored with 18 decimal places.  USDC amounts need to be adjusted since they are stored with only 6.
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      uint256 usdcAdjustedAmount;
      usdcAdjustedAmount = _amount * 10**12;
      currentFunding += usdcAdjustedAmount;
    } else {
      currentFunding += _amount;
    }

    Sponsor memory newSponsor = Sponsor({
      sponsorAddress: msg.sender,
      sponsorFundingAmount: _amount,
      sponsorStablecoin: _stablecoin
    });

    sponsors.push(newSponsor);

    ///Transfer the sponsor's stablecoin to Project.sol
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("dai"))) {
      ///The sponsor's DAI get transferred to the Projects.sol contract
      dai.transferFrom(msg.sender, address(this), _amount);
    } else if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      ///The sponsor's USDC get transferred to the Projects.sol contract
      usdc.transferFrom(msg.sender, address(this), _amount);
    }
  }

  function returnFundsToAllSponsors() public onlyOwner {
    for(uint256 i = 0; i < sponsors.length; i++) {
      Sponsor memory sponsor = sponsors[i];

      if(keccak256(abi.encodePacked(sponsor.sponsorStablecoin)) == keccak256(abi.encodePacked("dai"))) {
        ///The sponsor's DAI gets returned to the sponsor
        dai.transfer(sponsor.sponsorAddress, sponsor.sponsorFundingAmount);
      } else if(keccak256(abi.encodePacked(sponsor.sponsorStablecoin)) ==
          keccak256(abi.encodePacked("usdc"))) {
        ///The sponsor's USDC gets returned to the sponsor
        usdc.transfer(sponsor.sponsorAddress, sponsor.sponsorFundingAmount);
      }
    }
  }

  
}
