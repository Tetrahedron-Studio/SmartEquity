//SPDX-License Identifier: MIT
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICertificate} from "./interfaces/ICertificate.sol";

contract EquityToken is ERC20, Ownable {
    address public certificate;

    /**
     * @dev NewHolder emits when an account is issued shares for the first time
     *  holder -> new holder of shares
     *  shares -> shares issued
     */
    event NewHolder(address indexed holder, uint256 indexed shares);

    /**
     * @dev ShareIncreased emits when an account shares is increased
     *  holder -> holder of shares
     *  incrememt -> amount of new shares holder received
     */

    event ShareIncreased(address indexed holder, uint256 indexed increment);
    /**
     * @dev EquityTerminated emits when equity tokens are terminated i.e burnt
     *   holder -> holder of shares
     *  amount -> amount of shares terminated
     */

    event EquityTerminated(address indexed holder, uint256 indexed amount);
    /**
     *  @dev CertificateTerminated emits when an equity certificate is terminated
     *  holder -> address of holder whose certificate got terminated
     */
    
    event CertificateTerminated(address indexed holder);

    constructor(string memory name, string memory symbol, address _certificate)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        /**
         * @dev The chief or admin contract should be the one to deploy the equity token
         *  name The name of the equity token
         *  symbol The symbol of the equity token
         */
        certificate = _certificate;
    }

    function decimals() public pure override returns (uint8) {
        /**
         * @dev Overridng decimals to return 0, as shares do not need to be fractionalized
         *
         */
        return 0;
    }

    function beforeTransfer(address account) internal {
        /**
         * @dev checks if the account holds an Equity Certificate by calling it's contract function verify() function
         */
        require(ICertificate(certificate).verify(account));
    }

    function transfer(address account, uint256 value) public override onlyOwner returns (bool) {
        /**
         * @dev transfer() -> transfer shares from the Admin contract's balance to new or existing holders
         * token = shares
         *   address account -> the address whom shares would be trasfered to
         *  value -> the amount of shares to be trasnfered
         */
        //using beforeTransfer to check if the account holds certificate of equity
        beforeTransfer(account);
        //held = true if the account already holds shares
        bool held = balanceOf(account) > 0;
        //transfer shares to the account
        _transfer(owner(), account, value);
        //emit the event that corresponds to the account's share ownership pre-transfer
        if (held) emit ShareIncreased(account, value);
        else emit NewHolder(account, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override onlyOwner returns (bool) {
        /**
         * @dev transfer shares between holders
         *  from -> account from which shares is being transfered
         *  to -> account which receives the shares
         *  value -> amount of shares been transferred
         */
        //using beforeTransfer to check if the account holds certificate of equity
        beforeTransfer(to);
        _spendAllowance(from, owner(), value);
        //transfer shares
        _transfer(from, to, value);
        //using burnCertificate() to check if address from now has 0 shares so his certificate of equity can be terminated
        burnCertificate(from);
        return true;
    }

    function issue(uint256 amount) external onlyOwner {
        /**
         * @dev issues shares to Admin Contract
         *  amount -> amount of shares to be issued
         */
        _mint(owner(), amount * 10 ** decimals());
    }

    function burnShares(address holder, uint256 amount) external onlyOwner {
        /**
         * @dev burnShares() -> terminate holder's shares
         *  holder -> account who's shares are getting terminated
         *  amount -> amount of shares to be terminate
         */
        //call ERC20 _burn() to specified amount of shares
        _burn(holder, amount);
        //using burnCertificate() to check if address from now has 0 shares so his certificate of equity can be terminated
        burnCertificate(holder);
        //emit the EquityTerminated event
        emit EquityTerminated(holder, amount);
    }

    function burnCertificate(address holder) internal {
        /**
         * @dev burnCertificate() -> Terminates equity certificate if holder's shares == 0
         *  holder -> account whose equity might be terminated
         */
        //checks if holder's balance = 0
        if (balanceOf(holder) == 0) {
            //call the equity certificate contract function burn
            ICertificate(certificate).burn(holder);
            //emit the CertificateTerminated event
            emit CertificateTerminated(holder);
        }
    }
}
