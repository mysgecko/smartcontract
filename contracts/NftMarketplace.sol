// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/access/Ownable2Step.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";


// ////////////////////////////
// // Define Error - START //
// ////////////////////////////

// error PriceNotMet(address nftAddress, uint256 tokenId, uint256 price);
// error ItemNotForSale(address nftAddress, uint256 tokenId);
// error NotListed(address nftAddress, uint256 tokenId);
// error AlreadyListed(address nftAddress, uint256 tokenId);
// error NoProceeds();
// error NotOwner();
// error NotApprovedForMarketplace();
// error NotSendTokenForMarketplace(uint256 totalAmount, address tokenAddress, address nftAddress);
// error PriceMustBeAboveZero();
// error PayLessThanExpectation();

// //////////////////////////
// // Define Error - END ////
// //////////////////////////

// contract NftMarketplace is ReentrancyGuard, Ownable2Step {

//     ////////////////////////////
//     // Construction - START ////
//     ////////////////////////////

//     /**
//      * @dev SwapInfo to store dex swap router info
//      */
//     struct DexSwapInfo {
//         uint8 dexName;
//         address routerSwapAddr;
//     }

//     uint32 private PLATFORM_FEE = 5;
//     address private PLATFORM_SIGNER_ADDR;

//     // Format: signature -> counter
//     mapping(bytes => uint32) processedSignatureMap;

//     // Format: token address -> SwapInfo(dexName, routerSwapAddr)
//     mapping(address => DexSwapInfo) swapableTokenMap;

//     constructor() {
//         PLATFORM_SIGNER_ADDR = 0x55b0Cf9eA794C100a173dACCa50cEb412C3969FC;
//         // WETH
//         swapableTokenMap[0x4200000000000000000000000000000000000006] = DexSwapInfo(1, 0x2626664c2603336E57B271c5C0b26F421741e481);
//         // Mainnet
//         // Official USDC
//         swapableTokenMap[0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913] = DexSwapInfo(1, 0x2626664c2603336E57B271c5C0b26F421741e481);
//         // USDbC
//         swapableTokenMap[0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA] = DexSwapInfo(1, 0x2626664c2603336E57B271c5C0b26F421741e481);
//         // Testnet
//         // USDC
//         swapableTokenMap[0x2e9F75DF8839ff192Da27e977CD154FD1EAE03cf] = DexSwapInfo(1, 0x2626664c2603336E57B271c5C0b26F421741e481);
//     }

//     event sellNft(string salt, address seller, address buyer, address nftAddress, uint256 nftId, uint256 nftAmountForSale, string nftType, address spendTokenAddr);
//     event buyNft(string salt, address seller, address buyer, address nftAddress, uint256 nftId, uint256 nftAmountForSale, string nftType, address spendTokenAddr, bool isNativeToken, bool isWhitelistOnly);
//     event withdraw(address indexed receiver, uint256 ammount);
//     event newFlatformFeeRate(address indexed sender, uint256 currentPlatformFee, uint256 newPlatformFee);

//     //////////////////////////
//     // Construction - END ////
//     //////////////////////////


//     ////////////////////////////
//     // Util Functions - START //
//     ////////////////////////////

//     /*
//     * Extract v, r, s from Signature
//     * @return (uint8 v, bytes32 r, bytes32 s)
//     */
//     function extractSignature(bytes memory signature) private pure returns (uint8 v, bytes32 r, bytes32 s) {
//         require(signature.length == 65, "Invalid signature length");

//         // Extract r, s, and v from the signature
//         assembly {
//             r := mload(add(signature, 32))
//             s := mload(add(signature, 64))
//             v := byte(0, mload(add(signature, 96)))
//             // Reads the next 32 bytes after the length data
//             // r := mload(add(signature, 0x20))
//             // // Reads the next 32 bytes after r
//             // s := mload(add(signature, 0x40))
//             // // Reads the last byte
//             // v := byte(0, mload(add(signature, 0x60)))
//         }
//     }

//     /**
//      * Signature is produced by signing a keccak256 hash with the following format:
//      * "\x19Ethereum Signed Message\n" + len(msg) + msg
//      * @param _messageHash the hash of message
//      */
//     // function getEthSignedMessageHash(bytes32 _messageHash) private pure returns (bytes32) {
//     //     return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
//     //     // return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", _messageHash.length, _messageHash));
//     // }

