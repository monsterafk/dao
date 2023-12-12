// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DaoToken.sol";
import "../src/PazitoDao.sol";

import "@openzeppelin/contracts/governance/TimelockController.sol";

contract DaoTest is Test {
    PazitoDaoToken tokenDao;
    TimelockController timelock;
    PazitoDao dao;
    Target sc;

    uint8 constant NO = 0;
    uint8 constant YES = 1;
    uint8 constant ABSTAIN = 2;

    address admin = makeAddr("paz");
    address[] proposers = [makeAddr("prop1"), makeAddr("prop2"), makeAddr("prop3")];
    address[] executors = [makeAddr("ex1"), makeAddr("ex2"), makeAddr("ex3")];
    address[] users = [makeAddr("us1"), makeAddr("us2"), makeAddr("us3")];

    address[] _target;
    uint256[] _value;
    bytes[] _calldata;
    string _description;

    bytes32 data = keccak256(abi.encodePacked("get()"));

    function setUp() external {
        vm.startPrank(admin);

        sc = new Target();
        tokenDao = new PazitoDaoToken();
        timelock = new TimelockController(0, proposers, executors, admin);
        dao = new PazitoDao(tokenDao, timelock);
        
        bytes32 PROPOSER_ROLE = keccak256("PROPOSER_ROLE");
        bytes32 EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");
        bytes32 CANCELLER_ROLE = keccak256("CANCELLER_ROLE");

        timelock.grantRole(PROPOSER_ROLE , address(dao));
        timelock.grantRole(EXECUTOR_ROLE , address(dao));
        timelock.grantRole(CANCELLER_ROLE , address(dao));  
        
        tokenDao.mint(users[0], 1_000_000);
        tokenDao.mint(users[1], 1_000_000);
        tokenDao.mint(users[2], 1_000_000);

        vm.stopPrank();

        vm.prank(users[0]);
        tokenDao.delegate(users[0]);

        vm.prank(users[1]);
        tokenDao.delegate(users[1]);

        vm.prank(users[2]);
        tokenDao.delegate(users[2]);

        vm.deal(address(dao), 5 ether);
        vm.deal(address(timelock), 10_000 ether);

    }

    function test_createPropose() public {
        vm.startPrank(proposers[0]);

        _target.push(admin);
        _value.push(1 ether);
        _calldata.push(bytes(""));
        _description = "send 1 ether";
        
        uint256 id = dao.propose(_target, _value, _calldata, _description);
        address proposer = dao.proposalProposer(id);

        assert(proposer == proposers[0]);

        vm.stopPrank();
    }

    function test_vote() public {
        vm.startPrank(proposers[0]);

        _target.push(admin);
        _value.push(1 ether);
        _calldata.push(bytes(""));
        _description = "send 1 ether";
                
        uint256 id = dao.propose(_target, _value, _calldata, _description);

        vm.stopPrank();

        vm.roll(2 days);

        vm.prank(users[0]);
        dao.castVote(id, NO);

        vm.prank(users[1]);
        dao.castVote(id, YES);

        vm.prank(users[2]);
        dao.castVote(id, ABSTAIN);

        (uint a, uint b, uint c) = dao.proposalVotes(id);
    }

    
    function test_execute() public {
        vm.startPrank(proposers[0]);

        _target.push(admin);
        _value.push(1 ether);
        _calldata.push(bytes(""));
        _description = "send 1 ether";
                
        uint256 id = dao.propose(_target, _value, _calldata, _description);

        vm.stopPrank();

        skip(1 days);
        vm.roll(86402);

        vm.prank(users[0]);
        dao.castVote(id, YES);

        vm.prank(users[1]);
        dao.castVote(id, YES);

        vm.prank(users[2]);
        dao.castVote(id, YES);

        skip(8 days);
        vm.roll(691202);

        bytes32 _descriptionHash = keccak256(bytes(_description));

        vm.startPrank(executors[0]);
        dao.queue(_target, _value, _calldata, _descriptionHash);
        
        skip(1 days);
        vm.roll(900002);

        dao.execute(_target, _value, _calldata, _descriptionHash);
    }

    function test_failExecute() public {
        vm.startPrank(proposers[0]);

        _target.push(admin);
        _value.push(1 ether);
        _calldata.push(bytes(""));
        _description = "send 1 ether";
                
        uint256 id = dao.propose(_target, _value, _calldata, _description);

        vm.stopPrank();

        skip(1 days);
        vm.roll(86402);

        vm.prank(users[0]);
        dao.castVote(id, YES);

        vm.prank(users[1]);
        dao.castVote(id, YES);

        vm.prank(users[2]);
        dao.castVote(id, YES);

        skip(8 days);
        vm.roll(691202);

        bytes32 _descriptionHash = keccak256(bytes(_description));

        vm.startPrank(executors[0]);
        dao.queue(_target, _value, _calldata, _descriptionHash);
        
        skip(1 days);
        vm.roll(900000);

        dao.execute(_target, _value, _calldata, _descriptionHash);
    }


}

contract Target {
    receive() external payable {}
    fallback() external payable {}

    function get() external pure returns(uint8) {
        return 2;
    }
}