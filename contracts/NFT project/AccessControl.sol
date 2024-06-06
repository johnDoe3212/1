// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AccessControl {
    
    address private owner;

    mapping(address => mapping(bytes32 => bool)) private roles;

    bytes32 public constant BLACKLIST_ROLE = keccak256("BLACKLIST_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");


    event RoleGranted(address indexed account, bytes32 indexed role);
    event RoleRevoked(address indexed account, bytes32 indexed role);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not an owner");
        _;
    }
    
    function grantRole(address account, string memory role) onlyOwner public {
        bytes32 roleHash = keccak256(abi.encodePacked(role));
        roles[account][roleHash] = true;
        emit RoleGranted(account, roleHash);
    }

    function revokeRole(address account, string memory role) onlyOwner public {
        bytes32 roleHash = keccak256(abi.encodePacked(role));
        roles[account][roleHash] = false;
        emit RoleRevoked(account, roleHash);
    }

    function hasRole(address account, string memory role) public view returns (bool) {
        bytes32 roleHash = keccak256(abi.encodePacked(role));
        return roles[account][roleHash];
    }

    function getMyRole() public view returns (string memory) {
        if (msg.sender == owner) {
            return "Owner";
        }else if (roles[msg.sender][BLACKLIST_ROLE]) {
            return "Blacklisted";
        } else if (roles[msg.sender][WHITELIST_ROLE]) {
            return "Whitelisted";
        } else {
            return "Public";
        }
    }
}