//     /**
//      * Do verify message was signed by address with matched signature
//      * @param _raw_text the row text
//      * @param signature signature
//      * @param expectedSigner expected singer address
//      */
//     function verifyMessage(string memory _raw_text, bytes memory signature, address expectedSigner) private pure returns (bool) {
//         require(expectedSigner != address(0) && (uint160(expectedSigner) & 0 == 0), "");

//         // Calculate the message hash from the _raw_text
//         // bytes32 messageHash = keccak256(abi.encodePacked(_raw_text));
//         bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(bytes(_raw_text).length), _raw_text));
//         // bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", bytes(_raw_text).length, _raw_text));
//         // bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

//         (uint8 v, bytes32 r, bytes32 s) = extractSignature(signature);

//         // Recover the address of the signer from the signature and message hash
//         address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);

//         // Check if the recovered address matches the expected signer's address
//         return (recoveredAddress == expectedSigner);
//     }

//     function verifyMessage2(string memory _raw_text, bytes memory signature, address expectedSigner) public pure returns (string memory, bytes32, address, address) {
//         require(expectedSigner != address(0) && (uint160(expectedSigner) & 0 == 0), "");

//         // Calculate the message hash from the _raw_text
//         // bytes32 keccakMessage = keccak256(abi.encodePacked(_raw_text));
//         // bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(keccakMessage.length), keccakMessage));
//         bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(bytes(_raw_text).length), _raw_text));
//         // bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", bytes(_raw_text).length, _raw_text));
//         // bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

//         (uint8 v, bytes32 r, bytes32 s) = extractSignature(signature);

//         // Recover the address of the signer from the signature and message hash
//         address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);

//         // Check if the recovered address matches the expected signer's address
//         return (itoa(bytes(_raw_text).length), ethSignedMessageHash, recoveredAddress, expectedSigner);
//     }
    

//     // Returns the decimal string representation of value
//     function itoa(uint value) private pure returns (string memory) {
//         // Count the length of the decimal string representation
//         uint length = 1;
//         uint v = value;
//         while ((v /= 10) != 0) { length++; }

//         // Allocated enough bytes
//         bytes memory result = new bytes(length);

//         // Place each ASCII string character in the string,
//         // right to left
//         while (true) {
//             length--;

//             // The ASCII value of the modulo 10 value
//             result[length] = bytes1(uint8(0x30 + (value % 10)));

//             value /= 10;

//             if (length == 0) { break; }
//         }

//         return string(result);
//     }
    
//     /**
//      * Do verify message was signed by address with matched signature
//      * @param _raw_text the row text
//      * @param v v
//      * @param r r
//      * @param s s
//      * @param expectedSigner expected singer address
//      */
//     // function verifyMessage(string memory _raw_text, uint8 v, bytes32 r, bytes32 s, address expectedSigner) private pure returns (bool) {
//     //     require(expectedSigner != address(0) && (uint160(expectedSigner) & 0 == 0), "");

//     //     // Calculate the message hash from the TEXT
//     //     // bytes32 messageHash = keccak256(abi.encodePacked(_raw_text));
//     //     // bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
//     //     bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(bytes(_raw_text).length), _raw_text));

//     //     // Recover the address of the signer from the signature and message hash
//     //     address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);

//     //     // Check if the recovered address matches the expected signer's address
//     //     return (recoveredAddress == expectedSigner);
//     // }

//     /**
//      * Convert boolean to string.
//      * @param x boolean input
//      */
//     function toString(bool x) private pure returns (string memory) {
//         if (x) {
//             return "true";
//         } else {
//             return "false";
//         }
//     }
    
//     /**
//      * Check current time is tradable?
//      */
//     function isValidDuration(uint128 startTime, uint128 endTime) private view returns(bool) {
//         uint256 currentTime = block.timestamp;
//         if (startTime <= currentTime && currentTime <= endTime) {
//             return true;
//         } else {
//             return false;
//         }
//     }

