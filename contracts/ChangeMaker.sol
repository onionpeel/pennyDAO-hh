//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ChangeMaker is Ownable, Initializable {
  address public changeDao;

  function initialize(address _changeDao) public initializer {
    changeDao = _changeDao;
  }

}
