// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IngotNftCollectionError.sol";

////////////////////////////
// Define Error - START //
////////////////////////////

////////////////////////////
// Define Error - END  //
////////////////////////////

library IngotNftCollectionUtils {

    ////////////////////////////
    // Util Functions - START //
    ////////////////////////////

    /*
    * Extract v, r, s from Signature
    * @return (uint8 v, bytes32 r, bytes32 s)
    */
    function extractSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if(signature.length != 65){
          revert ByteCodeLengthNotMet(signature, signature.length);
        }

        // Extract r, s, and v from the signature
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
    }

    /**
     * Do verify message was signed by address with matched signature
     * @param _raw_text the row text
     * @param v v
     * @param r r
     * @param s s
     * @param expectedSignerAddr expected singer address
     */
    function verifyMessage(string memory _raw_text, uint8 v, bytes32 r, bytes32 s, address expectedSignerAddr) internal pure returns (bool) {
        if(!(expectedSignerAddr != address(0) && (uint160(expectedSignerAddr) & 0 == 0))){
          revert InvalidAddr(expectedSignerAddr);
        }

        // Calculate the message hash from the TEXT
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(bytes(_raw_text).length), _raw_text));

        // Recover the address of the signer from the signature and message hash
        address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);

        // Check if the recovered address matches the expected signer's address
        return (recoveredAddress == expectedSignerAddr);
    }

    /**
     * Do verify message was signed by address with matched signature
     * @param _raw_text the row text
     * @param signature signature
     * @param expectedSignerAddr expected singer address
     */
    function verifyMessage(string memory _raw_text, bytes memory signature, address expectedSignerAddr) internal pure returns (bool) {
        if(!(expectedSignerAddr != address(0) && (uint160(expectedSignerAddr) & 0 == 0))){
          revert InvalidAddr(expectedSignerAddr);
        }

        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", itoa(bytes(_raw_text).length), _raw_text));

        (uint8 v, bytes32 r, bytes32 s) = extractSignature(signature);

        // Recover the address of the signer from the signature and message hash
        address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);

        // Check if the recovered address matches the expected signer's address
        return (recoveredAddress == expectedSignerAddr);
    }
    
    // Returns the decimal string representation of value
    function itoa(uint256 value) internal pure returns (string memory) {
        // Count the length of the decimal string representation
        uint256 length = 1;
        uint256 v = value;
        while ((v /= 10) != 0) { length++; }

        // Allocated enough bytes
        bytes memory result = new bytes(length);

        // Place each ASCII string character in the string,
        // right to left
        while (true) {
            length--;
            // The ASCII value of the modulo 10 value
            result[length] = bytes1(uint8(0x30 + (value % 10)));
            value /= 10;
            if (length == 0) { break; }
        }

        return string(result);
    }

    /**
     * Convert boolean to string.
     * @param x boolean input
     */
    function toString(bool x) internal pure returns (string memory) {
        if (x) {
            return "true";
        } else {
            return "false";
        }
    }
    
    /**
     * Check current time is tradable?
     */
    function isValidDuration(uint128 startTime, uint128 endTime) internal view returns(bool) {
        uint256 currentTime = block.timestamp;
        if (startTime <= currentTime && currentTime <= endTime) {
            return true;
        } else {
            return false;
        }
    }

    ////////////////////////////
    // Main Functions - START //
    ////////////////////////////
}
