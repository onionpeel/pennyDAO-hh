//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

///@title Allow people to donate to ChangeDAO
contract Donation is OwnableUpgradeable {
  IERC20 dai;
  IERC20 usdc;
  address payable recipient;

  ///@notice Upgradeable contracts cannot use constructors. Once the contract is deployed, this initialize function is called to set variables that would normally be set inside of a constructor.
  function initialize(
    address daiAddress,
    address usdcAddress,
    address payable _recipient
  )
    public
    initializer
  {
    dai = IERC20(daiAddress);
    usdc = IERC20(usdcAddress);
    recipient = _recipient;
    __Ownable_init();
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

  function donate(string memory stablecoin) public {

  }

  function withdrawStablecoins() public onlyOwner {

  }
}