//     /**
//      * Verify the target address is ins whitelist
//      * @param salt the salt of seller's signature
//      * @param targetAddr target whitelist address
//      * @param signature signature of message [salt-targetAddr] was signed by Platform Signger Address
//      */
//     function verifyWhitelist(string memory salt, address targetAddr, bytes memory signature) private view returns(bool) {
//         // Calculate the message hash from the _raw_text
//         // bytes32 messageHash = keccak256(abi.encodePacked(salt, ',', Strings.toHexString(targetAddr)));
//         string memory message = string(abi.encodePacked(salt, ',', Strings.toHexString(targetAddr)));
//         // bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
//         bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(bytes(message).length), message));
//         // bytes32 ethSignedMessageHash = bytes32(abi.encodePacked(salt, '-', Strings.toHexString(target)));

//         (uint8 v, bytes32 r, bytes32 s) = extractSignature(signature);

//         // Recover the address of the signer from the signature and message hash
//         address signer = ecrecover(ethSignedMessageHash, v, r, s);
//         return signer == PLATFORM_SIGNER_ADDR;
//     }

//     //////////////////////////
//     // Util Functions - END //
//     //////////////////////////



//     ////////////////////////////
//     // Main Functions - START //
//     ////////////////////////////

//     /**
//      * Validate input struct data for list_message
//      * @param _inputData validate input struct data
//      */
//     function validateListMessageDataInptut(ListMessageData memory _inputData) private pure returns (bool){
//         require(bytes(_inputData.salt).length > 0, "Invalid salt");
//         require(_inputData.sellerAddr != address(0) && (uint160(_inputData.sellerAddr) & 0 == 0), "Invalid sellerAddr");
//         require(_inputData.nftAddr != address(0) && (uint160(_inputData.nftAddr) & 0 == 0), "Invalid nftAddr");
//         require(_inputData.nftId >= 0 && _inputData.nftId <= type(uint256).max-1, "Invalid nftId");
//         require(_inputData.nftAmountForSale >= 0 && _inputData.nftAmountForSale <= type(uint32).max-1, "Invalid nftAmountForSale");
//         require(bytes(_inputData.nftType).length > 0, "Invalid nftType");
//         require(_inputData.spendTokenAddr != address(0) && (uint160(_inputData.spendTokenAddr) & 0 == 0), "Invalid spendTokenAddr");
//         require(_inputData.spendPrice >= 0 && _inputData.spendPrice <= type(uint256).max-1, "Invalid spendPrice");
//         require(_inputData.startTime >= 0 && _inputData.startTime <= type(uint128).max-1, "Invalid startTime");
//         require(_inputData.endTime >= 0 && _inputData.endTime <= type(uint128).max-1, "Invalid endTime");
//         require(_inputData.isNativeToken == true || _inputData.isNativeToken == false, "Invalid isNativeToken");
//         require(_inputData.isWhitelistOnly == true || _inputData.isWhitelistOnly == false, "Invalid isWhitelistOnly");
//         return true;
//     }

//     struct ListMessageData {
//         string salt;
//         address sellerAddr;
//         address nftAddr;
//         uint256 nftId;
//         uint32 nftAmountForSale; 
//         string nftType;
//         address spendTokenAddr;
//         uint256 spendPrice; 
//         uint128 startTime;
//         uint128 endTime;
//         bool isNativeToken;
//         bool isWhitelistOnly;
//     }

//     function verifyBuyListedNftsTuple(ListMessageData memory _listMessageData, uint32 _nftAmountToBuy, bytes memory _signature) view public returns (string memory, bool) {
//         // Verify some basic conditions
//         validateListMessageDataInptut(_listMessageData);
//         require(_listMessageData.nftAmountForSale >= _nftAmountToBuy, "No NFT left");
//         require(isValidDuration(_listMessageData.startTime, _listMessageData.endTime), "Invalid timeframe");

//         // Verify some signature was signed by NFT Owner
//         // ${salt},${sellerAddr},${nftAddr},${nftId},${nftAmountForSale},${nftType},${spendTokenAddr},${spendPrice},${startTime},${endTime},${isNativeToken},${isWhitelistOnly}
//         string memory originalMsg = string(abi.encodePacked(_listMessageData.salt, ",", Strings.toHexString(_listMessageData.sellerAddr), ",", Strings.toHexString(_listMessageData.nftAddr), ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toString(_listMessageData.nftId), ",", Strings.toString(_listMessageData.nftAmountForSale), ",", _listMessageData.nftType, ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toHexString(_listMessageData.spendTokenAddr), ",", Strings.toString(_listMessageData.spendPrice), ",", Strings.toString(_listMessageData.startTime), ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toString(_listMessageData.endTime),  ",", toString(_listMessageData.isNativeToken),  ",", toString(_listMessageData.isWhitelistOnly)));

