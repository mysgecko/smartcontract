// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./IngotNftCollectionError.sol";
import "./IngotNftCollectionUtils.sol";
import "./IIngotERC721Collection.sol";

////////////////////////////
// Define Error - START //
////////////////////////////

////////////////////////////
// Define Error - END  //
////////////////////////////

contract IngotERC721Collection1 is ERC721URIStorage, ERC721Royalty, ReentrancyGuard, Ownable, IIngotERC721Collection {

    event mintNfts(address indexed sender, string _draftNftIds, uint256[] indexed tokenIds, bytes inputData);
    event mintedNft(address sender, uint256 tokenId);
    
    bool private isLocked;
    address private PLATFORM_SIGNER_ADDR;
    /**
     * whitelistControlFlag
     * 0: no whitelist control - DEFAULT
     * 1: only whitelist and owner are able to mint
     * 2: ... TBD
     */
    uint8 private whitelistControlFlag;
    uint32 private immutable MAX_PER_MINT; //max mints per txn
    uint256 private immutable MAX_SUPPLY; //Max nfts that can be minted, default type(uint256).maxs
    uint256 private _nextTokenId;
    uint256 private _burnedCounter;
    uint256 public normalMintPrice; //price to buy 1 nft recalib for eth=10^18
    string private baseTokenURI; //ipfs url of folder with JSON meta
    string private hiddenTokenURI; //ipfs url of folder with JSON meta
    mapping(address => uint32) private wl_minted_map;

    constructor(string memory _colName, string memory _colSymbol, string memory _baseTokenURI,
        uint32 _maxPerMint, uint256 _maxSupply, uint256 _normalMintPrice,
        uint96 _royaltyPercentInx100, uint8 _whitelistControlFlag) 
        ERC721(_colName, _colSymbol) Ownable(tx.origin) {
        PLATFORM_SIGNER_ADDR = 0x55b0Cf9eA794C100a173dACCa50cEb412C3969FC;
        if (keccak256(abi.encodePacked(_baseTokenURI)) != keccak256(abi.encodePacked(" "))) {
            baseTokenURI = _baseTokenURI;
        }
        _setDefaultRoyalty(tx.origin, _royaltyPercentInx100);

        normalMintPrice = _normalMintPrice; // 0 ether;
        whitelistControlFlag = _whitelistControlFlag;

        if (_maxPerMint <= 0) {
            MAX_PER_MINT = type(uint32).max;
        } else {
            MAX_PER_MINT = _maxPerMint;
        }

        if (_maxSupply <= 0) {
            MAX_SUPPLY = type(uint256).max;
        } else {
            MAX_SUPPLY = _maxSupply;
        }
        _nextTokenId = _nextTokenId + 1;
    }

    /**
     * Do nothing, just empty implement of Interface
     */
    function initialize(string memory _colName, string memory _colSymbol, string memory _baseTokenURI,
        uint32 _maxPerMint, uint256 _maxSupply, uint256 _normalMintPrice, uint96 _royaltyPercentInx100, 
        uint8 _whitelistControlFlag) external {}

    /**
     * Mint NFT
     * @param _isSafeMint will call safeMint if true
     * @param _jsonUri NFT metadata json uri
     * @param _quantity the number of NFT to be minted
     * @param _royaltyPercentInx100 royalty percentage
     * @param _draftNftIds draft Nft Id list
     */
    function normalMintNFTs(bool _isSafeMint,
        string memory _jsonUri, uint32 _quantity, uint96 _royaltyPercentInx100,
        string memory _draftNftIds, uint32 maxWlMint, bytes memory whitelistSignature
        ) external payable nonReentrant {
        if (normalMintPrice > 0 && msg.value < normalMintPrice * _quantity) {
            revert InsufficientValue(msg.value, normalMintPrice * _quantity);
        }

        // mint must less than max txn limit
        if (_quantity > MAX_PER_MINT)
            revert InsufficientMint(_quantity, MAX_PER_MINT);

        if (_nextTokenId + _quantity > MAX_SUPPLY)
            revert InsufficientSupply(MAX_SUPPLY, _nextTokenId);

        // Check if enable whitelist, do verify whitelist address
        if (whitelistControlFlag != 0) {
            // Whitelist signature will be with this template: "NFT_ADDR,WHITELIST_ADDR,MAX_NUMBER_OF_NFT"
            // e.g. 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266,0x4ed7c70f96b99c776995fb64377f0d4ab3b0e1c1,10
            if (
                !IngotNftCollectionUtils.verifyMessage(
                    string(
                        abi.encodePacked(
                            Strings.toHexString(address(this)), ",",
                            Strings.toHexString(msg.sender), ",",
                            Strings.toString(maxWlMint)
                        )
                    ),
                    whitelistSignature,
                    PLATFORM_SIGNER_ADDR
                )
            ) revert NotWhitelistAddress();
            // Have to check number of minted NFTs if not exceeded
            if (wl_minted_map[msg.sender] >= maxWlMint)
                revert ReachedMintLimit();
        }

        // Mint the NFT
        uint256[] memory mintedTokenIds = new uint256[](_quantity);
        uint256 newTokenId;
        uint32 wlMintedCount;
        for (uint32 i = 0; i < _quantity; i++) {
            wlMintedCount = wl_minted_map[msg.sender];
            newTokenId = _nextTokenId;
            _nextTokenId++;
            // mint new nft token
            if(_isSafeMint){
                _safeMint(msg.sender, newTokenId, "");
            }else{
                _mint(msg.sender, newTokenId);
            }
            wl_minted_map[msg.sender] = wlMintedCount + 1;

            emit mintedNft(msg.sender, newTokenId);

            if (keccak256(abi.encodePacked(_jsonUri)) != keccak256(abi.encodePacked(""))) {
                _setTokenURI(newTokenId, _jsonUri);
            } else {
                _setTokenURI(newTokenId, string(abi.encodePacked(baseTokenURI, Strings.toString(newTokenId))));
            }
            // Set royalty to minted tokenId
            _setTokenRoyalty(newTokenId, owner(), _royaltyPercentInx100);
            mintedTokenIds[i] = newTokenId;
        }

        bytes memory inputData = msg.data;
        emit mintNfts(msg.sender, _draftNftIds, mintedTokenIds, inputData);
    }

    function safeMint(address to, string memory uri) external onlyOwner{
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function mint(address to, string memory uri) external onlyOwner{
        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit mintedNft(msg.sender, tokenId);
    }

    function burn(uint256 tokenId) public onlyOwner{
        _burn(tokenId);
        _burnedCounter = _burnedCounter + 1;
    }
    
    // function _baseURI() internal view virtual override returns (string memory) {
    //     return baseTokenURI;
    // }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        normalMintPrice = _mintPrice;
    }

    // function setBaseURI(string memory _baseTokenURI) internal {
    //     baseTokenURI = _baseTokenURI;
    // }

    // function setTokenURI(uint256 _tokenID, string memory _tokenURI) internal {
    //     _setTokenURI(_tokenID, _tokenURI);
    // }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        if(ownerOf(tokenId) == address(0)){
            revert ERC721NonexistentToken(tokenId);
        }
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Royalty, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function maxPerMint() view public returns (uint256){
        return MAX_PER_MINT;
    }

    function maxSupply() view public returns (uint256){
        return MAX_SUPPLY;
    }

    function totalSupply() view public returns (uint256){
        return _nextTokenId - 1;
    }

    function circularSupply() view public returns (uint256){
        return _nextTokenId - _burnedCounter - 1;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address receiver, uint256 amount) {
        return super.royaltyInfo(_tokenId, _salePrice);
    }

    function creator() view public returns (address){
        return owner();
    }

    // Owner withdraw native balance
    function withdraw() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Zero Balance");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // Check the balance by owner
    function getbalance() external view onlyOwner returns (uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }

}
