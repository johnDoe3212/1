// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ComRev {
    address[] public candidates = [
        0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5,
        0x8553C5D2BEa806C3a22140C02fB1e5F1E38500C2,
        0x8BCB0bF9E36c4eF539a5BeAEa36577319B47a320
    ];

    mapping(address => bytes32) public commits;
    mapping(address => uint) public votes;
    bool votingStopped;

    function commitVote(bytes32 _hashedVote) external {
        require(!votingStopped);
        require(commits[msg.sender] == bytes32(0));

        commits[msg.sender] = _hashedVote;
    }

    function revealVote(address _candidate, bytes32 _secret) external {
        require(votingStopped);

        bytes32 commit = keccak256(abi.encodePacked(_candidate, _secret, msg.sender));

        require(commit == commits[msg.sender]);

        delete commits[msg.sender];

        votes[_candidate]++;
    }

    function stopVoting() external {
        require(!votingStopped);

        votingStopped = true;
    }

}