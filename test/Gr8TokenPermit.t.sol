// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import { SigUtils } from "test/SigUtils.sol";

import { Gr8TokenPermit } from "src/Gr8TokenPermit.sol";


contract Gr8TokenPermitTest is Test {
    Gr8TokenPermit token;
    SigUtils sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;

    uint256 SUPPLY_LIMIT = 1_000_000 ether;

    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        prank(owner);

        token = new Gr8TokenPermit(SUPPLY_LIMIT);
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        token.mint(owner, 100 ether);
    }

    function test_TransferWithPermit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1 ether,
            nonce: 0,
            deadline: 20 minutes
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        assertEq(token.balanceOf(owner), 100 ether);
        assertEq(token.balanceOf(spender), 0);

        prank(spender);

        token.transferFromWithPermit(
            owner, 
            spender, 
            permit.value, 
            permit.deadline, 
            v, r, s);

        assertEq(token.nonces(owner), 1);
        assertEq(token.balanceOf(owner), 100 ether - permit.value);
        assertEq(token.balanceOf(spender), permit.value);
        assertEq(token.allowance(owner, spender), 0);
    }

    function prank(address _addr) internal {
        vm.stopPrank();
        vm.startPrank(_addr);
    }
}