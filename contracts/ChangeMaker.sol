//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Project.sol";

contract ChangeMaker is ERC721 {
  address public owner;
  using Counters for Counters.Counter;
  Counters.Counter public projectTokenId;
  address projectImplementation;
  mapping (uint256 => address) public projectIdToProjectContract;

  function initialize(address _owner) public {
    owner = _owner;
    projectImplementation = address(new Project());
  }

  function createProject(
    uint256 _expirationTime,
    uint256 _fundingThreshold
  )
    public
  {
    require(msg.sender == owner, "Msg.sender must be contract owner");

    address clone = Clones.clone(projectImplementation);

    projectTokenId.increment();
    uint256 currentToken = projectTokenId.current();

    _safeMint(msg.sender, currentToken);
    projectIdToProjectContract[currentToken] = clone;

    Project(clone).initialize(
      msg.sender,
      _expirationTime,
      _fundingThreshold
    );
  }
}
