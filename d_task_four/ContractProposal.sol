// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Import counter library for a better way to tga and track different proposals
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";

contract ContractProposal {

    // DATA

    // variable to create "admin" functionality and store the owner of the contract
    address owner;

    // using Counters for Counters.Counter attaches library functions to a 
    // type Counters.Counter private _counter declares a variable of that type

    using Counters for Counters.Counter;
    Counters.Counter private _counter;

    // Proposal fields for each proposal
    struct Proposal {
            string title; // title or name of each proposal for ease of referencing
            string description; // Description of proposal
            uint256 approve; // Number of approve votes
            uint256 reject; // Number of reject votes
            uint256 pass; // NUmber of pass votes
            uint256 total_vote_end; // When the total votes in the proposal reaches this limit, proposal ends
            bool current_state; // This shows the current state of the proposal, meaning whether if passes of failes
            bool is_active; // This shows if others can vote to our contract
    }

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals

    address[] private voted_addresses;

    // constructor
    constructor() {
        owner = msg.sender;
        voted_addresses.push(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier active() {
        require(proposal_history[_counter.current()].is_active == true);
        _;
    }

    modifier newVoter(address _address) {
        require(!isVoted(_address), "Address has not voted yet");
        _;
    }

    // EXECUTE FUNCTIONS

    // ability to change ownership of contract - can only be done by owner
    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    function create(string calldata _title, string calldata _description, uint256 _total_vote_to_end) external onlyOwner {
            _counter.increment();
            proposal_history[_counter.current()] = Proposal(_title,_description, 0, 0, 0, _total_vote_to_end, false, true);
        }

    // voting functionality

    function vote(uint8 choice) external active newVoter(msg.sender) {
        Proposal storage proposal = proposal_history[_counter.current()];
        uint256 total_vote = proposal.approve + proposal.reject + proposal.pass;

        voted_addresses.push(msg.sender);

        if (choice == 1) {
                proposal.approve += 1;
                proposal.current_state = calculateCurrentState();
        } else if (choice == 2){
                proposal.reject += 1;
                proposal.current_state = calculateCurrentState();
        } else if (choice == 0) {
                proposal.pass += 1;
                proposal.current_state = calculateCurrentState();
        }

        if ((proposal.total_vote_to_end - total_vote == 1) && (choice == 1 || choice == 2 || choice == 0 )) {
                proposal.is_active = false;
                voted_addresses = [owner];
        }
    }

    // We used private because this function is just a helper function 
    // for our previous vote function and it is only being used in the 
    // contract.
-   // We used view because the function only views data from the 
    // blockchain and does not alter it.
    function calculateCurrentState() private view returns(bool) {
        Proposal storage proposal = proposal_history[_counter.current()];

        uint256 approve = proposal.approve;
        uint256 reject = proposal.reject;
        uint256 pass = proposal.pass;

        // basically asking if proposal.pass is an odd number
        // if it is then make it even by adding 1 so that it can be divided
        // by 2
        if(proposal.pass %2 == 1) {
            pass += 1;
        }

        pass = pass / 2;


        if (approve > reject + pass) {
            return true;
        } else {
            return false;
        }
    }
}
