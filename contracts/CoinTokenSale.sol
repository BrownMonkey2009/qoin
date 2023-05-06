// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

// Import QoinToken contract
import "./QoinToken.sol";

// Qoin token sale smart contract
contract QoinTokenSale {
    address payable private _wallet;
    uint256 private _weiRaised;
    uint256 private _tokensSold;
    uint256 private _tokenPrice;
    IERC20 private _qoinToken;

    // Constructor function
    constructor(address payable wallet, uint256 tokenPrice, address qoinTokenAddress) {
        require(wallet != address(0), "QoinTokenSale: wallet is the zero address");
        require(tokenPrice > 0, "QoinTokenSale: token price must be greater than zero");
        require(qoinTokenAddress != address(0), "QoinTokenSale: Qoin token address is the zero address");

        _wallet = wallet;
        _tokenPrice = tokenPrice;
        _qoinToken = IERC20(qoinTokenAddress);
    }

    // Fallback function
    fallback() external payable {
        buyTokens();
    }

    // Receive function
    receive() external payable {
        buyTokens();
    }

    // Returns the wallet address
    function wallet() public view returns (address payable) {
        return _wallet;
    }

    // Returns the wei raised
    function weiRaised() public view returns (uint256) {
        return _weiRaised;
    }

    // Returns the token price
    function tokenPrice() public view returns (uint256) {
        return _tokenPrice;
    }

    // Returns the number of tokens sold
    function tokensSold() public view returns (uint256) {
        return _tokensSold;
    }

    // Buy tokens
    function buyTokens() public payable {
        require(msg.value > 0, "QoinTokenSale: wei amount must be greater than zero");

        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount * _tokenPrice;
        require(_qoinToken.balanceOf(address(this)) >= tokens, "QoinTokenSale: insufficient balance for sale");

        _qoinToken.transfer(msg.sender, tokens);
        _weiRaised += weiAmount;
        _tokensSold += tokens;
        _wallet.transfer(weiAmount);
    }

     // End the token sale and transfer unsold tokens to the wallet
    function endSale() public {
        require(msg.sender == _wallet, "QoinTokenSale: only the wallet can end the sale");

        uint256 unsoldTokens = _qoinToken.balanceOf(address(this));
        if (unsoldTokens > 0) {
            _qoinToken.transfer(_wallet, unsoldTokens);
        }

        _wallet.transfer(address(this).balance);
    }
}
