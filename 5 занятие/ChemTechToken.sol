// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "scripts/IERC20.sol";

contract ChemTechToken is IERC20 {
    event transfer(address indexed from, address indexed to, uint256 value);
    event approval(address indexed owner, address indexed spender, uint256 amount);
    
    uint256 private _totalSupply;
    string public name;
    string public symbol = 'CTT';
    uint public decimals;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals){
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    
    function TotalSupply() external view returns (uint256){
        return _totalSupply;
    }

    function BalanceOf(address account) external view returns (uint256){
        return balanceOf[account];
    }

    function Transfer(address recipient, uint256 amount) external returns (bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit transfer(msg.sender, recipient, amount);
        return true;
    }

    function Approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender] -= amount;
        emit approval(msg.sender, spender, amount);
        return true;
    }

    function Allowance(address owner, address spender) external view  returns (uint256){
        return allowance[owner][spender];
    }

    function TransferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit transfer(sender, recipient, amount);
        return true;
    }
}