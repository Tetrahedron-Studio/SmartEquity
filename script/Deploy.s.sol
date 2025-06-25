// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

import "../src/EquityCertificate.sol";
import "../src/EquityToken.sol";
import {Script} from "forge-std/Script.sol";

contract deploy is Script {
    function run() external {
        vm.startBroadcast();
        EquityCertificate cert = new EquityCertificate("TETRAHEDRON LABS", "TETRA");
        EquityToken shares = new EquityToken("TETRAHEDRON", "TETRA", address(cert));
        shares.issue(1e6);
        cert.mint(0x90F79bf6EB2c4f870365E785982E1f101E93b906, "abcd");
        cert.mint(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720, "1234");
        vm.stopBroadcast();
    }
}