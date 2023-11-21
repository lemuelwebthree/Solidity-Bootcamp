// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ContractProposal {

    // Proposal fields for each proposal
    struct Proposal {
            string title; // title or name of each proposal for ease of referencing
            string description; // Description of proposal
            uint256 approve; // Number of approve votes
            uint256 reject; // Number of reject votes
            uint256 pass; // NUmber of pass votes
            uint256 total_vote_to_end; // When the total votes in the proposal reches this limit, proposal ends
            bool current_state; // This shows the current state of the propsoal, meaning whether if passes of failes
            bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
}
