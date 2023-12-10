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

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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


contract Airdrop is Ownable {
    using SafeMath for uint256;
    IERC20 tcr;

    uint256 constant BP = 100;
    uint256 public totalClaimed;
    bool public canClaim;

    mapping(address => bool) public  _hasClaimed;

    event Claimed(address indexed recipient, uint256 amount);

    constructor (address _address) { 
        tcr = IERC20(_address); 
    }

    function setStart(bool _canClaim)
        public 
        onlyOwner 
    { 
        canClaim = _canClaim;
    }

    function withdrawUnClaim(uint256 amount) 
        public 
        onlyOwner
    {
        require(amount <= tcr.balanceOf(address(this)), "insufficient balance");
        tcr.transfer(msg.sender, amount);
    }

    function claimAirdrop() 
        public 
    {
        
        require(canClaim, "Airdrop has ended.");
        require(!_hasClaimed[msg.sender], "Already claimed.");
        require(totalClaimed.add(20e18) <= BP.mul(1e18), "Airdrop has been fully claimed.");
        
        totalClaimed = totalClaimed.add(20e18);
        tcr.transfer(msg.sender, 20e18);
        _hasClaimed[msg.sender] = true;
    }
}







