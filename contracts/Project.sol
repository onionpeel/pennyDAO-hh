//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ChangeDAO.sol";

contract Project is ERC721, Ownable {
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
  ChangeDAO changeDAO;

  constructor() ERC721("Project", "PRJTv1IMPL") {
    dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
  }

  function initialize(
    uint256 _expirationTime,
    uint256 _fundingThreshold,
    address _changeDAOAddress
  )
    public
  {
    expirationTime = _expirationTime;
    fundingThreshold = _fundingThreshold;
    changeDAO = ChangeDAO(_changeDAOAddress);
  }

  struct Sponsor {
    address sponsorAddress;
    uint256 sponsorFundingAmount;
    string sponsorStablecoin;
  }

  Sponsor[] public sponsors;

  function fundProject(uint256 _amount, string memory _stablecoin) public {
    require(expirationTime > block.timestamp, "Funding period has ended");
    require(!isFullyFunded, "Project is already fully funded");

    ///currentFunding is stored with 18 decimal places.  USDC amounts need to be adjusted since they are stored with only 6.
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      uint256 usdcAdjustedAmount;
      usdcAdjustedAmount = _amount * 10**12;
      currentFunding += usdcAdjustedAmount;
    } else {
      currentFunding += _amount;
    }

    if(currentFunding >= fundingThreshold) {
      isFullyFunded = true;
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

  //THIS WILL BE CHANGED TO USE ERC1155
  // function mintSponsorNFTs(string[] memory sponsorCIDs) public onlyOwner{
  //   require(!hasMinted, "NFTs for this project have already been minted");
  //   require(isFullyFunded, "Project needs to be fully funded before NFTs are minted");
  //   hasMinted = true;
  //
  //   for(uint256 i = 0; i < sponsors.length; i++) {
  //     Sponsor memory sponsor = sponsors[i];
  //
  //     _safeMint(sponsor.sponsorAddress, i + 1);
  //     ///??????????????
  //     //_setTokenURI(i + 1, sponsorCIDs[i]);
  //   }
  // }
}
