// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract OwnersInfo{
    string private _info = "The owner of this contract is Ivan Ivanov.";
    function ShowInfoAboutOwner() internal view returns (string memory){
        return _info;
    }
    function Foo() public view {
        ShowInfoAboutOwner();
    }
}

contract CallCounter{
    uint private _counter;
    function AddOneUnit() public {
        _counter++;
    }
    function GetCounet() public view returns (uint){
        return _counter;
    }
}

contract ChangeInteger{
    uint public Counter;
    function AddValue() virtual public {
        Counter++;
    }
}

contract DepositMoney is OwnersInfo, CallCounter, ChangeInteger{
    function Deposit() public payable {
        AddOneUnit();
    }
    function AddValue() override public {
        Counter+=10;
    }
}

contract SendMessageToOwner is OwnersInfo, CallCounter{
    string[] public Messages;
    function Send(string memory message) public {
        Messages.push(message);
        AddOneUnit();
    }
}