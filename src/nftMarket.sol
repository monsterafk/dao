// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace {
    struct Listing {
        address seller;
        address nft;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    event NewLot(address nft, uint256 tokenId, uint256 price);
    event NFTPurchased(address nft, uint256 tokenId, address buyer, uint256 price);
    event PriceChanged(address nft, uint256 tokenId, uint256 newPrice);
    event LotDeleted(address nft, uint256 tokenId);

    // modifier OwnerNft(uint256 tokenId) {
    //     require(listings[tokenId].seller == msg.sender, "You are not an owner");
    // }

    function putUpSaleNFt(address nft, uint256 tokenId, uint256 price) external {
        require(IERC721(nft).getApproved(tokenId) == address(this), "Not approved");
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);

        listings[nft][tokenId] = Listing({seller: msg.sender, nft: nft, tokenId: tokenId, price: price, active: true});
        emit NewLot(nft, tokenId, price);
    }

    function buyNFt(address nft, uint256 tokenId) external payable {
        require(msg.value >= listings[nft][tokenId].price, "Insufficient funds");
        require(listings[nft][tokenId].active, "Sold");

        (bool success,) = (listings[nft][tokenId].seller).call{value: msg.value}("");
        require(success);

        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
        listings[nft][tokenId].active = false;

        emit NFTPurchased(nft, tokenId, msg.sender, msg.value);
    }

    function setNewPrice(address nft, uint256 tokenId, uint256 newPrice) external {
        require(msg.sender == listings[nft][tokenId].seller, "You are not an owner");
        require(listings[nft][tokenId].active, "Sold");

        listings[nft][tokenId].price = newPrice;
        emit PriceChanged(nft, tokenId, newPrice);
    }

    function getNftInfo(address nft, uint256 tokenId) external view returns (address, uint256, bool) {
        require(listings[nft][tokenId].active);
        
        return (listings[nft][tokenId].seller, listings[nft][tokenId].price, listings[nft][tokenId].active);
    }

    function deleteNft(address nft, uint256 tokenId) external {
        require(msg.sender == listings[nft][tokenId].seller, "You are not an owner");
        require(listings[nft][tokenId].active, "Sold");

        IERC721(nft).transferFrom(address(this), msg.sender, tokenId);
        delete(listings[nft][tokenId]);

        emit LotDeleted(nft, tokenId);
    }

}
