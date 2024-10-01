// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


interface  IAirdrop {
    /// @dev Merkle verifying failed
    error NotAllowedToMint();

    /// @dev Not allowed to cross USER_LIMIT
    error UserLimitReached();

    /// @dev User has already minted
    error AlreadyAirdropped();

    /// @dev Root value shouldn't be eq to zero
    error ZeroRoot();

    /// @dev Wrong amount
    error ZeroAmount();
    error TooLargeAmount();
    
    // Events below
    event Minted(address indexed user, uint256 indexed amount);
}