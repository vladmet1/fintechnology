// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Foo {
    using Strings for uint256;

    string public MyString = "Name";
    bytes public MyStringInBytes = "Name";
    uint public SomeValue = 10;

    function ConcatinateStrings(string memory a, string memory b)  public pure returns (string memory){
        return string(abi.encodePacked(a,b," "," ef"));
    }

    function GetMessage() public view returns (string memory){
        return string(abi.encodePacked("SomeValue = ", SomeValue.toString()));
    }
    
}