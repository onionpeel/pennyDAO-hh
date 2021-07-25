//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Project.sol";

contract ChangeMaker is ERC721, Ownable, Initializable {
  address public cloneOwner;
  address immutable projectImplementation;


  constructor() ERC721('ChangeMaker', 'CHNMKR') {
    projectImplementation = address(new Project());
  }

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the clone is created
  /// @dev The initializer modifier prevents this from being called more than once
  /// @param _cloneOwner The address of the ChangeDao instance that created the clone
  function initialize(address _cloneOwner) public initializer {
    cloneOwner = _cloneOwner;
  }

  // function createProject(
  //   uint256 expirationTime,
  //   uint256 fundingThreshold,
  //   uint256 minimumSponsorship
  // )
  //   public
  //   onlyOwner
  // {
  //   address clone = Clones.clone(projectImplementation);
  //
  //   projectTokenId.increment();
  //   uint256 currentToken = projectTokenId.current();
  //
  //   _safeMint(msg.sender, currentToken);
  //   projectIdToProject[currentToken] = clone;
  //
  //   Project(clone).initialize(
  //     expirationTime,
  //     fundingThreshold,
  //     minimumSponsorship,
  //     changeDAOAddress,
  //     changeDAOAdmin
  //   );
  // }
}
