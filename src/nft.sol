// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";  

contract MyNFT is ERC721 {
    constructor() ERC721("tt", "re"){
        _mint(msg.sender, 1);
    }
}