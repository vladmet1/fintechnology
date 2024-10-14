// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Main{
    function getMessage() public pure returns (string memory) {
        return "Hello world!";
    }
}

contract RectangleInfo is Main{
    uint private _area;
    uint private _perimetr;
    function getArea(uint width, uint length) public returns (uint) {
        require(width > 0 && length > 0, "Error! Width and length > 0");
        _area = width * length;
        return _area;
    }
    function getPerimetr(uint width, uint length) public returns (uint) {
        require(width > 0 && length > 0, "Error! Width and length > 0");
        _perimetr = 2 * (width + length);
        return _perimetr;
    }
}

contract CircleInfo is Main{
    uint256 private _area;
    uint256 private _perimetr;
    // uint256 private pi = 3.14;
    uint256 private constant pi = 3141592653589793238;
    uint256 private constant scale = 10**18; 
    function getArea(uint256 radius) public returns (uint256) {
        require(radius > 0, "Error! Radius > 0");
        // _area = pi * radius * radius;
        _area = (pi * radius * radius) / scale;
        return _area;
    }
    function getPerimetr(uint256 radius) public returns (uint256) {
        require(radius > 0, "Error! Radius > 0");
        // _perimetr = 2 * pi * radius;
        _perimetr = (2 * pi * radius) / scale;
        return _perimetr;
    }
}