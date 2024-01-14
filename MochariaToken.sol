// SPDX-License-Identifier: MIT

pragma solidity <= 0.8.4;

library SafeMath {

	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		if (a == 0) {
		return 0;
		}
		c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return a / b;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	}
}

abstract contract Ownable {
	address public _owner;

	// Modify owner
	event OwnershipTransfered(address indexed previousOwner, address indexed newOwner);
	
	constructor() {
		_owner = 0x36F00Ac7F211d515577c219eeaa8876D2aA9A3fd;
	}

	// Only Owner
	modifier onlyOwner() {
		require(msg.sender == _owner, "You are not the owner");
		_;
	}

	function _transferOwnership(address newOwner) public virtual onlyOwner{
		address previousOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransfered(previousOwner, newOwner);
	}
}

interface IBEP20 {
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
	
	// Events
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IBEP20Metadata {
	function name() external view returns (string memory);
	function symbol() external view returns (string memory);
	function decimals() external view returns (uint8);
}

contract MochariaToken is Ownable, IBEP20, IBEP20Metadata {
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;

	uint256 private _totalSupply;
	string private _name;
	string private _symbol;
	uint8 private _decimal;

	using SafeMath for uint256;

	constructor () {
		_totalSupply = 100000000000;
		_name = "Mocharia Token";
		_symbol = "CHAR";
		_decimal = 5;
		_balances[msg.sender] = _totalSupply;
		emit Transfer(address(0), msg.sender, _totalSupply);
	}

	function name() public virtual view override returns (string memory) {
		return _name;
	}

	function symbol() public virtual view override returns (string memory) {
		return _symbol;
	}

	function decimals() public virtual view override returns (uint8) {
		return _decimal;
	}

	function totalSupply() public virtual view override returns (uint256) {
		return _totalSupply;
	}

	function balanceOf(address account) public virtual view override returns (uint256) {
		return _balances[account];
	}

	function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public virtual view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public virtual override returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool){
		_transfer(sender, recipient, amount);
		uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "BEP20: transfer amount exceeds allowance");
		_approve(sender, msg.sender, currentAllowance - amount);
		return true;
	}

    function burn(uint256 amount) public virtual override onlyOwner returns (bool) {
        require(amount > 0, "Amount to burn must be greater than zero");
        require(amount <= _balances[msg.sender], "Burn amount exceeds owner's balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(msg.sender, 0x000000000000000000000000000000000000dEaD, amount);
        return true;
    }

	function transferOwnership(address newOwner) public virtual onlyOwner returns (bool){
		_transferOwnership(newOwner);
		return true;
	}

    function renounceOwnership() public virtual onlyOwner returns (bool){
        _transferOwnership(address(0));
        return true;
    }

	// Internal Functions
	function _transfer(address sender, address recipient, uint256 amount) internal virtual {
		require(_balances[sender] >= amount, "You don't have enough to continue with this transaction");
		require(recipient != address(0), "You are sending to a null account");
		_balances[sender] = _balances[sender].sub(amount);
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}

	function _approve(address owner, address spender, uint256 amount) internal virtual {
		require(owner != address(0), "Null address");
		require(spender != address(0), "Null address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

}