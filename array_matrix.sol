// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Test{

    uint[] public MyArray;
    uint[] public MyArray2 = [1,2,3];
    uint256[5] public MyFixedLengthArray;

    function AddElementToArray(uint value) public {
        MyArray.push(value);
        MyArray.push(value*2);
        MyArray.push(value);
        MyArray.pop();
    }

    function GetArrayLength() public view returns (uint){
        return MyArray.length;
    }

    function DeleteArraysElementByIndex(uint index) public {
        delete MyArray[index];
    }
}