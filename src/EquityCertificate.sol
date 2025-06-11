//SPDX-License identifier: MIT
pragma solidity ^0.8.28;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EquityCertificate is ERC721URIStorage, Ownable {
    /**
     * @dev CertificateNum -> number of certificates issued so far
     */
    uint public CertificateNum = 0;
    /**
     * @dev isHolder ->  maps holders and their certificate status - True or False
     */
    mapping(address => bool) public isHolder;
    /**
     * @dev isAuthorized -> maps addresses that can call certain functions 
     */
    mapping(address => bool) public isAuthorized;
    /**
     * @dev tokenIdOf -> maps holder addresss to certificateId
     */
    mapping(address => uint) public tokenIdOf;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender){}

    /**
     * @dev verify() -> verify that an address holds the equity certificate
     * @param holder -> address of holder
     */
    function verify(address holder) public view returns(bool) {
        return isHolder[holder];
    }

    /**
     * @dev onlyAuthorized -> ensures that only authorised addresses can call certain function
     */
    modifier onlyAuthorized() {
        require(isAuthorized[msg.sender] || msg.sender == owner());
        _;
    }

    /**
     * @dev authorize() -> gives addressauthorization, 
     */
    function authorize(address x) external onlyAuthorized {
        isAuthorized[x] = true;
    }

    /**
     * @dev mint() -> mint certificate to holder
     * @param holder -> address of holder
     * @param details -> link to the details of the holder
     */
    function mint(address holder, string memory details) external onlyOwner {
        //ensures holders doesn't already have a certificate
        require(isHolder[holder] == false, "Holder can't hold two certificates");
        //mint certificate
        _mint(holder, CertificateNum++);
        //update CertificateNum
        CertificateNum += 1;
        //map holder address to the certificateID
        tokenIdOf[holder] = CertificateNum;
        //set the Certificate Metadata
        _setTokenURI(CertificateNum, details);
        //
        isHolder[holder] = true;
    }

    /**
     * @dev burn() -> burn certificate
     */
    function burn(address holder) external onlyAuthorized {
        require(isHolder[holder], "holder does not hold certificate");
        _burn(tokenIdOf[holder]);
        isHolder[holder] = false;
    }
}