// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
 

contract Evnt {
    event Catch(uint amount);
    event Hide(string place);

    function go() external {
        emit Catch(1000);
        emit Hide("house");
    }
}