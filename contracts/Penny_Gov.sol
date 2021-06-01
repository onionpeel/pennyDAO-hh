// //SPDX-License-Identifier: GPL-3.0
//
// pragma solidity ^0.8.0;
//
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import { ChangeToken } from "./ChangeToken.sol";
//
//
//
// contract governance {
//
//     address ChangeToken;
//     address applications;
//
//     event TimeToVote(uint256 indexed app_id, uint32 indexed timestamp);
//     event Voted(address indexed voter, bool yayOrNay, uint weight);
//
//     struct Vote {
//         uint256 yayAmount;
//         uint256 nayAmount;
//         uint amount;
//         mapping (address => bool) alreadyVoted; /// tracking people who've already voted
//         uint32 start;
//         uint32 end;
//         bool upForVote;
//     }
//     /// application id to the vote struct
//     mapping (uint256 => Vote) public alreadyVotedOn;
//
//     uint256 public currentlyVotingOn;
//
//     function putupforvote(
//         uint256 app_id,
//         uint amount) external {
//
//         require(IERC721(applications).ownerOf(app_id) == msg.sender);
//         alreadyVotedOn[app_id].upForVote = true;
//         alreadyVotedOn[app_id].start = block.timestamp;
//         alreadyVotedOn[app_id].end = block.timestamp + 30 days;
//
//
//         emit TimeToVote(app_id, block.timestamp);
//     }
//
//     function vote(
//         uint256 app_id,
//         bool yayOrNay) external {
//
//         require(alreadyVotedOn[app_id].upForVote && alreadyVotedOn[app_id].end >= block.timestamp);
//         require(!alreadyVotedOn[app_id].alreadyVoted[msg.sender]); /// prevent revoting
//         uint256 voting_weight = IERC20(CHANGE).balanceOf(msg.sender);
//         if (yayOrNay) {
//             alreadyVotedOn[app_id].yayAmount += voting_weight;
//         }
//         else {
//             alreadyVotedOn[app_id].nayAmount += voting_weight;
//         }
//         alreadyVotedOn[app_id].alreadyVoted[msg.sender] = True;
//         emit Voted(msg.sender, yayOrNay, voting_weight);
//     }
//
//     function finalize_vote(
//         uint app_id) external {
//
//         require(alreadyVotedOn[app_id].upForVote && alreadyVotedOn[app_id].end < block.timestamp);
//
//         if (alreadyVotedOn[app_id].yayAmount > alreadyVotedOn[app_id].nayAmount) {
//             ChangeToken(CHANGE).disburse_funds(IERC721(applications).ownerOf(app_id), alreadyVotedOn[app_id].amount);
//         }
//
//         alreadyVotedOn[app_id].upForVote = false;
//     }
//
//
// }