//         return (originalMsg, verifyMessage(originalMsg, _signature, _listMessageData.sellerAddr));
//     }

//     /**
//      * Maker calls this function to buy the listed NFTs.
//      * @param _listMessageData data in tuple format
//      * @param _nftAmountToBuy number of NFTs to buy
//      * @param _signature the signature of signed list_message
//      */
//     function buyListedNfts(ListMessageData memory _listMessageData, uint32 _nftAmountToBuy, bytes memory _signature, bytes memory _signature2) 
//                     external payable returns (bool) {
//         // Verify some basic conditions
//         validateListMessageDataInptut(_listMessageData);
//         require(_listMessageData.nftAmountForSale >= _nftAmountToBuy, "No NFT left");
//         require(isValidDuration(_listMessageData.startTime, _listMessageData.endTime), "Invalid timeframe");

//         // Verify some signature was signed by NFT Owner
//         // ${salt},${sellerAddr},${nftAddr},${nftId},${nftAmountForSale},${nftType},${spendTokenAddr},${spendPrice},${startTime},${endTime},${isNativeToken},${isWhitelistOnly}
//         string memory originalMsg = string(abi.encodePacked(_listMessageData.salt, ",", Strings.toHexString(_listMessageData.sellerAddr), ",", Strings.toHexString(_listMessageData.nftAddr), ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toString(_listMessageData.nftId), ",", Strings.toString(_listMessageData.nftAmountForSale), ",", _listMessageData.nftType, ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toHexString(_listMessageData.spendTokenAddr), ",", Strings.toString(_listMessageData.spendPrice), ",", Strings.toString(_listMessageData.startTime), ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toString(_listMessageData.endTime),  ",", toString(_listMessageData.isNativeToken),  ",", toString(_listMessageData.isWhitelistOnly)));

//         require(verifyMessage(originalMsg, _signature, _listMessageData.sellerAddr), 'Invalid Signature');

//         // Check if enable whitelist, do verify whitelist address
//         if(_listMessageData.isWhitelistOnly){
//             require(verifyWhitelist(_listMessageData.salt, msg.sender, _signature2), "Not in whitelist");
//         }

//         // Load spend token contract
//         if(_listMessageData.isNativeToken){
//             if(msg.value < _listMessageData.spendPrice){
//                 revert PayLessThanExpectation();
//             }
//         }else{
//             require((swapableTokenMap[_listMessageData.spendTokenAddr]).dexName != 0, "Not permited token");
            
//             IERC20 spendTknContract = IERC20(_listMessageData.spendTokenAddr);
//             uint256 totalAmountToPay = _nftAmountToBuy * _listMessageData.spendPrice;

//             if(spendTknContract.balanceOf(msg.sender) < totalAmountToPay){
//                 revert PayLessThanExpectation();
//             }

//             uint256 allowedAmount = spendTknContract.allowance(msg.sender, address(this));
//             if(allowedAmount < totalAmountToPay){
//                 revert NotApprovedForMarketplace();
//             }

//             // Spend token from seller wallet
//             try spendTknContract.transferFrom(msg.sender, address(this), totalAmountToPay) returns (bool){
//                 // Do nothing
//             }catch {
//                 revert NotSendTokenForMarketplace(totalAmountToPay, _listMessageData.spendTokenAddr, address(this));
//             }
            
//             delete spendTknContract;
//             delete allowedAmount;
//             delete totalAmountToPay;
//         }

//         // Check if the NFT token is an ERC721 or ERC1155 token
//         if (keccak256(abi.encodePacked(_listMessageData.nftType)) == keccak256(abi.encodePacked("erc721"))) {
//             require(processedSignatureMap[_signature] == 0, "used signature");

//             // Get the ERC721 contract
//             IERC721 ecr721Contract = IERC721(_listMessageData.nftAddr);
            
//             if (ecr721Contract.getApproved(_listMessageData.nftId) != address(this)) {
//                 revert NotApprovedForMarketplace();
//             }

//             // Require that the caller owns the NFT token
//             require(ecr721Contract.ownerOf(_listMessageData.nftId) == _listMessageData.sellerAddr, "Not NFT owner");

//             // mark this signature as used to prevent reentrance
//             processedSignatureMap[_signature] = 1;
            
