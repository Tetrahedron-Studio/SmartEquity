//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface ICertificate {
    //verify that an address holds the equity certificate
    function verify(address) external returns (bool);

    //burns the equity certificate of a specified address
    function burn(address owner) external;

    //returns the tokenID an address holds
    function tokenIdOf(address owner) external returns (uint256);
}
