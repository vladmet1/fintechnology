// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Test{
    address public Owner;
    uint public CurrentAmount;

    constructor(){
        Owner=msg.sender;
    }

    function Deposit() external payable {
        CurrentAmount += msg.value;
    }

    function Withdraw() external IsOwner{
        uint accountBalance = address(this).balance;
        require(accountBalance > 0, "No money to withdraw.");
        payable(Owner).transfer(accountBalance);
        CurrentAmount = 0;
    }

    // Без выбора валют 
    // function TransferToAccount(address payable _recipient, uint TransferAmount) external IsOwner {
    //     require(TransferAmount > 0, "TransferAmount must be greater than zero.");
    //     require(address(this).balance >= TransferAmount, "Not enough money to transfer.");

    //     _recipient.transfer(TransferAmount);
    //     CurrentAmount -= TransferAmount;
    // }

    // С выбором валюты 1 = Ether, 0 = Wei
    function TransferToAccount(address payable recipient, uint TransferAmount, bool isEther) external IsOwner {
        require(TransferAmount > 0, "TransferAmount must be greater than zero.");
        uint Convert = isEther ? TransferAmount * 1 ether : TransferAmount;
        require(address(this).balance >= Convert, "Not enough money to convert.");
        require(CurrentAmount >= TransferAmount, "Not enough money in the transfer.");

        recipient.transfer(Convert);
        CurrentAmount -= Convert;
    }

    modifier IsOwner(){
        require(msg.sender == Owner, "You are not the owner of this contract.");
        _;
    }

}