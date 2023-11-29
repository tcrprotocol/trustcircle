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

contract Staking {

    using SafeMath for uint256;
    IERC20 tcr;

    uint256 constant BP = 2324480;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 duration;
    }

    mapping(address => Stake) private _stakes;

    constructor(address _addr) {
        tcr = IERC20(_addr); 
    }

    function stake(uint256 _amount, uint256 _duration) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_stakes[msg.sender].amount == 0, "You already have an active stake");

        // Transfer TCR tokens from user to contract
        tcr.transferFrom(msg.sender, address(this), _amount);

        _stakes[msg.sender] = Stake({
            amount: _amount,
            startTime: block.timestamp,
            duration: _duration
        });
    }

    function withdraw() external {
        require(_stakes[msg.sender].amount > 0, "No active stake");
        require(block.timestamp >= _stakes[msg.sender].startTime + _stakes[msg.sender].duration, "Stake duration not over yet");

        uint256 stakedAmount = _stakes[msg.sender].amount;
        delete _stakes[msg.sender]; // Clear user's stake data

        // Calculate and transfer reward
        uint256 reward = calculateReward(stakedAmount, _stakes[msg.sender].duration);
        tcr.transfer(msg.sender, stakedAmount + reward);
    }

    function calculateReward(uint256 _amount, uint256 _duration) internal pure returns (uint256) {
        // This is a simple example, you can implement more complex reward calculations
        return _amount * _duration / 1 days; // Reward is the same as staked amount * duration in days
    }
}