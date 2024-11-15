// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    event _transfer(address indexed from, address indexed to, uint256 value);
    event _approval(address indexed owner, address indexed spender, uint256 value);

    uint256 private totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals;
    address public immutable OWNER;

    mapping(address => uint256) private balanceOf;
    mapping(address => mapping(address => uint256)) private allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals){
        OWNER = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    //Эта функция возвращает общее количество токенов, которые были созданы и находятся в обращении.
    function TotalSupply() external view returns (uint256){
        return totalSupply;
    }

    //Эта функция возвращает баланс токенов на указанном адресе.
    function BalanceOf(address account) external view returns (uint256){
        return balanceOf[account];
    }

    //Эта функция переводит указанное количество токенов от отправителя (msg.sender) на указанный адрес получателя.
    function Transfer(address recipient, uint256 amount) external override returns (bool){
        //Эта проверка гарантирует, что токены не будут переведены на нулевой адрес.
        require(recipient != address(0), "Attention! Transfer to the zero address.");
        //Эта проверка гарантирует, что у отправителя достаточно токенов для перевода.
        require(balanceOf[msg.sender] >= amount, "There is not enough money in the account.");
        
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit _transfer(msg.sender, recipient, amount);
        return true;
    }

    //Эта функция возвращает количество токенов, которые отправитель (spender) может потратить от имени создателя.
    //Это количество устанавливается функцией Approve.
    function Allowance(address owner, address spender) external view returns (uint256){
        return allowance[owner][spender];
    }

    //Эта функция устанавливает допуск для отправителя (spender) на указанное количество токенов от имени отправителя (msg.sender).
    function Approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender] = amount;
        emit _approval(msg.sender, spender, amount);
        return true;
    }

    //Эта функция переводит указанное количество токенов от отправителя (sender) на получателя.
    //Эта функция может быть вызвана только тем, кто имеет допуск от отправителя (sender).
    function TransferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
        //Эта проверка гарантирует, что токены не будут переведены на нулевой адрес.
        require(recipient != address(0), "Attention! Transfer to the zero address.");
        //Эта проверка гарантирует, что у отправителя достаточно токенов для перевода.
        require(balanceOf[sender] >= amount, "There is not enough money in the account.");
        //Эта проверка гарантирует, что у получателя достаточно допуска для перевода токенов от имени отправителя.
        require(allowance[sender][msg.sender] >= amount, "There is not enough allowance for transfer.");

        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit _transfer(sender, recipient, amount);
        return true;
    }
    //Эта функция создает указанное количество токенов и переводит их на указанный адрес.
    //Функция является внутренней, она может быть вызвана только из самого контракта или из производных контрактов.
    function _mint(address to, uint256 amount) internal {
        //Эта проверка гарантирует, что новые токены не будут созданы на нулевом адресе.
        require(to != address(0), "Attention! Mint to the zero address.");
        
        balanceOf[to] += amount;
        totalSupply += amount;
        emit _transfer(address(0), to, amount);
    }

    //Эта функция уничтожает указанное количество токенов с указанного адреса.
    //Функция является внутренней, она может быть вызвана только из самого контракта или из производных контрактов.
    function _burn(address from, uint256 amount) internal {
        //Эта проверка гарантирует, что токены не будут сожжены с нулевого адреса.
        require(from != address(0), "Attention! Burn to the zero address.");
        //Эта проверка гарантирует, что у адреса from достаточно токенов для сжигания.
        require(balanceOf[from] >= amount, "Burn amount exceeds balance");

        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit _transfer(from, address(0), amount);
    }

    //Эта функция вызывает внутреннюю функцию _mint для создания токенов.
    //Она является внешней и может быть вызвана только владельцем контракта благодаря модификатору.
    function mint(address to, uint256 amount) external OnlyOwner{
        _mint(to, amount);
    }

    //Эта функция вызывает внутреннюю функцию _burn для уничтожения токенов.
    //Она является внешней и может быть вызвана только владельцем контракта благодаря модификатору.
    function burn(address from, uint256 amount) external OnlyOwner{
        _burn(from, amount);
    }

    modifier OnlyOwner(){
        require(msg.sender == OWNER, "You are not the owner.");
        _;
    }
}

contract ISUCTToken is ERC20{
    constructor(address emissionCenter) ERC20 ("ISUCT", "ICT", 18){}
}