//             // Transfer ownership of the NFT from the token owner to the buyer.
//             try ecr721Contract.safeTransferFrom(_listMessageData.sellerAddr, msg.sender, _listMessageData.nftId) {
//                 // Update the used signature list by counter to prevent reused the processed signatures
//                 payForSeller(_listMessageData.isNativeToken, _listMessageData.sellerAddr, _listMessageData.spendTokenAddr, _listMessageData.spendPrice, _listMessageData.nftAmountForSale);
//             } catch Error(string memory errorMessage) {
//                 // failed, return token to buyer
//                 refundToBuyer(_listMessageData.isNativeToken, _listMessageData.sellerAddr, _listMessageData.spendTokenAddr, _listMessageData.spendPrice * _listMessageData.nftAmountForSale);
//                 processedSignatureMap[_signature] = 0;
//                 revert(string(abi.encodePacked("Transfer NFT failed ", errorMessage)));
//             }

//         } else if (keccak256(abi.encodePacked(_listMessageData.nftType)) == keccak256(abi.encodePacked("erc1155"))) {
//             // TODO have to check the nftAmountForSale 
//             require(processedSignatureMap[_signature] < _listMessageData.nftAmountForSale, "No NFT left");
//             require(processedSignatureMap[_signature] + _nftAmountToBuy <= _listMessageData.nftAmountForSale, "No NFT left");

//             // Get the ERC1155 contract
//             IERC1155 erc1155Contract = IERC1155(_listMessageData.nftAddr);

//             if (!erc1155Contract.isApprovedForAll(_listMessageData.sellerAddr, address(this))) {
//                 revert NotApprovedForMarketplace();
//             }

//             // Require that the caller has sufficient balance of the NFT token
//             require(erc1155Contract.balanceOf(_listMessageData.sellerAddr, _listMessageData.nftId) >= _listMessageData.nftAmountForSale, "Insufficient token balance");

//             // mark this signature as used to prevent reentrance
//             processedSignatureMap[_signature] = processedSignatureMap[_signature] + _nftAmountToBuy;

//             // Transfer ownership of the NFT from the token owner to the buyer.
//             try erc1155Contract.safeTransferFrom(_listMessageData.sellerAddr, msg.sender, _listMessageData.nftId, _listMessageData.nftAmountForSale, "") {
//                 // Update the used signature list by counter to prevent reused the processed signatures
//                 payForSeller(_listMessageData.isNativeToken, _listMessageData.sellerAddr, _listMessageData.spendTokenAddr, _listMessageData.spendPrice, _listMessageData.nftAmountForSale);
//             } catch Error(string memory errorMessage) {
//                 // failed, return token to buyer
//                 refundToBuyer(_listMessageData.isNativeToken, _listMessageData.sellerAddr, _listMessageData.spendTokenAddr, _listMessageData.spendPrice * _listMessageData.nftAmountForSale);
//                 processedSignatureMap[_signature] = processedSignatureMap[_signature] - _nftAmountToBuy;
//                 revert(string(abi.encodePacked("Transfer NFT failed ", errorMessage)));
//             }
//         } else {
//             // Revert if the NFT token is not of type ERC721 or ERC1155
//             revert("Unsupported nft type");
//         }
//         emit buyNft(_listMessageData.salt, _listMessageData.sellerAddr, msg.sender, _listMessageData.nftAddr, _listMessageData.nftId, _listMessageData.nftAmountForSale, 
//                     _listMessageData.nftType, _listMessageData.spendTokenAddr, _listMessageData.isNativeToken, _listMessageData.isWhitelistOnly);
//         return true;
//     }

//     /**
//      * Pay $ for seller.
//      * @param isNativeToken is spend token native?
//      * @param sellerAddr seller wallet address
//      * @param spendTokenAddr token address to be spent
//      * @param spendPrice price to be spent
//      * @param _nftAmountToTrade number of NFT will be trade
//      */
//     function payForSeller(bool isNativeToken, address sellerAddr, address spendTokenAddr, uint256 spendPrice, uint32 _nftAmountToTrade) private returns (bool) {
//         if(isNativeToken){
//             uint256 platformFee = (msg.value * PLATFORM_FEE) / 100;
//             uint256 royaltyFee = (msg.value * 3) / 100;

