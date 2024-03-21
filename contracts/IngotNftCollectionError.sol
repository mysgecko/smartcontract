// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

////////////////////////////
// Define Error - START //
////////////////////////////

error InsufficientValue(uint256 value, uint256 mintPrice);
error InvalidAddr(address inputAddress);
error InsufficientMint(uint32 expected, uint32 max);
error ReachedMintLimit();
error InsufficientSupply(uint256 maxSupp, uint256 circulateSupp);
error ByteCodeLengthNotMet(bytes input, uint256 lengthInt);
error NotWhitelistAddress();

////////////////////////////
// Define Error - END  //
////////////////////////////
