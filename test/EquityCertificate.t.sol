//SPDX-License Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {EquityToken} from "../src/EquityToken.sol";
import {EquityCertificate} from "../src/EquityCertificate.sol";

contract TestCertificate is Test {
    EquityCertificate cert;
    address x;
    function setUp() external {
        cert = new EquityCertificate("Test Certificate", "TCERT");
        x = address(1);
        cert.mint(x, "abcd");
    }

    function testMint() external {
        assertEq(cert.verify(x), true);
        assertEq(cert.ownerOf(1), x);
        console.log(cert.ownerOf(1));
    }

    function testMintTwice() external {
        vm.expectRevert("Holder can't hold two certificates");
        cert.mint(x, "bcde");
    }

    function testBurn() external {
        cert.burn(x);
        assertEq(cert.verify(x), false);
    }

    function testMintAfterBurn() external {
        cert.burn(x);
        cert.mint(x, "bcde");
        assertEq(cert.verify(x), true);
    }

    function testTransferFrom() external {
        vm.expectRevert("Soulbound: Certificate Transfer not possible");
        cert.transferFrom(x, address(2), 1);
    }

    function testApprove() external {
        vm.expectRevert("Soulbound: Certificate Transfer approval not possible");
        cert.approve(address(2), 1);
    }
}