//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ChangeMaker is Initializable {
  address private _owner;
  address private _changeDaoAddress;

  function initialize(address _changeDao) public initializer {
    _owner = msg.sender;
    _changeDaoAddress = _changeDao;
  }
}