//             // Send selling $ to seller
//             address payable sellerContract = payable(sellerAddr);
//             sellerContract.transfer(msg.value - (platformFee + royaltyFee));

//             // Send fee $ to owner
//             address payable ownerContract = payable(owner());
//             ownerContract.transfer(platformFee);

//             // Send royalty $ to creator
//             // TODO Find the way to get creator and royalty fee
//             // address payable creatorContract = payable(creatorAddr);
//             // creatorContract.transfer(royaltyFee);
//             ownerContract.transfer(royaltyFee);

//         }else{
//             IERC20 spendTknContract = IERC20(spendTokenAddr);
//             uint256 totalAmountToPay = _nftAmountToTrade * spendPrice;
            
//             uint256 platformFee = (totalAmountToPay * PLATFORM_FEE) / 100;
//             uint256 royaltyFee = (totalAmountToPay * 3) / 100;

//             // Send selling $ to seller
//             spendTknContract.transfer(sellerAddr, totalAmountToPay - (platformFee + royaltyFee));

//             // Send fee $ to owner
//             spendTknContract.transfer(owner(), platformFee);

//             // Send royalty $ to creator
//             // TODO Find the way to get creator and royalty fee
//             // spendTknContract.transfer(creatorAddr, royaltyFee);
//             spendTknContract.transfer(owner(), royaltyFee);
//         }
//         return true;
//     }

//     /**
//      * Refund to buyer if NFTs are not transferable.
//      * @param isNativeToken Check flag is native token or not
//      * @param buyerAddr the wallet address of buyer
//      * @param spendTokenAddr the token address to be refunded
//      * @param tookAmmount the number of ammount to be refunded
//      */
//     function refundToBuyer(bool isNativeToken, address buyerAddr, address spendTokenAddr, uint256 tookAmmount) private returns (bool) {
//         if(isNativeToken){
//             // Send selling $ to seller
//             address payable buyerContract = payable(buyerAddr);
//             buyerContract.transfer(tookAmmount);
//         } else {
//             IERC20 spendTknContract = IERC20(spendTokenAddr);
//             // Send selling $ to seller
//             spendTknContract.transfer(buyerAddr, tookAmmount);
//         }
//         return true;
//     }

//     /**
//      * Validate input struct data for offer_message
//      * @param _inputData validate input struct data
//      */
//     function validateOfferMessageDataInptut(OfferMessageData memory _inputData) private pure returns (bool){
//         require(bytes(_inputData.salt).length > 0, "Invalid salt");
//         require(_inputData.buyerAddr != address(0) && (uint160(_inputData.buyerAddr) & 0 == 0), "Invalid buyerAddr");
//         require(_inputData.nftAddr != address(0) && (uint160(_inputData.nftAddr) & 0 == 0), "Invalid nftAddr");
//         require(_inputData.nftId >= 0 && _inputData.nftId <= type(uint256).max-1, "Invalid nftId");
//         require(_inputData.nftAmountToBuy >= 0 && _inputData.nftAmountToBuy <= type(uint32).max-1, "Invalid nftAmountToBuy");
//         require(bytes(_inputData.nftType).length > 0, "Invalid nftType");
//         require(_inputData.spendTokenAddr != address(0) && (uint160(_inputData.spendTokenAddr) & 0 == 0), "Invalid spendTokenAddr");
//         require(_inputData.spendPrice >= 0 && _inputData.spendPrice <= type(uint256).max-1, "Invalid spendPrice");
//         require(_inputData.startTime >= 0 && _inputData.startTime <= type(uint128).max-1, "Invalid startTime");
//         require(_inputData.endTime >= 0 && _inputData.endTime <= type(uint128).max-1, "Invalid endTime");
//         return true;
//     }

//     struct OfferMessageData {
//         string salt;
//         address buyerAddr;
//         address nftAddr;
//         uint256 nftId;
//         uint32 nftAmountToBuy; 
//         string nftType;
//         address spendTokenAddr;
//         uint256 spendPrice; 
//         uint128 startTime;
//         uint128 endTime;
//     }

//     /**
//      * Maker calls this function to sell NFT by accept the selected offer.
//      * @param _offerMessageData the original offer data had been signed by buyer
//      * @param _nftAmountToSell the number of NFTs which to be sell
//      * @param _signature the signature of signed offer_message
//      */
//     function sellNftsForOffer(OfferMessageData memory _offerMessageData, uint32 _nftAmountToSell, bytes memory _signature) 
//                     external returns (bool) {
        
