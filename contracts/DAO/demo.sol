// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Demo {
    string public message;
    mapping(address => uint256) public balances;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) external {
        require(msg.sender == owner);
        owner = _to;
    }

    function pay(string calldata _message) external payable {
        message = _message;
        balances[msg.sender] = msg.value;
    }
}