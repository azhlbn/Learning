// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { AccessControl } from "@openzeppelin/access/AccessControl.sol";

import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { SafeERC20 } from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

import { IAirdrop } from "src/libraries/IAirdrop.sol";


contract Airdrop is IAirdrop {
    using SafeERC20 for Token;

    // Target ERC20 token
    Token public token;

    // Total number of mints
    uint256 public mintsNumber;

    // Only one mint allowed for each user
    mapping(address user => bool isAirdropped) public alreadyAirdropped;

    // Presetted limits
    uint256 public constant USER_LIMIT = 100;
    uint256 public constant MINT_PER_USER_LIMIT = 1000;

    constructor(address _tokenAddr) {
        token = Token(_tokenAddr);
    }

    function mint(
        uint256 amount,
        bytes32[] memory proof, 
        bytes32 root, 
        bytes32 leaf
    ) external {
        address user = msg.sender;

        if (mintsNumber == USER_LIMIT) revert UserLimitReached();
        if (amount > 1000 || amount == 0) revert WrongAmount();
        if (alreadyAirdropped[user]) revert AlreadyAirdropped();
        if (!MerkleProof.verify(proof, root, leaf)) revert NotAllowedToMint();

        alreadyAirdropped[user] = true;
        mintsNumber++;
        token.safeTransfer(user, amount);

        emit Minted(user, amount);
    }
}

contract Token is ERC20, AccessControl {
    bytes32 public immutable AIRDROP;

    constructor(address _airdropAddr) ERC20("Great Token", "GT") {
        AIRDROP = keccak256("AIRDROP");

        grantRole(AIRDROP, _airdropAddr);
    } 

    /// @notice Tokens are issued via an airdrop contract
    function mint(address who, uint256 amount) external onlyRole(AIRDROP) {
        _mint(who, amount);
    }
}