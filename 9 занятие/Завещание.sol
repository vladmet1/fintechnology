// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Bequest {
    address public grandmother; // Бабушка
    address public trustee; // Поверенный
    uint256 public contractStartTime;
    bool public deathNotified;
    uint256 public deathNotificationTime;

    // Наследники
    struct Heir {
        uint256 amount;
        bool hasClaimed;
    }

    mapping(address => Heir) private heirs;
    address[] private heirAddresses;

    modifier onlyGrandmother() {
        require(msg.sender == grandmother, "You are not a grandmother.");
        _;
    }

    modifier onlyHeir() {
        require(heirs[msg.sender].amount > 0, "You are not an heir.");
        _;
    }

    modifier onlyTrustee() {
        require(msg.sender == trustee, "You are not a trustee.");
        _;
    }

    modifier afterDeath() {
        require(deathNotified && block.timestamp >= deathNotificationTime + 30 days, "30 days have not passed.");
        _;
    }

    modifier after10Years() {
        require(block.timestamp >= contractStartTime + 10 * 365 days, "10 years have not passed.");
        _;
    }

    modifier after15Years() {
        require(block.timestamp >= contractStartTime + 15 * 365 days, "15 years have not passed.");
        _;
    }

    event FundsDeposited(address indexed heir, uint256 amount); // Событие, уведомляющее о внесении бабушкой средств для наследника.
    event FundsWithdrawn(address indexed heir, uint256 amount); // Событие, уведомляющее об отзыве бабушкой средств для наследника.
    event DeathNotified(); // Событие, уведомляющее о смерти бабушки.
    event DeathNotificationCancelled(); // Событие, уведомляющее об отмене уведомления о смерти бабушки.
    event InheritanceClaimed(address indexed heir, uint256 amount); // Событие, уведомляющее об успешном получении наследником завещанных средств.

    constructor() {
        grandmother = msg.sender;
        contractStartTime = block.timestamp;
    }

    // Эта функция позволяет бабушке внести определённое количество Эфира для указанного наследника.
    function depositFunds(address heir, uint256 amount) external payable onlyGrandmother {
        require(msg.value == amount * 1 ether, "Incorrect Ether value sent");
        if (heirs[heir].amount == 0) {
            heirAddresses.push(heir);
        }
        heirs[heir].amount += amount * 1 ether;
        emit FundsDeposited(heir, amount * 1 ether);
    }

    // Эта функция позволяет бабушке отозвать определённое количество Эфира для указанного наследника.
    function withdrawFunds(address heir, uint256 amount) external onlyGrandmother {
        require(heirs[heir].amount >= amount * 1 ether, "The heir have insufficient Ether.");
        heirs[heir].amount -= amount * 1 ether;
        payable(grandmother).transfer(amount * 1 ether);
        emit FundsWithdrawn(heir, amount * 1 ether);
    }

    // Эта функция позволяет бабушке отозвать весь Эфир с контракта.
    function withdrawAll() external onlyGrandmother {
        uint256 balance = address(this).balance;
        for (uint256 i = 0; i < heirAddresses.length; i++) {
            heirs[heirAddresses[i]].amount = 0;
        }
        payable(grandmother).transfer(balance);
    }

    // Эта функция позволяет бабушке увидеть завещанное количество Эфира для указанного наследника.
    function viewHeirAllocation(address heir) external view onlyGrandmother returns (uint256) {
        return heirs[heir].amount;
    }

    // Эта функция позволяет бабушке назначить поверенного, который может уведомить о смерти бабушки.
    function setTrustee(address _trustee) external onlyGrandmother {
        trustee = _trustee;
    }

    // Эта функция позволяет поверенному сделать уведомление о смерти бабушки.
    function notifyDeath() external onlyTrustee {
        deathNotified = true;
        deathNotificationTime = block.timestamp;
        emit DeathNotified();
    }

    // Эта функция позволяет поверенному отозвать уведомление о смерти бабушки.
    function cancelDeathNotification() external onlyTrustee {
        deathNotified = false;
        emit DeathNotificationCancelled();
    }

    // Эта функция позволяет наследнику запросить перевод завещанных средств после подтверждения смерти бабушки.
    function claimInheritance() external afterDeath onlyHeir {
        Heir storage heir = heirs[msg.sender];
        require(heir.amount > 0, "No inheritance allocated");
        require(!heir.hasClaimed, "Inheritance already claimed");
        heir.hasClaimed = true;
        uint256 amount = heir.amount;
        heir.amount = 0;
        payable(msg.sender).transfer(amount);
        emit InheritanceClaimed(msg.sender, amount);
    }

    // Эта функция позволяет наследникам инициировать распределение наследства через 10 лет при согласии большинства.
    function initiateInheritanceWithConsensus() external after10Years onlyHeir {
        uint256 activeHeirs = 0;
        uint256 agreeingHeirs = 0;

        for (uint256 i = 0; i < heirAddresses.length; i++) {
            if (heirs[heirAddresses[i]].amount > 0) {
                activeHeirs++;
                if (heirs[heirAddresses[i]].hasClaimed) {
                    agreeingHeirs++;
                }
            }
        }

        require(activeHeirs > 2, "Not enough heirs");
        require(agreeingHeirs * 2 >= activeHeirs, "Insufficient consensus");

        distributeFunds();
    }

    // Эта функция позволяет наследникам инициировать распределение наследства через 15 лет.
    function initiateInheritanceAfter15Years() external after15Years onlyHeir {
        distributeFunds();
    }

    function distributeFunds() internal {
        for (uint256 i = 0; i < heirAddresses.length; i++) {
            Heir storage heir = heirs[heirAddresses[i]];
            if (heir.amount > 0 && !heir.hasClaimed) {
                uint256 amount = heir.amount;
                heir.amount = 0;
                heir.hasClaimed = true;
                payable(heirAddresses[i]).transfer(amount);
                emit InheritanceClaimed(heirAddresses[i], amount);
            }
        }
    }
}