//         // Verify some basic conditions
//         validateOfferMessageDataInptut(_offerMessageData);
//         require(_offerMessageData.nftAmountToBuy >= _nftAmountToSell, "No enought NFT left");
//         require(isValidDuration(_offerMessageData.startTime, _offerMessageData.endTime), "Invalid timeframe");
//         require((swapableTokenMap[_offerMessageData.spendTokenAddr]).dexName != 0, "Not permited token");

//         // Verify some signature was signed by buyer
//         // ${salt},${buyerAddr},${nftAddr},${nftId},${nftAmountToBuy},${nftType},${spendTokenAddr},${spendPrice},${startTime},${endTime}
//         string memory originalMsg = string(abi.encodePacked(_offerMessageData.salt, ",", Strings.toHexString(_offerMessageData.buyerAddr), ",", Strings.toHexString(_offerMessageData.nftAddr), ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toString(_offerMessageData.nftId), ",", Strings.toString(_offerMessageData.nftAmountToBuy), ",", _offerMessageData.nftType, ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toHexString(_offerMessageData.spendTokenAddr), ",", Strings.toString(_offerMessageData.spendPrice), ","));
//         originalMsg = string(abi.encodePacked(originalMsg, Strings.toString(_offerMessageData.startTime), ",", Strings.toString(_offerMessageData.endTime)));

//         require(verifyMessage(originalMsg, _signature, _offerMessageData.buyerAddr), 'Invalid Signature');

//         // Load spend token contract
//         IERC20 spendTknContract = IERC20(_offerMessageData.spendTokenAddr);
//         uint256 totalAmountToPay = _nftAmountToSell * _offerMessageData.spendPrice;

//         if(spendTknContract.balanceOf(_offerMessageData.buyerAddr) < totalAmountToPay){
//             revert PayLessThanExpectation();
//         }

//         uint256 allowedAmount = spendTknContract.allowance(_offerMessageData.buyerAddr, address(this));
//         if(allowedAmount < totalAmountToPay){
//             revert NotApprovedForMarketplace();
//         }

//         // Spend token from seller wallet
//         try spendTknContract.transferFrom(_offerMessageData.buyerAddr, address(this), totalAmountToPay) returns (bool isTransfered){
//             require(isTransfered, "Token not transferable");
//         }catch {
//             revert NotSendTokenForMarketplace(totalAmountToPay, _offerMessageData.spendTokenAddr, address(this));
//         }

//         // Check if the NFT token is an ERC721 or ERC1155 token
//         if (keccak256(abi.encodePacked(_offerMessageData.nftType)) == keccak256(abi.encodePacked("erc721"))) {
//             require(processedSignatureMap[_signature] == 0, "Used signature");

//             // Get the ERC721 contract
//             IERC721 ecr721Contract = IERC721(_offerMessageData.nftAddr);
            
//             if (ecr721Contract.getApproved(_offerMessageData.nftId) != address(this)) {
//                 revert NotApprovedForMarketplace();
//             }

//             // Require that the maker owns the NFT token
//             require(ecr721Contract.ownerOf(_offerMessageData.nftId) == msg.sender, "Not NFT owner");
            
//             // Mark this signature as used to prevent reentrance
//             processedSignatureMap[_signature] = 1;

//             // Transfer ownership of the NFT from the token owner to the buyer.
//             try ecr721Contract.safeTransferFrom(msg.sender, _offerMessageData.buyerAddr, _offerMessageData.nftId) {
//                 // Update the used signature list by counter to prevent reused the processed signatures
//                 payForSeller(false, msg.sender, _offerMessageData.spendTokenAddr, _offerMessageData.spendPrice, _offerMessageData.nftAmountToBuy);
//             } catch Error(string memory errorMessage) {
//                 // failed, return token to buyer
//                 processedSignatureMap[_signature] = 0;
//                 spendTknContract.transferFrom(address(this), _offerMessageData.buyerAddr, totalAmountToPay);
//                 revert(string(abi.encodePacked("Transfer NFT failed ", errorMessage)));
//             }

