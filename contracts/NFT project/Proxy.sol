// SPDX License-Identifier: MIT

pragma solidity ^0.8.0

contract Proxy {
    address private _implementation;

    constructor(address implementation) {
        _implementation = implementation;
    }

    function setImplementation(address newImplementation) external {
        _implementation = newImplementation;
    }

    fallback() external payable {
        address _impl = _implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}

}
