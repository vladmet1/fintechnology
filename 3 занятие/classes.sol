// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Main{
    function GetMessage() public pure returns (string memory) {
        return "Hello world!";
    }
}

contract RectangleInfo is Main{
    uint public _area;
    uint public _perimetr;
    function GetArea(uint width, uint length) public virtual returns (uint) {
        require(width > 0 && length > 0, "Error! Width and length < 0");
        _area = width * length;
        return _area;
    }  
    function GetPerimetr(uint width, uint length) public virtual returns (uint) { 
        require(width > 0 && length > 0, "Error! Width and length < 0");
        _perimetr = 2 * (width + length);
        return _perimetr;
    }
}

contract CircleInfo is Main{
    uint public _area;
    uint public _perimetr;
    uint public constant pi = 3;
    function GetArea(uint radius) public returns (uint) {
        require(radius > 0, "Error! Radius < 0");
        _area = (pi * radius * radius);
        return _area;
    }
    function GetPerimetr(uint radius) public returns (uint) {
        require(radius > 0, "Error! Radius < 0");
        _perimetr = (2 * pi * radius);
        return _perimetr;
    }
}

contract SquareInfo is RectangleInfo{
    function GetArea(uint width, uint length) public override returns (uint) {
        require(width > 0 && length > 0, "Error! Width and length < 0");
        require(width == length, "Error! Width != length");
        _area = width * length;
        return _area;
    }  
    function GetPerimetr(uint width, uint length) public override returns (uint) {
        require(width > 0 && length > 0, "Error! Width and length < 0");
        require(width == length, "Error! Width != length");
        _perimetr = 2 * (width + length);
        return _perimetr;
    }
}