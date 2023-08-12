// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/nftMarket.sol";
import "../src/nft.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract MarketTest is Test {
    MyNFT nft;
    NFTMarketplace market; 
    address user = vm.addr(1);

    function setUp() public {
        market = new NFTMarketplace();


    }

    function testPutUpSaleNFT() public{
        vm.startPrank(user);
        nft = new MyNFT();
        nft.approve(address(market), 1);
        market.putUpSaleNFt(address(nft), 1, 1 ether);
    }

    function testBuyNFt() public {
        vm.startPrank(user);
        nft = new MyNFT();
        nft.approve(address(market), 1);
        market.putUpSaleNFt(address(nft), 1, 1 ether);
        vm.stopPrank();

        market.buyNFt{value: 2 ether}(address(nft), 1);
        
        console.log(user.balance);
    }

    function testSetNewPrice() public {
        vm.startPrank(user);
        nft = new MyNFT();
        nft.approve(address(market), 1);
        market.putUpSaleNFt(address(nft), 1, 1 ether);

        market.setNewPrice(address(nft), 1, 3 ether);
        vm.stopPrank();

        market.buyNFt{value: 3 ether}(address(nft), 1);

        console.log(user.balance);
    }

    function testFailSetNewPrice() public {
        vm.startPrank(user);
        nft = new MyNFT();
        nft.approve(address(market), 1);
        market.putUpSaleNFt(address(nft), 1, 1 ether);

        vm.stopPrank();
        market.setNewPrice(address(nft), 1, 3 ether);
        market.buyNFt{value: 3 ether}(address(nft), 1);

        console.log(user.balance);
    }

    function testGetNftInfo() public {
        vm.startPrank(user);
        nft = new MyNFT();
        nft.approve(address(market), 1);
        market.putUpSaleNFt(address(nft), 1, 1 ether);
        vm.stopPrank();

        market.getNftInfo(address(nft), 1);
        market.buyNFt{value: 3 ether}(address(nft), 1);

    }

    function testDeleteNft() public {
        vm.startPrank(user);
        nft = new MyNFT();
        nft.approve(address(market), 1);
        market.putUpSaleNFt(address(nft), 1, 1 ether);
        market.deleteNft(address(nft), 1);
        vm.stopPrank();
    

    }
}
