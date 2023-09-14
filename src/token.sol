// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PAZIK is ERC20 {
    address public admin;
    address[] public buyersOfTokens;

    mapping(address => bool) public blackListed;
    mapping(address => bool) public wasClaimed; // для клэйма
    mapping(address => uint) public lockedTokens; // для анлока
    mapping(address => uint) public claimTokens; // для клэйма

    uint8 public purchaseTax = 5; //покупка
    uint8 public sellTax = 5; // продажа

    event TokensUnlockedBy10(address[] buyers);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");  
        _;
    }

    constructor() ERC20("PAZIK", "PZK") {
        admin = msg.sender;

        _mint(address(this), 100_000_000 * (10 ** uint256(decimals()))); 
    }

    function blackList(address _addr, bool banned) external onlyAdmin {
        blackListed[_addr] = banned;
    }

    function setSellTax(uint8 _sellTax) external onlyAdmin {
        require(_sellTax == 6|| _sellTax == 100); 
        
        sellTax = _sellTax;
    }

    function setNewAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balanceOf(msg.sender) - lockedTokens[msg.sender] - amount >= 0, "wait token locked");
        require(!blackListed[msg.sender], "you are banned");

        if((msg.sender).code.length > 0) {
            uint256 taxToBuy = (amount * purchaseTax) / 100;
            uint256 amountToBuy = amount - taxToBuy;  
            
            super.transfer(admin, taxToBuy);
            return super.transfer(recipient, amountToBuy);            

        } else {
            return super.transfer(recipient, amount);
        }
    }

    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        require(!blackListed[from], "you are banned");
        require(balanceOf(from) - lockedTokens[from] - amount >= 0);
        _spendAllowance(from, to, amount);

        if(to.code.length > 0 ) {
            require(balanceOf(from) - lockedTokens[from] - amount >= 0);

            uint256 taxToSell = (amount * sellTax) / 100;

            super._transfer(from, admin, taxToSell);
            super._transfer(from, to, amount);     
            return true;

        } else{
            return super.transferFrom(from, to, amount);
        }
    }

    function unlockTokens() external onlyAdmin{
        for(uint256 i; i < buyersOfTokens.length; i++) {
            _unlock(buyersOfTokens[i]);
        }
        emit TokensUnlockedBy10(buyersOfTokens);
    }

    function _unlock(address user) private {
        lockedTokens[user] -= (claimTokens[user] / 100) * 10;
    }

    function claim() external {
        require(claimTokens[msg.sender] > 0, "you didn't buy a token");
        require(!wasClaimed[msg.sender], "you already claimed");

        wasClaimed[msg.sender] = true;
        lockedTokens[msg.sender] = claimTokens[msg.sender];

        _transfer(address(this), msg.sender, lockedTokens[msg.sender]);
    }

    function setTokens(address buyer, uint256 amountToLock) external onlyAdmin{
        claimTokens[buyer] = amountToLock;
        buyersOfTokens.push(buyer);
    }

    // ДЛЯ ТЕСТОВ!!!!!!!!
    function mint() external {
        _mint(msg.sender, 1000 * 1e18);
    }

}