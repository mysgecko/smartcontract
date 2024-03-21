// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./IngotERC721Collection1.sol";
import "./IngotERC721Collection2.sol";
import "./IngotERC721Collection3.sol";
import "./IIngotERC721Collection.sol";

// // Main smartcontract to create smart contract on fly
contract IngotNFTCollectionFactory is Initializable, OwnableUpgradeable {

    mapping(address => address[]) private CREATOR_COLLECTION_ADDRS;
    address public erc721ImplAddr2;
    address public erc721ImplAddr3;

    event NewCollectionCreated(address sender, address collectionAddress, string draftCollId);

    // constructor() Ownable(msg.sender) {
    //     IngotERC721Collection2 erc721TokenImplementation2 = new IngotERC721Collection2("IngotMysGeckoCollectionType2", "IMGecko2");
    //     erc721ImplAddr2 = address(erc721TokenImplementation2);
    //     IngotERC721Collection3 erc721TokenImplementation3 = new IngotERC721Collection3("IngotMysGeckoCollectionType3", "IMGecko3");
    //     erc721ImplAddr3 = address(erc721TokenImplementation3);
    // }
    
    /// @custom:oz-upgrades-unsafe-allow constructor
    // constructor() initializer {}

    function initialize(address _owner_addr, address _erc721ImplAddr2, address _erc721ImplAddr3) public initializer  {
        OwnableUpgradeable.__Ownable_init(_owner_addr);
        erc721ImplAddr2 = _erc721ImplAddr2;
        erc721ImplAddr3 = _erc721ImplAddr3;
        // IIngotERC721Collection erc721TokenImplementation2 = new IngotERC721Collection2("IngotMysGeckoCollectionType2", "IMGecko2");
        // erc721ImplAddr2 = address(erc721TokenImplementation2);
        // IIngotERC721Collection erc721TokenImplementation3 = new IngotERC721Collection3("IngotMysGeckoCollectionType3", "IMGecko3");
        // erc721ImplAddr3 = address(erc721TokenImplementation3);
    }

    /**
     * Deploy new ERC721 Collection
     */
    function deployNewErc721Collection(uint8 nftTemplateType, string memory _colName, string memory _colSymbol, string memory _baseTokenURI,
        uint32 _maxPerMint, uint256 _maxSupply, uint256 _normalMintPrice,
        uint96 _royaltyPercentInx100, uint8 _whitelistControlFlag, string memory draftCollId) external returns(address) {
        address newNFTAddr;
        IIngotERC721Collection newNFT;
        if(nftTemplateType == 1){
            newNFT = new IngotERC721Collection1(_colName, _colSymbol, _baseTokenURI, _maxPerMint, _maxSupply, 
                                                                    _normalMintPrice, _royaltyPercentInx100, _whitelistControlFlag);
            // newNFT.transferOwnership(msg.sender);
            newNFTAddr = address(newNFT);
        }else 
        if(nftTemplateType == 2){
            // Creating a new crew object, you need to pay for the deployment of this contract everytime - $$$$
            bytes32 salt = keccak256(abi.encodePacked(_colName, _colSymbol, block.number));
            newNFT = IngotERC721Collection2(Clones.cloneDeterministic(erc721ImplAddr2, salt));
            // since the clone create a proxy, the constructor is redundant and you have to use the initialize function
            newNFT.initialize(_colName, _colSymbol, _baseTokenURI, _maxPerMint, _maxSupply, 
                                                                    _normalMintPrice, _royaltyPercentInx100, _whitelistControlFlag); 

            newNFTAddr = address(newNFT);
        }else 
        if(nftTemplateType == 3){
            // Creating a new crew object, you need to pay for the deployment of this contract everytime - $$$$
            bytes32 salt = keccak256(abi.encodePacked(_colName, _colSymbol, block.number));
            newNFT = IngotERC721Collection3(Clones.cloneDeterministic(erc721ImplAddr3, salt));
            // since the clone create a proxy, the constructor is redundant and you have to use the initialize function
            newNFT.initialize(_colName, _colSymbol, _baseTokenURI, _maxPerMint, _maxSupply, 
                                                                    _normalMintPrice, _royaltyPercentInx100, _whitelistControlFlag); 

            newNFTAddr = address(newNFT);
        }else{
            return address(0);
        }

        // Adding the new contract to our list of addresses
        CREATOR_COLLECTION_ADDRS[msg.sender].push(newNFTAddr);
        emit NewCollectionCreated(msg.sender, newNFTAddr, draftCollId);
        return newNFTAddr;
    }

    /**
     * To get collection list of creator.
     * @param creatorAddr creator address
     */
    function getCollectionByCreator(address creatorAddr) view external returns (address[] memory) {
        return CREATOR_COLLECTION_ADDRS[creatorAddr];
    } 

}
