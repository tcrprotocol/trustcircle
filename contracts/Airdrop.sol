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

contract Airdrop is Ownable {
    using SafeMath for uint256;
    IERC20 tcr;

    uint256 constant BP = 102400;
    uint256 private startTime;
    uint256 private endTime;
    uint256 public totalClaimed;
    uint256 public allocationAmount;

    mapping (address => uint256) public _airClaim;
    mapping(address => bool) public  _hasClaimed;

    event Claimed(address indexed recipient, uint256 amount);

    constructor (address _address) { 
        tcr = IERC20(_address); 
    }

    function setStart(uint256 _start)
        public 
        onlyOwner 
    { 
        startTime = _start;
    }

    function setEnds(uint256 _ends) 
        public 
        onlyOwner 
    {
        endTime = _ends;
    }
    
    function allocationQuota() 
        public 
        view 
        returns(uint256)
    {
        return _airClaim[msg.sender];
    }

    function setClaimableAmounts(address[] memory addresses, uint256[] memory amounts) 
        public 
        onlyOwner 
    {
        require(addresses.length == amounts.length, "Input arrays must have the same length.");
        
        for (uint256 i = 0; i < addresses.length; i++) {
            require(allocationAmount.add(amounts[i]) <= BP.mul(1e18), "Total claimable amount exceeds BP limit");
            _airClaim[addresses[i]] = _airClaim[addresses[i]].add(amounts[i]);
            allocationAmount = allocationAmount.add(amounts[i]);
        }
    }

    function claimAirdrop() 
        public 
    {
        require(block.timestamp >= startTime, "Airdrop claim not start.");
        require(block.timestamp <= endTime, "Airdrop claim ended.");

        require(!_hasClaimed[msg.sender], "Already claimed.");
        require(_airClaim[msg.sender] > 0, "Insufficient claim balance.");
        require(totalClaimed.add(_airClaim[msg.sender]) <= BP.mul(1e18), "Airdrop has been fully claimed.");
        
        totalClaimed = totalClaimed.add(_airClaim[msg.sender]);
        tcr.transfer(msg.sender, _airClaim[msg.sender]);
        _airClaim[msg.sender] = 0;
        _hasClaimed[msg.sender] = true;
    }
}