//         } else if (keccak256(abi.encodePacked(_offerMessageData.nftType)) == keccak256(abi.encodePacked("erc1155"))) {
//             // TODO have to check the nftAmountForSale 
//             require(processedSignatureMap[_signature] < _offerMessageData.nftAmountToBuy, "Exceed NFTs amount");
//             require(processedSignatureMap[_signature] + _nftAmountToSell <= _offerMessageData.nftAmountToBuy, "Exceed NFTs amount");

//             // Get the ERC1155 contract
//             IERC1155 erc1155Contract = IERC1155(_offerMessageData.nftAddr);

//             if (!erc1155Contract.isApprovedForAll(msg.sender, address(this))) {
//                 revert NotApprovedForMarketplace();
//             }

//             // Require that the caller has sufficient balance of the NFT token
//             require(erc1155Contract.balanceOf(msg.sender, _offerMessageData.nftId) >= _offerMessageData.nftAmountToBuy, "Insufficient token balance");

//             // Mark this signature as used to prevent reentrance
//             processedSignatureMap[_signature] = processedSignatureMap[_signature] + _nftAmountToSell;

//             // Transfer ownership of the NFT from the token owner to the buyer.
//             try erc1155Contract.safeTransferFrom(msg.sender, _offerMessageData.buyerAddr, _offerMessageData.nftId, _offerMessageData.nftAmountToBuy, "") {
//                 // Update the used signature list by counter to prevent reused the processed signatures
//                 payForSeller(false, msg.sender, _offerMessageData.spendTokenAddr, _offerMessageData.spendPrice, _offerMessageData.nftAmountToBuy);
//             } catch Error(string memory errorMessage) {
//                 // failed, return token to buyer
//                 processedSignatureMap[_signature] = processedSignatureMap[_signature] - _nftAmountToSell;
//                 spendTknContract.transferFrom(address(this), _offerMessageData.buyerAddr, totalAmountToPay);
//                 revert(string(abi.encodePacked("Transfer NFT failed ", errorMessage)));
//             }
//         } else {
//             // Revert if the NFT token is not of type ERC721 or ERC1155
//             revert("Unsupported nft type");
//         }
        
//         emit sellNft(_offerMessageData.salt, msg.sender, _offerMessageData.buyerAddr, _offerMessageData.nftAddr, _offerMessageData.nftId, _offerMessageData.nftAmountToBuy, 
//                     _offerMessageData.nftType, _offerMessageData.spendTokenAddr);
//         return true;
//     }

//     /**
//      * Function to check the contract's balance
//      */
//     function getContractBalance() external view returns (uint256) {
//         return address(this).balance;
//     }

//     /**
//      * Function to allow the owner to withdraw Ether from the contract
//      */
//     function withdrawAll() external onlyOwner nonReentrant {
//         uint256 withdrawableAmmount = address(this).balance;
//         require(withdrawableAmmount > 0, "Insufficient contract balance");
//         payable(owner()).transfer(withdrawableAmmount);
//         emit withdraw(owner(), withdrawableAmmount);
//     }

//     /**
//      * Function to update the PLATFORM_FEE
//      */
//     function updatePlatformFee(uint32 _newPlatformFee) external onlyOwner {
//         PLATFORM_FEE = _newPlatformFee;
//         emit newFlatformFeeRate(owner(), PLATFORM_FEE, _newPlatformFee);
//     }

//     /**
//      * Check signature is processed or not.
//      * @param _signature THe signature to check
//      * @return 
//      */
//     function checkUsedSignature(bytes memory _signature) external view returns (uint32) {
//         return processedSignatureMap[_signature];
//     }
    
//     /**
//      * Add new swapable token and dex support.
//      * @param _tokenAddress alt token address
//      * @param _dexId dex ID: 1 - uniswap, 2 - sushiswap
//      * @param _dexRouterAddress Dex swap router address
//      */
//     function addNewSwapableToken(address _tokenAddress, uint8 _dexId, address _dexRouterAddress) external onlyOwner() returns (bool) {
//         swapableTokenMap[_tokenAddress] = DexSwapInfo(_dexId, _dexRouterAddress);
//         return true;
//     }

//     /**
//      * Set new Platform Signer Address.
//      * @param _newSignerAddr NEw signer address
//      */
//     function setPlatformSignerAddress(address _newSignerAddr) external onlyOwner() {
//         PLATFORM_SIGNER_ADDR = _newSignerAddr;
//     }

    
//     //////////////////////////
//     // Main Functions - END //
//     //////////////////////////

// }
