/*
 * ooooooooooooooooooooooooooooooooooooooooooooooooo
 * ────────╔════╗──────╔╗─╔═══╗─────╔╗──────────────
 * ────────║╔╗╔╗║─────╔╝╚╗║╔═╗║─────║║──────────────
 * ────────╚╝║║╠╩╦╗╔╦═╩╗╔╝║║─╚╬╦═╦══╣║╔══╗──────────
 * ──────────║║║╔╣║║║══╣║─║║─╔╬╣╔╣╔═╣║║║═╣──────────
 * ──────────║║║║║╚╝╠══║╚╗║╚═╝║║║║╚═╣╚╣║═╣──────────
 * ──────────╚╝╚╝╚══╩══╩═╝╚═══╩╩╝╚══╩═╩══╝──────────
 * ooooooooooooooooooooooooooooooooooooooooooooooooo
 */


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TrustCircleIdentityNFT is ERC721URIStorage, Ownable {

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    uint256 private _mintingPrice = 5 * 10 ** 16;

    mapping(address => uint256) private _addressToNFTs;

    event NFTMinted(address indexed owner, uint256 tokenId, string tokenURI);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) { }

    function mint(string memory uri) 
        public
        payable  
    {
        require(_addressToNFTs[msg.sender] == 0, "NFT has been minted");
        require(msg.value >= _mintingPrice, "Insufficient funds to mint NFT");
        
        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
        _addressToNFTs[msg.sender] = tokenId;
        
        payable(msg.sender).transfer( _mintingPrice);
        emit NFTMinted(msg.sender, tokenId, uri);
    }

    function getTokenId() 
        public 
        view 
        returns (uint256) 
    {
        return _addressToNFTs[msg.sender];
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function withdrawBalance(uint256 amount) 
        external 
        onlyOwner 
    {
        payable(msg.sender).transfer(amount);
    }
}
