// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Test{

    mapping(address => Transaction[]) public TransactionLedger;

    struct Transaction{
        uint Timestamp;
        uint Value;
    }

    struct TransactionEther {
        uint Timestamp;
        uint ValueEther;
    }

    function Deposit() public payable {
        Transaction memory newTransaction = Transaction({
            Timestamp: block.timestamp,
            Value: msg.value
        });

        TransactionLedger[msg.sender].push(newTransaction);
    }

    function GetTransactions(address sender) public view returns (TransactionEther[] memory) {
        Transaction[] memory transactions = TransactionLedger[sender];
        TransactionEther[] memory transactionsEther = new TransactionEther[](transactions.length);

        for (uint i = 0; i < transactions.length; i++) {
            transactionsEther[i] = TransactionEther({
                Timestamp: transactions[i].Timestamp,
                ValueEther: transactions[i].Value / 1e18
            });
        }

        return transactionsEther;
    }
}