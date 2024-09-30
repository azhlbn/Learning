// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


contract IAirdrop {
    /// @dev Merkle verifying failed
    error NotAllowedToMint();

    /// @dev Not allowed to cross USER_LIMIT
    error UserLimitReached();

    /// @dev Amount shouldn't be eq to 0 and greater than MINT_PER_USER_LIMIT
    error WrongAmount();

    /// @dev User has already minted
    error AlreadyAirdropped();
    
    // Events below
    event Minted(address indexed user, uint256 indexed amount);
}