//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Project.sol";

contract ChangeMaker is ERC721, Ownable {
  // address public owner;
  using Counters for Counters.Counter;
  Counters.Counter public projectTokenId;
  address projectImplementation;
  address changeDAOAddress;
  mapping (uint256 => address) public projectIdToProjectContract;

  // constructor(
  //   address daiAddress,
  //   address usdcAddress,
  //   address changeDAOAddress
  // )
  //   ERC721("ChangeMaker", "CHNGv1IMPL")
  // {
  //   projectImplementation = address(new Project(daiAddress, usdcAddress, changeDAOAddress));
  // }

  constructor(
    // address _changeDAO
  )
    ERC721("ChangeMaker", "CHNGv1IMPL")
  {
    projectImplementation = address(new Project());
    // changeDAO = _changeDAO;
  }

  function initialize() public {
    changeDAOAddress = owner();
  }

  function createProject(
    uint256 _expirationTime,
    uint256 _fundingThreshold
  )
    public
    onlyOwner
  {
    // require(msg.sender == owner, "Msg.sender must be contract owner");

    address clone = Clones.clone(projectImplementation);

    projectTokenId.increment();
    uint256 currentToken = projectTokenId.current();

    _safeMint(msg.sender, currentToken);
    projectIdToProjectContract[currentToken] = clone;

    Project(clone).initialize(
      _expirationTime,
      _fundingThreshold,
      changeDAOAddress
    );
  }
}
