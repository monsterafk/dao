// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/token.sol";
import "../src/testToken.sol";
import "forge-std/Test.sol";
import "../node_modules/@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "../node_modules/@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol";

contract TokenTest is Test {
    PAZIK paz;
    TestToken token1;            // указать адреса из тестнета или майнета 
    IUniswapV2Router01 router;
    IUniswapV2Pair pair;

    address owner = 0x49F2B238cC0AFf04fBdB8295589a10Df7c2C2e7D;
    address user = vm.addr(1);

    address[] paath = [address(token1), address(paz)];
    address[] paath2 = [address(paz), address(token1)];

    function setUp() public {
        vm.label(address(paz), "PAZIK");
        vm.label(address(token1), "TOKEN");

        vm.createSelectFork('https://data-seed-prebsc-2-s2.bnbchain.org:8545');
    }

    function testSetTokens() public {
        vm.prank(owner);
        paz.setTokens(user, 1000 * 1e18);

        vm.startPrank(user);
        paz.claim();

    }
    
    function testFailSetTokens() public {
        vm.prank(owner);
        paz.setTokens(user, 1000 * 1e18);

        vm.startPrank(user);
        paz.claim();
        paz.transfer(owner, 1);
    }

    function testAddLiq() public {
        vm.startPrank(owner);
        paz.mint();
        token1.mint();

        paz.approve(address(pair), 1000 * 1e18);
        token1.approve(address(pair), 1000 * 1e18);

        router.addLiquidity(address(paz), address(token1), 500 * 1e18, 500 * 1e18, 0, 0, owner, block.timestamp + 600);

    }

    function testSwapTax() public {
        vm.startPrank(owner);
        paz.mint();
        token1.mint();

        paz.approve(address(pair), 1000 * 1e18);
        token1.approve(address(pair), 1000 * 1e18);

        router.addLiquidity(address(paz), address(token1), 500 * 1e18, 500 * 1e18, 0, 0, owner, block.timestamp + 600);

        vm.stopPrank();

        vm.startPrank(user);

        token1.mint();
        paz.mint();

        token1.approve(address(pair), 1000 * 1e18);
        token1.approve(address(router), 1000 * 1e18);

        emit log_uint(paz.balanceOf(owner));

        router.swapExactTokensForTokens(100 * 1e18, 0, paath, user, block.timestamp + 600);

        emit log_uint(paz.balanceOf(owner));
    }

    function testUnlockTokens() public {
        vm.prank(owner);
        paz.setTokens(user, 1000 * 1e18);

        vm.prank(user);
        paz.claim();

        vm.prank(owner);
        paz.unlockTokens();

        vm.prank(user);
        paz.transfer(owner, 100 * 1e18);
    
    }

        function testFailUnlockTokens() public {
        vm.prank(owner);
        paz.setTokens(user, 1000 * 1e18);

        vm.prank(user);
        paz.claim();

        vm.prank(owner);
        paz.unlockTokens();

        vm.prank(user);
        paz.transfer(owner, 101 * 1e18);
    
    }

    function testFailclaim() public {
        vm.prank(owner);
        paz.setTokens(user, 1000 * 1e18);

        vm.startPrank(user);
        paz.claim();
        paz.claim();
    }
    
}
