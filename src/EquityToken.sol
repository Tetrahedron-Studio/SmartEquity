//SPDX-License Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICertificate} from "./interfaces/ICertificate.sol";

contract EquityToken is ERC20, Ownable {
    address public certificate;

    //for when an account is issues shares
    event NewHolder(address indexed holder, uint256 indexed shares);
    //for when an account shares is increased
    event ShareIncrease(address indexed holder, uint256 indexed increment);
    //for equity tokens are terminated
    event EquityTerminated(address indexed holder, uint256 indexed amount);

     modifier authorized {
        require(msg.sender == address(this) || msg.sender == owner());
        _;
    }

    constructor(string memory name, string memory symbol, address _certificate)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        /**
         * @dev The chief or admin contract should be the one to deploy the equity token
         *         @param name The name of the equity token
         *         @param symbol The symbol of the equity token
         */
        certificate = _certificate;
    }

    function decimals() public pure override returns (uint8) {
        /**
         * @notice Overridng decimals to return 0, as shares do not need to be fractionalized
         *
         */
        return 0;
    }

    function beforeTransfer(address to) internal {
        /**
         * @notice checks if the address 'to' holds the Certificate NFT
         */
        require(ICertificate(certificate).verify(to));
    }

    function transfer(address to, uint256 value) public override onlyOwner returns (bool) {
        /**
         * @notice only Owner can transfer tokens, Owner will most likely chief or admin contract
         */
        //ensure recipient holds certificate of equity
        beforeTransfer(to);
        bool held;
        if (balanceOf(to) >= 1) {
            //checks if recipient already has shares
            held = true;
        }
        _transfer(owner(), to, value);
        //if held == true, emit ShareIncrease
        if (held) emit ShareIncrease(to, value);
        //if held == false, emit NewHolder
        else emit NewHolder(to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override onlyOwner returns (bool) {
        address spender = _msgSender();
        beforeTransfer(to);
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        burnCertificate(from);
        return true;
    }

    function issue(uint256 amount) external onlyOwner {
        //Issue new batch of shares
        _mint(owner(), amount * 10 ** decimals());
    }

    function burnShares(address holder, uint256 amount) public authorized {
        //Teminate/burn equity tokens
        _burn(holder, amount);
        burnCertificate(holder);
        emit EquityTerminated(holder, amount);
    }

    function burnCertificate(address holder) public authorized {
        //terminate equity certificate
        if (balanceOf(holder) == 0) {
            ICertificate(certificate).burn(holder);
        }
    }

}
