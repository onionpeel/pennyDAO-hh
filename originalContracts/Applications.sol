// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {
    ERC721Enumerable
} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {
    ERC2771Context
} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";

/// @title PennyDAO Grant Applications
/// @author PennyDAO
/// @notice Interact with applications for a PennyDAO Grant
/// @dev This is essentially an ERC721 contract with transfer functionality disabled
contract Applications is ERC721, ERC721Enumerable, ERC2771Context {
    using Counters for Counters.Counter;

    enum ApplicationAction {Create, Update, Delete, Submit}

    event ApplicationEvent(
        ApplicationAction action,
        address indexed actor,
        uint256 indexed applicationId,
        uint256 timestamp
    );

    /// @param awardToken Address of an ERC20-compatible token to award
    /// @param recipient Address to send `awardToken` to if the application is approved
    /// @param awardAmount Amount of `awardToken` to send `recipient` if the application is approved
    /// @param ipfsMetadata IPFS CID where metadata exists for this application
    struct Application {
        address awardToken;
        address recipient;
        uint256 awardAmount;
        string ipfsMetadata;
    }

    address private _grantor;
    Counters.Counter private _tokenIdTracker;
    mapping(uint256 => Application) private _applications;

    constructor(address grantor, address trustedForwarder)
        ERC721("PennyDAO Grant Applications", "PDAO-GA")
        ERC2771Context(trustedForwarder)
    {
        _grantor = grantor;
    }

    /// @notice Create a PennyDAO grant application
    /// @dev `awardToken` must be a valid ERC20 token
    /// @param _application See `Application` struct for more information
    /// @return true on successful creation of an application
    function createApplication(Application calldata _application)
        external
        returns (bool)
    {
        uint256 applicationId = _tokenIdTracker.current();
        _applications[applicationId] = _application;
        _mint(_msgSender(), applicationId);

        emit ApplicationEvent(
            ApplicationAction.Create,
            _msgSender(),
            applicationId,
            block.timestamp
        );

        _tokenIdTracker.increment();
        return true;
    }

    /// @notice Getter function for retrieving application data
    /// @dev Will revert if `_applicationId` is a non-existent application
    /// @param _applicationId a valid application Id
    /// @return application An application struct containing stored data
    function retrieveApplication(uint256 _applicationId)
        external
        view
        returns (Application memory application)
    {
        require(ERC721._exists(_applicationId)); // dev: application does not exist
        application = _applications[_applicationId];
    }

    /// @notice Update an unsubmitted application
    /// @param _applicationId a valid applicationId
    /// @param _application a new Application struct with fields updated as necessary
    /// @return true on successful update of an application
    function updateApplication(
        uint256 _applicationId,
        Application calldata _application
    ) external returns (bool) {
        require(_msgSender() == ERC721.ownerOf(_applicationId)); // dev: _msgSender is not application owner
        _applications[_applicationId] = _application;

        emit ApplicationEvent(
            ApplicationAction.Update,
            _msgSender(),
            _applicationId,
            block.timestamp
        );

        return true;
    }

    /// @notice Delete a PennyDAO grant application
    /// @dev _msgSender must be the owner of the application
    /// @param _applicationId The application Id to delete
    /// @return true on successful deletion of an application
    function deleteApplication(uint256 _applicationId) external returns (bool) {
        require(_msgSender() == ERC721.ownerOf(_applicationId)); // dev: _msgSender is not application owner
        _burn(_applicationId);

        emit ApplicationEvent(
            ApplicationAction.Delete,
            _msgSender(),
            _applicationId,
            block.timestamp
        );

        return true;
    }

    /// @notice Submit an application to the PennyDAO for a vote
    /// @param _applicationId a valid application id
    /// @return true on successful submission of an application
    function submitApplication(uint256 _applicationId) external returns (bool) {
        require(_msgSender() == ERC721.ownerOf(_applicationId)); // dev: _msgSender is not application owner
        ERC721._safeTransfer(_msgSender(), _grantor, _applicationId, "");

        emit ApplicationEvent(
            ApplicationAction.Submit,
            _msgSender(),
            _applicationId,
            block.timestamp
        );

        return true;
    }

    /// @inheritdoc	IERC165
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(ERC2771Context).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @inheritdoc	ERC2771Context
    function _msgSender()
        internal
        view
        override(Context, ERC2771Context)
        returns (address sender)
    {
        sender = ERC2771Context._msgSender();
    }

    /// @inheritdoc	ERC2771Context
    function _msgData()
        internal
        view
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /// @inheritdoc	ERC721
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
