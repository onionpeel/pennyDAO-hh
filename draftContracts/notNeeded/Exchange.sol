//SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import "hardhat/console.sol";

contract Exchange {
  IERC20 bt;
  //mainnet DAI address
  // address constant DAI = 0x6b175474e89094c44da98b954eedeac495271d0f;

  constructor(address btAddress) {
    bt = IERC20(btAddress);
  }

  //
  function buyBt(uint256 amount) public {

  }

}
