// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IERC20 {
    function TotalSupply() external view returns (uint256);

    function BalanceOf(address account) external view returns (uint256);

    function Transfer(address recipient, uint256 amount) external returns (bool);

    function Allowance(address owner, address spender) external view returns (uint256);

    function Approve(address sender, uint256 amount) external returns (bool);
    
    function TransferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}