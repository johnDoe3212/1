// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./AccessControl.sol";

contract NFT is ERC721, AccessControl {

    address private owner;
    uint256 private whitelistStartTime;
    uint256 private publicStartTime;

    constructor() ERC721("EarthNFT", "ENFT") {
        owner = msg.sender;
        whitelistStartTime = 1714521900;
        publicStartTime = whitelistStartTime + 24 hours;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://black-imperial-hummingbird-238.mypinata.cloud/ipfs/QmYkuCegb8oja1BLGjvD2rzfdatySiN91RQHDTJoRe9ZgP/";
    }

    function whitelistMint(uint256 tokenId) public {
        require(!hasRole(msg.sender, "BLACKLIST_ROLE"), "You are blacklisted");
        
        require(block.timestamp >= whitelistStartTime, "Whitelist minting not started yet");
       
        require(hasRole(msg.sender, "WHITELIST_ROLE"), "You are not whitelisted");
        
        _safeMint(msg.sender, tokenId);
    }

    function publicMint(uint256 tokenId) public {
        require(!hasRole(msg.sender, "BLACKLIST_ROLE"), "You are blacklisted");
        
        require(block.timestamp >= publicStartTime, "Public minting not started yet");
        
        _safeMint(msg.sender, tokenId);
    }

    function setWhitelistStartTime(uint256 _startTime) public onlyOwner {
        whitelistStartTime = _startTime;
    }

    function setPublicStartTime(uint256 _startTime) public onlyOwner {
        publicStartTime = _startTime;
    }
}