// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ERC20Permit, ERC20 } from "@openzeppelin/token/ERC20/extensions/ERC20Permit.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/access/Ownable2Step.sol";

import { IGr8TokenPermit } from "src/libraries/IGr8TokenPermit.sol";


contract Gr8TokenPermit is IGr8TokenPermit, ERC20Permit, Ownable2Step {
    uint256 public immutable SUPPLY_LIMIT;

    constructor(uint256 _supplyLimit)
        ERC20Permit("Great Token")
        ERC20("Great Token", "GR8")
        Ownable(msg.sender)
    {
        SUPPLY_LIMIT = _supplyLimit;
    }

    /// @notice Issue tokens by owner until supply limit reached    
    function mint(address _who, uint256 _amount) external onlyOwner {
        if (totalSupply() + _amount > SUPPLY_LIMIT) revert SupplyLimitReached();
        _mint(_who, _amount);

        emit Minted(_who, _amount);
    }

    /// @notice Transfer from any address without calling approve()
    function transferFromWithPermit(
        address _from,
        address _to,
        uint256 _amount,
        uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s
    ) external {
        ERC20Permit.permit(_from, _to, _amount, _deadline, _v, _r, _s);
        _transfer(_from, _to, _amount);

        emit TransferedWithPermit(_from, _to, _amount);
    }
}
