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

contract TCRPresale is Ownable {
    using SafeMath for uint256;
    
    IERC20 tcr;

    uint256 constant BP = 2324480;

    bool    public started;
    uint256 public price;
    uint256 public ends;
    uint256 public hardcap;
    bool    public paused;
    uint256 public minimum;

    uint256 public totalOwed;
    uint256 public weiRaised;

    mapping(address => uint256) public claimable;

    constructor (address _address) { 
        tcr = IERC20(_address);
    }

    
    function pause(bool _paused)
        public 
        onlyOwner 
    { 
        paused = _paused;
    }

    function setPrice(uint256 _price)
        public 
        onlyOwner 
    { 
        price = _price; 
    }

    function setHardCap(uint256 _hardcap)   
        public 
        onlyOwner 
    { 
        hardcap = _hardcap;
    }

    function setMinimum(uint256 _minimum)
        public 
        onlyOwner 
    { 
        minimum = _minimum;
    }

    function unlock() 
        public 
        onlyOwner 
    { 
        ends = 0; 
    }

    function withdrawETH(uint256 amount) 
        public 
        onlyOwner
    {
        payable(msg.sender).transfer(amount);
    }

    function withdrawUnsold(uint256 amount) 
        public 
        onlyOwner 
    {
        require(amount <= tcr.balanceOf(address(this)).sub(totalOwed), "insufficient balance");
        tcr.transfer(msg.sender, amount);
    }

    function startPresale(uint256 _ends) 
        public 
        onlyOwner 
    {
        require(!started, "already started!");
        require(price > 0, "set price first!");
        require(hardcap > 0, "set hardcap first!");
        require(minimum > 0, "set minimum first!");

        started = true;
        paused = false;
        ends = _ends;
    }

    function calculateAmountPurchased(uint256 _value) 
        public 
        view 
        returns (uint256) 
    {
        return _value.mul(BP).div(price).mul(1e18).div(BP);
    }

    function claim() 
        public 
    {
        require(block.timestamp > ends, "presale has not yet ended");
        require(claimable[msg.sender] > 0, "nothing to claim");
        uint256 amount = claimable[msg.sender];
        claimable[msg.sender] = 0;
        totalOwed = totalOwed.sub(amount);
        require(tcr.transfer(msg.sender, amount), "failed to claim");
    }

    function buy() 
        public 
        payable 
    {
        require(block.timestamp < ends, "presale has ended");
        require(!paused, "presale is paused");
        require(msg.value >= minimum, "amount too small");
        require(weiRaised.add(msg.value) < hardcap, "hardcap exceeded");

        uint256 amount = calculateAmountPurchased(msg.value);
        require(totalOwed.add(amount) <= tcr.balanceOf(address(this)), "sold out");

        claimable[msg.sender] = claimable[msg.sender].add(amount);
        totalOwed = totalOwed.add(amount);
        weiRaised = weiRaised.add(msg.value);
    }
}