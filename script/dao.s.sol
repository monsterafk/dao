// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PazitoDao.sol";
import "../src/DaoToken.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract DaoDeploy is Script{
    PazitoDaoToken token;
    PazitoDao dao;
    TimelockController controller;

    address[] proposers;
    address[] executors;

    function run() external {
        uint pk = vm.envUint("PRIVATE_KEY_TEST");
        address owner = vm.envAddress("OWNER_TEST");

        vm.startBroadcast(pk);

        proposers.push(owner);
        executors.push(owner);

        controller = new TimelockController(0, proposers, executors, owner);
        token = new PazitoDaoToken();
        dao = new PazitoDao(token, controller);


        bytes32 PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
        bytes32 EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
        bytes32 CANCELLER_ROLE = keccak256("CANCELLER_ROLE");

        controller.grantRole(PROPOSER_ROLE , address(dao));
        controller.grantRole(EXECUTOR_ROLE , address(dao));
        controller.grantRole(CANCELLER_ROLE , address(dao));  



        vm.stopBroadcast();
    }
    
}

import "../src/tryhraph.sol";

contract Depl is Script{
    Evnt evens;

    function run() external {
        uint pk = vm.envUint("PRIVATE_KEY");
        string memory rpc = vm.envString("RPC");

        vm.startBroadcast(pk);

        vm.createSelectFork(rpc);

        evens = new Evnt();


        vm.stopBroadcast();
    }
    
}

