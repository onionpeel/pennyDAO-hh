//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Project.sol";

contract ChangeMaker is ERC721, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter public projectTokenId;
  address projectImplementation;
  address changeDAOAddress;
  address changeDAOAdmin;
  bool private initialized;
  mapping (uint256 => address) public projectIdToProject;

  constructor() ERC721("ChangeMaker", "CHNGv1IMPL") {
    projectImplementation = address(new Project());
  }

  function initialize(address _changeDAOAdmin) public {
    require(!initialized, "Contract has already been initialized");
    initialized = true;
    changeDAOAddress = owner();
    changeDAOAdmin = _changeDAOAdmin;
  }

  function createProject(
    uint256 expirationTime,
    uint256 fundingThreshold,
    uint256 minimumSponsorship
  )
    public
    onlyOwner
  {
    address clone = Clones.clone(projectImplementation);

    projectTokenId.increment();
    uint256 currentToken = projectTokenId.current();

    _safeMint(msg.sender, currentToken);
    projectIdToProject[currentToken] = clone;

    Project(clone).initialize(
      expirationTime,
      fundingThreshold,
      minimumSponsorship,
      changeDAOAddress,
      changeDAOAdmin
    );
  }
}
