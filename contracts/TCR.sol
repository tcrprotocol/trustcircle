// https://trustcircle.world
/*
 * ooooooooooooooooooooooooooooooooooooooooooooooooo
 * ────────╔════╗──────╔╗─╔═══╗─────╔╗──────────────
 * ────────║╔╗╔╗║─────╔╝╚╗║╔═╗║─────║║──────────────
 * ────────╚╝║║╠╩╦╗╔╦═╩╗╔╝║║─╚╬╦═╦══╣║╔══╗──────────
 * ──────────║║║╔╣║║║══╣║─║║─╔╬╣╔╣╔═╣║║║═╣──────────
 * ──────────║║║║║╚╝╠══║╚╗║╚═╝║║║║╚═╣╚╣║═╣──────────
 * ──────────╚╝╚╝╚══╩══╩═╝╚═══╩╩╝╚══╩═╩══╝──────────
 * ooooooooooooooooooooooooooooooooooooooooooooooooo
 *
 * 
 * We have made some light modifications to the openzeppelin ER20
 * located here "@openzeppelin/contracts".
 * Please read below for a quick overview of what has been changed:
 *
 *
 * We have updated this contract to implement the openzeppelin Ownable standard.
 * We have updated the contract from 0.8.0;
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './DefaultTrustCircle.sol';

contract TCR is DefaultTrustCircle {
     constructor() DefaultTrustCircle("Trust Circle", "TCR") {
        _mint(msg.sender, 10240000e18);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}