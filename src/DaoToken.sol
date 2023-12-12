// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/Nonces.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PazitoDaoToken is Ownable, ERC20, ERC20Permit, ERC20Votes  {  

    constructor() Ownable(msg.sender) ERC20("PazitoDaoToken", "PDT") ERC20Permit("PazitoDaoToken"){
        _mint(msg.sender, 1000);
    }
    function _update(address _from, address _to, uint256 _amount) internal override(ERC20, ERC20Votes){
        super._update(_from, _to, _amount);
    }

    function nonces(address _owner) public view virtual override(ERC20Permit, Nonces) returns(uint256){
        return super.nonces(_owner);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    // function burn(address _from, uint256 _amount) external {
    //     _burn(_from, _amount);
    // }
}