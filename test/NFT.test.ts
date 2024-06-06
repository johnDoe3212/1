import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { NFT } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("NFT", function () {
    let owner: SignerWithAddress;
    let user1: SignerWithAddress;
    let user2: SignerWithAddress;
    let user3: SignerWithAddress;
    let nft: NFT;

    beforeEach(async function () {
        [owner, user1, user2, user3] = await ethers.getSigners();
        const NFT = await ethers.getContractFactory("NFT");

        nft = await NFT.deploy();

        await nft.connect(owner).grantRole(user1.address, "WHITELIST_ROLE");
        await nft.connect(owner).grantRole(user2.address, "BLACKLIST_ROLE");
    });

    it("should be possible to grant roles only by owner", async function () {
        await expect(nft.connect(user1).grantRole(user2.address, "WHITELIST_ROLE")).to.be.revertedWith("Not an owner");

        expect(await nft.connect(owner).hasRole(user1.address, "WHITELIST_ROLE")).to.be.true;
        expect(await nft.connect(owner).hasRole(user2.address, "BLACKLIST_ROLE")).to.be.true;

        expect(await nft.connect(owner).hasRole(user3.address, "WHITELIST_ROLE")).to.be.false;
        expect(await nft.connect(owner).hasRole(user3.address, "BLACKLIST_ROLE")).to.be.false;
    });

    it("shouldn't be possible to mint before whitelistStartMint", async function () {
        await time.increaseTo(1714221900)
        await expect(nft.connect(user1).whitelistMint(1)).to.be.revertedWith('Whitelist minting not started yet');
    });
    
    it("should be possible to whitelistMint only by whitelisted address", async function () {
        await time.increaseTo(1714521901);
        expect(await nft.connect(user1).whitelistMint(1)).not.to.be.reverted;
        await expect(nft.connect(user2).whitelistMint(1)).to.be.revertedWith("You are blacklisted");
        await expect(nft.connect(user3).whitelistMint(1)).to.be.revertedWith("You are not whitelisted");
    });

    it("shouldn't be possible to mint by blacklisted address", async function () {
        await expect(nft.connect(user2).publicMint(1)).to.be.revertedWith("You are blacklisted");
    });

    it("shouldn't be possible to mint before startMint", async function () {
        await time.increaseTo(1714531901)
        await expect(nft.connect(user1).publicMint(1)).to.be.revertedWith('Public minting not started yet');
        await expect(nft.connect(user3).publicMint(2)).to.be.revertedWith('Public minting not started yet');
    });

    it("should be possible to publicMint for whitelisted and non-blacklisted addresses", async function () {
        await time.increaseTo(1714608300);
        expect(await nft.connect(user1).publicMint(1)).not.to.be.reverted;
        expect(await nft.connect(user3).publicMint(2)).not.to.be.reverted;
    });

    it("should be possible to change whitelistMint time only by owner", async function () {
        expect(await nft.connect(owner).setWhitelistStartTime(1714521901)).not.to.be.reverted;
        await expect(nft.connect(user1).setWhitelistStartTime(1714521901)).to.be.revertedWith("Not an owner");
    });

    it("should be possible to change publicMint time only by owner", async function () {
        expect(await nft.connect(owner).setPublicStartTime(1714608300)).not.to.be.reverted;
        await expect(nft.connect(user1).setPublicStartTime(1714608300)).to.be.revertedWith("Not an owner");
    });

    it("should be possible to revoke roles only by owner", async function () {
        await expect(nft.connect(user1).revokeRole(user2.address, "WHITELIST_ROLE")).to.be.revertedWith("Not an owner");
        await nft.connect(owner).revokeRole(user1.address, "WHITELIST_ROLE");
        await nft.connect(owner).revokeRole(user2.address, "BLACKLIST_ROLE");

        expect(await nft.connect(owner).hasRole(user1.address, "WHITELIST_ROLE")).to.be.false;
        expect(await nft.connect(owner).hasRole(user2.address, "BLACKLIST_ROLE")).to.be.false;  
    });

    it("should show correct roles", async function () {
        expect(await nft.connect(owner).getMyRole()).to.be.eq("Owner");
        expect(await nft.connect(user1).getMyRole()).to.be.eq("Whitelisted");
        expect(await nft.connect(user2).getMyRole()).to.be.eq("Blacklisted");
        expect(await nft.connect(user3).getMyRole()).to.be.eq("Public");
    });

    it("should give proper URI", async function () {
        await time.increaseTo(1814608300);
        await nft.connect(user1).whitelistMint(1);
        expect(await nft.connect(user1).tokenURI(1)).to.be.eq("https://black-imperial-hummingbird-238.mypinata.cloud/ipfs/QmYkuCegb8oja1BLGjvD2rzfdatySiN91RQHDTJoRe9ZgP/1"); 
    });
});