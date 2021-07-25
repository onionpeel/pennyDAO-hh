//SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./Project.sol";

interface IChangeDao {
  function changeDaoPercentage() external view returns (uint16);
  function changeMakerPercentage() external view returns (uint16);
  function getCommunityFundPercentage() external view returns (uint16);
}

contract ChangeMaker is ERC721, Ownable, Initializable {
  address public cloneOwner;
  address public changeDao;
  address immutable projectImplementation;


  constructor() ERC721('ChangeMaker', 'CHNMKR') {
    projectImplementation = address(new Project());
  }

  /// @notice This replaces a constructor in clones
  /// @dev This function should be called immediately after the clone is created
  /// @param _cloneOwner The address of the cloneOwner instance that created the clone
  /// @param _changeDao The address of the changeDao instance
  function initialize(address _cloneOwner, address _changeDao) public initializer {
    // require(msg.sender == _cloneOwner, "Only cloneOwner can initialize");
    cloneOwner = _cloneOwner;
    changeDao = _changeDao;
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

  // FUNCTION TO SET PERCENTAGES
}
