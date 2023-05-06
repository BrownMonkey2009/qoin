// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

// ERC-20 standard interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// Qoin token smart contract
contract QoinToken is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // Constructor function
    constructor(){
        name = "Qoin";
        symbol = "qoin";
        decimals = 18;
        _totalSupply = 1000000000 * (10 ** uint256(decimals)); // Total supply of 1,000,000,000 Qoin tokens
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    // Returns the total supply of Qoin tokens
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    // Returns the balance of the given address
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    // Transfers tokens from sender to recipient
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // Returns the amount of tokens that spender is allowed to spend on behalf of owner
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    // Approves spender to spend the given amount of tokens on behalf of the owner
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // Transfers tokens from sender to recipient using the allowance mechanism
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    // Internal transfer function
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "QoinToken: transfer from the zero address");
        require(recipient != address(0), "QoinToken: transfer to the zero address");
        require(_balances[sender] >= amount, "QoinToken: transfer amount exceeds balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    // Internal approval function
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "QoinToken: approve from the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

// Qoin token sale smart contract
contract QoinTokenSale {
    address payable private _wallet;
    uint256 private _weiRaised;
    uint256 private _tokensSold;
    uint256 private _tokenPrice;
    IERC20 private _qoinToken;

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
