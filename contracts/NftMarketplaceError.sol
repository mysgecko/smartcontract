// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

////////////////////////////
// Define Error - START //
////////////////////////////

error ByteCodeLengthNotMet(bytes input, uint256 lengthInt);
error InvalidAddr(address inputAddress);
error InvalidNumber(uint256 inputNumber);
error InvalidBool();
error InAuctionTimeframe();
error InvalidTimeframe();
error InvalidSignature();
error UsedSignature();
error UsedSalt();
error InvalidSalt();
error BiddedUser();
error InvalidStatus();
error NotParticipantAddress();
error NotWhitelistAddress();
error NotWhitelistToken();
error NonTransferableToken();
error FailedTransferNft(address sender, address receiver, address nftAddr);
error FailedTransferToken(address sender, address receiver, uint256 amount);
error ExceedNftsAmount();
error InsufficientBalance(string message);
error PriceNotMatch();
error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
error PriceNotMetExpectation(uint256 expectedPrice, uint256 submittedPrice);
error ItemNotForSale(address nftAddress, uint256 tokenId);
error NotListed(address nftAddress, uint256 tokenId);
error AlreadyListed(address nftAddress, uint256 tokenId);
error NotNftOwner();
error NotApprovedForMarketplace(uint256 totalAmount, address tokenAddress);
error NotSendTokenForMarketplace(uint256 totalAmount, address tokenAddress, address nftAddress);
error PriceMustBeAboveZero();
error PayLessThanExpectation();

//////////////////////////
// Define Error - END ////
//////////////////////////
