// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface IGr8TokenPermit {
    // Errors
    error SupplyLimitReached();

    // Events
    event Minted(address indexed who, uint256 indexed amount);
    event TransferedWithPermit(address indexed from, address indexed to, uint256 amount);
}