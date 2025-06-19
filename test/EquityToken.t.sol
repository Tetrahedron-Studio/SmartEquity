//SPDX-License Identifier: MIT
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {EquityToken} from "../src/EquityToken.sol";
import {EquityCertificate} from "../src/EquityCertificate.sol";

contract TokenTest is Test {
    EquityCertificate cert;
    EquityToken shares;
    function setUp() external {
        cert = new EquityCertificate("Test cert", "TCERT");
        shares = new EquityToken("Test shares", "TEST", address(cert));
        cert.authorize(address(shares));
        shares.issue(5e6);
    }

    function testDecimals() external {
        assertEq(shares.decimals(), 0);
        console.log(shares.decimals());
    }

    function testTransfer1() external {
        //check if transfer() reverts for non-holders
        console.log(address(1));
        vm.expectRevert("Only Approved accounts can receive shares");
        shares.transfer(address(1), 1e5);
    }

    function testTransfer2() external {
        //check if transfer() works for holders
        cert.mint(address(1), "abcd");
        shares.transfer(address(1), 1e5);
        assertEq(shares.balanceOf(address(1)), 1e5);
    }

    function testTransfer3() external {
        //test transferFrom()
        cert.mint(address(1), "abcd");
        shares.transfer(address(1), 1e5);
        cert.mint(address(2), "bcde");
        shares.transferFrom(address(1), address(2), 1e5);
        assertEq(shares.balanceOf(address(1)), 0);
        assertEq(shares.balanceOf(address(2)), 1e5);
        assertEq(cert.verify(address(1)), false);
    }

    function testBurn1() external {
        //test burnShares() for burning of some of a holder's shares
        cert.mint(address(1), "abcd");
        shares.transfer(address(1), 1e5);
        shares.burnShares(address(1), 6e4);
        assertEq(shares.balanceOf(address(1)), 4e4);
        assertEq(cert.verify(address(1)), true);
    }

    function testBurn2() external {
        //test burnShares() for burning of all of a holder's shares
        cert.mint(address(1), "abcd");
        shares.transfer(address(1), 1e5);
        shares.burnShares(address(1), 1e5);
        assertEq(shares.balanceOf(address(1)), 0);
        assertEq(cert.verify(address(1)), false);
    }

}