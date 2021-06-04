//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

//defines the interface of Project
interface IChangeMakers {
  function addChangeMaker(address _organization, bytes32 _name, uint256 _registrationTime) external;

  function authorize(address _changeMaker) public returns (bool);

  function checkAuthorization(address _changeMaker) public returns (bool);

  function removeAuthorization(address _changeMaker) public returns (bool);
}
