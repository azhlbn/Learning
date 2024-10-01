// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC20 } from "@openzeppelin/token/ERC20/ERC20.sol";
import { AccessControl } from "@openzeppelin/access/AccessControl.sol";

import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";

import { IAirdrop } from "src/libraries/IAirdrop.sol";


contract Airdrop is IAirdrop, AccessControl {
    // Target ERC20 token
    Gr8Token public token;

    // Total number of mints
    uint256 public totalUsers;

    // MerkleProof variables
    bytes32 public root;

    mapping(address user => uint256 amount) public mintedPerUser;

    // Presetted limits
    uint256 public constant USER_LIMIT = 100;
    uint256 public constant MINT_PER_USER_LIMIT = 1000;

    constructor(address _tokenAddr) {
        token = Gr8Token(_tokenAddr);
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Allows verified users to get tokens
    function mint(
        uint256 _amount,
        bytes32[] memory _proof, 
        bytes32 _leaf
    ) external {
        address user = msg.sender;

        if (totalUsers > USER_LIMIT) revert UserLimitReached();
        if (_amount == 0) revert ZeroAmount();
        if (mintedPerUser[user] + _amount > MINT_PER_USER_LIMIT) revert TooLargeAmount();
        if (!MerkleProof.verify(_proof, root, _leaf)) revert NotAllowedToMint();

        // incr totalUsers only if sender is new user
        if (mintedPerUser[user] == 0) totalUsers++;

        mintedPerUser[user] += _amount;
        token.mint(user, _amount);

        emit Minted(user, _amount);
    }

    /// @notice Set root for MerkleProof logic
    function updateRoot(bytes32 _root) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_root == bytes32(0)) revert ZeroRoot();
        root = _root;
    }
}

contract Gr8Token is ERC20, AccessControl {
    bytes32 public immutable AIRDROP;

    constructor(address _airdropAddr) ERC20("Great Token", "GR8") {
        AIRDROP = keccak256("AIRDROP");
        
        grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        grantRole(AIRDROP, _airdropAddr);
    } 

    /// @notice Tokens are issued via an airdrop contract
    function mint(address _who, uint256 _amount) external onlyRole(AIRDROP) {
        _mint(_who, _amount);
    }
}