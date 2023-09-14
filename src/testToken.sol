// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {


    constructor() ERC20("TestToken", "TestToken") {
    

        _mint(address(this), 100_000_000 * (10 ** uint256(decimals()))); // эмиссия 
    }

    function mint() external {
        _mint(msg.sender, 1000 * 1e18);
    }
}