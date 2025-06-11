//SPDX-License identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EquityCertificate is ERC721, Ownable {
    /**
     * A verify function will be implemented
     *  verify(address) returns(bool) -> checks if that address holds the equity certificate
     *
     */

    //address -> tokenId
    mapping(address => uint256) public tokenIDs;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    //returns the tokenId of the given address
    function tokenIdOf(address owner) public view returns (uint256) {
        return tokenIDs[owner];
    }

    //destroy token
    function burn(address owner) external {
        _burn(tokenIdOf(owner));
    }
}
