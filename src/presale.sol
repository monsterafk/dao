// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../node_modules/@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol" ;
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Presale {
    address immutable usdt;
    uint256 public tokensHave = 100_000_000 * 1e18;
    uint256 minAmountUSDT = 50 * 10 ** 6;
    Buyer[] public buyers;

    AggregatorV3Interface immutable oracle;

    struct Buyer{
        address buyer;
        uint256 amountTokens;
    }

    event TokensBuyed(address buyer, uint256 amount);

    constructor(address oracle1, address usdT) {
        oracle = AggregatorV3Interface(oracle1);
        usdt = usdT;
    }

    function buyWithUSDT(address token, uint256 amount) external  returns(uint256){
        require(token == usdt, "Only usdt");
        require(IERC20(token).allowance(msg.sender, address(this)) >= amount);
        require(amount >= minAmountUSDT);

        IERC20(token).transferFrom(msg.sender, address(this), amount);

        uint256 amountTokens = (amount / 50) * 100;// 0.5$ token price 
        require(tokensHave - amountTokens >= 0); 

        buyers.push(Buyer({
            buyer: msg.sender,
            amountTokens: amountTokens
        }));

        tokensHave -= amountTokens;

        emit TokensBuyed(msg.sender, amountTokens);
        return amountTokens;
    }

    function buyPerETH() external payable returns(uint256){
        require(msg.value >= 0.05 ether);
        

        uint256 value = msg.value;
        uint256 amount = tokenPrice(value);
        require(tokensHave - amount >= 0);

        buyers.push(Buyer({
            buyer: msg.sender,
            amountTokens: amount
        }));

        tokensHave -= amount;

        emit TokensBuyed(msg.sender, amount);
        return amount;
    }

    function tokenPrice(uint256 value) internal view returns(uint256 amount) {
        (,int256 ethUsd,,,) = oracle.latestRoundData();

        ethUsd = (ethUsd / 1e8);
        int256 tokenOnePrice = (1 / ethUsd) / 2;
        
        amount = value / uint256(tokenOnePrice);
    }

    function getBuyers() external view returns(Buyer[] memory){
        return buyers;
    }
    
}
