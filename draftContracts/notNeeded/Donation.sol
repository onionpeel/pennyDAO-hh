//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

///@title Allow people to donate to ChangeDAO
contract Donation is Ownable {
  IERC20 dai;
  IERC20 usdc;
  address payable recipient;

  constructor(
    address daiAddress,
    address usdcAddress,
    address payable _recipient
  )
  {
    dai = IERC20(daiAddress);
    usdc = IERC20(usdcAddress);
    recipient = _recipient;
  }

  fallback() external payable {}
  receive() external payable {}

  function changeRecipient(address payable _newRecipient) public onlyOwner {
    recipient = _newRecipient;
  }

  function withdrawETH() public onlyOwner {
    (bool success, ) = recipient.call{value: address(this).balance}("");
    require(success, "Failed to withdraw ETH");
  }

  function donateStablecoins(string memory _stablecoin, uint256 _amount) public {
    ///Transfer the sponsor's stablecoin to Donation.sol
    if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("dai"))) {
      ///The sponsor's DAI get transferred to the Projects.sol contract
      dai.transferFrom(msg.sender, address(this), _amount);
    } else if(keccak256(abi.encodePacked(_stablecoin)) == keccak256(abi.encodePacked("usdc"))) {
      ///The sponsor's USDC get transferred to the Projects.sol contract
      usdc.transferFrom(msg.sender, address(this), _amount);
    }
  }

  function withdrawStablecoins() public onlyOwner {
    uint256 daiBalance = dai.balanceOf(address(this));
    if (daiBalance > 0) {
      dai.transfer(msg.sender, daiBalance);
    }

    uint256 usdcBalance = usdc.balanceOf(address(this));
    if (usdcBalance > 0) {
      usdc.transfer(msg.sender, usdcBalance);
    }
  }
}
