// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Bond {
    address public issuer; // Эмитет
    uint256 public totalBonds; // Количество облигаций
    uint256 public bondPrice; // Стоимость одной облигации
    uint256 public interestRate; // Процентная ставка
    uint256 public maturityDate; // Дата погашения в Unix timestamp
    uint256 public totalInvested; // Сумма инвестиций
    bool public isIssued; // Выпущена?

    mapping(address => uint256) public bondHolders; // Связывает адрес инвестора с количеством купленных облигаций
    
    event BondsIssued(uint256 totalBonds, uint256 bondPrice, uint256 interestRate, uint256 maturityDate); // Событие, уведомляющее о выпуске облигаций
    event BondsPurchased(address indexed buyer, uint256 amount); // Событие, уведомляющее о покупке облигаций
    event BondsRedeemed(address indexed holder, uint256 amount); // Событие, уведомляющее о погашении облигаций
    event FundsWithdrawn(address indexed issuer, uint256 amount); // Событие, уведомляющее о снятии средств эмитентом

    // Ограничивает вызов функций только эмитентом
    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer can call this function");
        _;
    }

    // Ограничивает вызов функций до наступления даты погашения
    modifier onlyBeforeMaturity() {
        require(block.timestamp < maturityDate, "Bond sale period has ended");
        _;
    }

    // Ограничивает вызов функций после наступления даты погашения
    modifier onlyAfterMaturity() {
        require(block.timestamp >= maturityDate, "Bond redemption period has not started");
        _;
    }

    // Устанавливает адрес эмитента
    constructor() {
        issuer = msg.sender;
    }

    // Позволяет эмитенту выпустить облигации. Может быть вызвана только эмитентом.
    function issueBonds(uint256 _totalBonds, uint256 _bondPrice, uint256 _interestRate, uint256 _maturityDate) external onlyIssuer {
        require(!isIssued, "Bonds already issued");
        require(_totalBonds > 0, "Total bonds must be greater than zero");
        require(_bondPrice > 0, "Bond price must be greater than zero");
        require(_interestRate > 0, "Interest rate must be greater than zero");
        require(_maturityDate > block.timestamp, "Maturity date must be in the future");

        totalBonds = _totalBonds;
        bondPrice = _bondPrice * 1 ether;
        interestRate = _interestRate;
        maturityDate = _maturityDate;
        isIssued = true;

        emit BondsIssued(totalBonds, bondPrice, interestRate, maturityDate);
    }

    // Позволяет инвесторам покупать облигации, только до наступления даты погашения.
    function purchaseBonds() external payable onlyBeforeMaturity {
        require(msg.value > 0, "Amount must be greater than zero");
        uint256 amount = msg.value / bondPrice;
        require(amount > 0, "Insufficient ETH for bond purchase");
        require(totalBonds >= amount, "Not enough bonds available");

        bondHolders[msg.sender] += amount;
        totalBonds -= amount;
        totalInvested += msg.value;

        emit BondsPurchased(msg.sender, amount);
    }

    // Позволяет инвесторам погасить облигации и получить вложенные средства с начисленными процентами, после наступления даты погашения.
    function redeemBonds() external onlyAfterMaturity {
        uint256 amount = bondHolders[msg.sender];
        require(amount > 0, "No bonds to redeem");

        uint256 totalAmount = amount * bondPrice;
        uint256 interest = (totalAmount * interestRate * (maturityDate - block.timestamp)) / (365 days * 100); // Начисляет проценты на основе указанной ставки
        uint256 totalPayout = totalAmount + interest;

        require(address(this).balance >= totalPayout, "Insufficient contract balance for payout");

        bondHolders[msg.sender] = 0;
        payable(msg.sender).transfer(totalPayout);

        emit BondsRedeemed(msg.sender, amount);
    }

    receive() external payable {}
}
