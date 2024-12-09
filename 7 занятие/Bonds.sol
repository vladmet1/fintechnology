// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Bonds {
    using Strings for uint256;

    address public issuer; // Эмитент
    uint256 public totalBonds; // Количество облигаций
    uint256 public bondPrice; // Стоимость одной облигации
    uint256 public interestRate; // Процентная ставка
    uint256 public issuanceDate; // Дата выпуска облигаций
    uint256 public maturityDate; // Дата погашения в Unix timestamp
    uint256 public totalInvested; // Сумма инвестиций
    bool public isIssued; // Выпущена?

    mapping(address => uint256) private bondHolders; // Связывает адрес инвестора с количеством купленных облигаций
    mapping(address => bool) private  hasInvested; // Уже инвестор?

    address[] private investors; // Список инвесторов
    uint256 private totalInvestors; // Общее количество инвесторов

    event BondsIssued(uint256 totalBonds, uint256 bondPrice, uint256 interestRate, uint256 maturityDate); // Событие, уведомляющее о выпуске облигаций
    event BondsPurchased(address indexed buyer, uint256 amount); // Событие, уведомляющее о покупке облигаций
    event BondsRedeemed(address indexed holder, uint256 amount); // Событие, уведомляющее о погашении облигаций

    // Ограничивает вызов функций только эмитентом
    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer can call this function.");
        _;
    }

    // Ограничивает вызов функций до наступления даты погашения
    modifier onlyBeforeMaturity() {
        require(block.timestamp < maturityDate, "Bond sale period has ended.");
        _;
    }

    // Ограничивает вызов функций после наступления даты погашения
    modifier onlyAfterMaturity() {
        require(block.timestamp >= maturityDate, "Bond redemption period has not started.");
        _;
    }

    constructor() {
        issuer = msg.sender;
    }

    // Позволяет эмитенту выпустить облигации
    function issueBonds(uint256 _totalBonds, uint256 _bondPrice, uint256 _interestRate, uint256 _maturityDate) external onlyIssuer {
        require(!isIssued, "Bonds already issued.");
        require(_totalBonds > 0, "Total bonds must be greater than zero.");
        require(_bondPrice > 0, "Bond price must be greater than zero.");
        require(_interestRate > 0, "Interest rate must be greater than zero.");
        require(_maturityDate > block.timestamp, "Maturity date must be in the future.");

        totalBonds = _totalBonds;
        bondPrice = _bondPrice * 1 ether;
        interestRate = _interestRate;
        maturityDate = _maturityDate;
        issuanceDate = block.timestamp;
        isIssued = true;

        emit BondsIssued(totalBonds, bondPrice, interestRate, maturityDate);
    }

    // Позволяет инвесторам покупать облигации до наступления даты погашения
    function purchaseBonds() external payable onlyBeforeMaturity {
        require(msg.value > 0, "Amount must be greater than zero.");
        uint256 amount = msg.value / bondPrice;
        require(amount > 0, "Insufficient funds to purchase.");
        require(totalBonds >= amount, string(abi.encodePacked("Insufficient bonds to buy. Available bonds: ", totalBonds.toString())));

        if (!hasInvested[msg.sender]) { // Проверка на добавление инвестора в список
            investors.push(msg.sender);
            hasInvested[msg.sender] = true;
            totalInvestors++;
        }

        bondHolders[msg.sender] += amount;
        totalBonds -= amount;
        totalInvested += msg.value;

        emit BondsPurchased(msg.sender, amount);
    }

    // Позволяет эмитенту выводить все средства со счёта контракта, до наступления даты погашения*
    function withdrawFundsBeforeMaturity() external onlyIssuer onlyBeforeMaturity {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No funds available to withdraw.");

        payable(issuer).transfer(contractBalance);
    }

    // Позволяет эмитенту узнать общую сумму выплат инвесторам после наступления даты погашения*
    function calculateTotalPayout() public view onlyIssuer returns (uint256 totalPayout) {
        require(block.timestamp >= maturityDate, "Bond redemption period has not started.");

        totalPayout = 0;
        for (uint256 i = 0; i < totalInvestors; i++) {
            address investor = investors[i];
            uint256 amount = bondHolders[investor];
            if (amount > 0) {
                uint256 totalAmount = amount * bondPrice;
                uint256 interest = (totalAmount * interestRate * (maturityDate - issuanceDate)) / (1 days * 100); // Начисляет проценты
                totalPayout += totalAmount + interest;
            }
        }
    }

    // Позволяет эмитенту отправлять средства на счёт контракта*
    function transferToContract() external payable onlyIssuer {
        require(msg.value > 0, "Amount must be greater than zero.");
    }

    // Позволяет инвесторам узнать сумму выплат после наступления даты погашения*
    function calculateRedemptionAmount(address investor) public view returns (uint256 totalAmount, uint256 interest, uint256 totalPayout) {
        uint256 amount = bondHolders[investor];
        require(amount > 0, "You do not have bonds to redeem.");

        totalAmount = amount * bondPrice;
        interest = (totalAmount * interestRate * (maturityDate - issuanceDate)) / (1 days * 100); // Начисляет проценты
        totalPayout = totalAmount + interest;
    }

    // Позволяет инвесторам погасить облигации и получить выплаты после наступления даты погашения
    function redeemBonds() external onlyAfterMaturity {
        uint256 amount = bondHolders[msg.sender];
        require(amount > 0, "You do not have bonds to redeem.");

        uint256 totalAmount = amount * bondPrice;
        uint256 interest = (totalAmount * interestRate * (maturityDate - issuanceDate)) / (1 days * 100); // Начисляет проценты
        uint256 totalPayout = totalAmount + interest;

        require(address(this).balance >= totalPayout, "Insufficient contract balance for payout.");

        bondHolders[msg.sender] = 0;
        payable(msg.sender).transfer(totalPayout);

        emit BondsRedeemed(msg.sender, amount);
    }

    // Позволяет эмитенту выводить оставшиеся средства со счёта контракта, только после погашения всех облигаций*
    function withdrawRemainingFunds() external onlyIssuer {
        require(block.timestamp >= maturityDate, "Bond redemption period has not started.");
        for (uint256 i = 0; i < investors.length; i++) {
            require(bondHolders[investors[i]] == 0, "All bonds must be redeemed before withdrawing remaining funds.");
        }

        uint256 remainingBalance = address(this).balance;
        require(remainingBalance > 0, "Insufficient funds to withdraw.");

        payable(issuer).transfer(remainingBalance);
    }

    // Позволяет эмитенту выводить оставшиеся средства со счёта контракта, спустя месяц не дожидаясь погашения всех облигаций*
        function withdrawRemainingFundsAfterOneMonth() external onlyIssuer {
            require(block.timestamp >= maturityDate, "Bond redemption period has not started.");
            require(block.timestamp >= maturityDate + 30 days, "One month has not passed since maturity.");

            uint256 remainingBalance = address(this).balance;
            require(remainingBalance > 0, "Insufficient funds to withdraw.");

            payable(issuer).transfer(remainingBalance);
        }

    receive() external payable {}
}
