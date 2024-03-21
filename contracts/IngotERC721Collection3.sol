// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ERC721Psi.sol";
import "./IIngotERC721Collection.sol";
import "./IngotNftCollectionError.sol";
import "./IngotNftCollectionUtils.sol";

////////////////////////////
// Define Error - START //
////////////////////////////

////////////////////////////
// Define Error - END  //
////////////////////////////

contract IngotERC721Collection3 is ERC721Psi, ERC2981, ReentrancyGuard, IIngotERC721Collection {
    using Strings for uint256;

    event mintNfts(address indexed sender, string _draftNftIds, uint256[] indexed tokenIds, bytes inputData);
    event mintedNft(address sender, uint256 tokenId);

    bool private isLocked;
    address private PLATFORM_SIGNER_ADDR;
    /**
     * whitelistControlFlag
     * 0: no restrict, everyone can mint - DEFAULT
     * 1: only creator can mint
     * 2: only whitelist and creator can mint
     */
    uint8 private whitelistControlFlag;
    uint32 private MAX_PER_MINT; //max mints per txn
    uint256 private MAX_SUPPLY; //Max nfts that can be minted, default type(uint256).maxs
    uint256 private normalMintPrice; //price to buy 1 nft recalib for eth=10^18
    address private _owner;
    string private _name;
    string private _symbol;
    string private baseTokenURI; //ipfs url of folder with JSON meta
    string private hiddenTokenURI; //ipfs url of folder with JSON meta
    mapping(address => uint32) private wl_minted_map;
    mapping(uint256 => string) private TOKEN_URI_MAPP;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only the creator can call this function");
        _;
    }
    
    constructor(string memory _colName, string memory _colSymbol) ERC721Psi(_colName, _colSymbol)  {
        PLATFORM_SIGNER_ADDR = 0x55b0Cf9eA794C100a173dACCa50cEb412C3969FC;
        _owner = tx.origin;
    }

    function initialize(string memory _colName, string memory _colSymbol, string memory _baseTokenURI,
        uint32 _maxPerMint, uint256 _maxSupply, uint256 _normalMintPrice, uint96 _royaltyPercentInx100, 
        uint8 _whitelistControlFlag) public {
        require(!isLocked, "Locked");
        _owner = tx.origin;
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
        _name = _colName;
        _symbol = _colSymbol;
        setInitCurrentIndex();
        isLocked = true;
    }

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

        if (_nextTokenId() + _quantity > MAX_SUPPLY)
            revert InsufficientSupply(MAX_SUPPLY, _nextTokenId());

        // Check if enable whitelist, do verify whitelist address
        if (whitelistControlFlag != 0) {
            // Whitelist signature will be with this template: "NFT_ADDR,WHITELIST_ADDR,MAX_NUMBER_OF_NFT"
            // e.g. 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266,0x4ed7c70f96b99c776995fb64377f0d4ab3b0e1c1,10
            if (!IngotNftCollectionUtils.verifyMessage(
                    string(
                        abi.encodePacked(
                            Strings.toHexString(address(this)), ",",
                            Strings.toHexString(msg.sender), ",",
                            Strings.toString(maxWlMint)
                        )
                    ), whitelistSignature, PLATFORM_SIGNER_ADDR
                )
            ) revert NotWhitelistAddress();
            // Have to check number of minted NFTs if not exceeded
            if (wl_minted_map[msg.sender] >= maxWlMint)
                revert ReachedMintLimit();
        }

        // Mint the NFT
        uint256[] memory mintedTokenIds = new uint256[](_quantity);
        wl_minted_map[msg.sender] += _quantity;
        uint256 startTokenId;
        uint256 endTokenId;
        // mint new nft token
        if(_isSafeMint){
            (startTokenId, endTokenId) = _safeMint(msg.sender, _quantity, "");
        }else{
            (startTokenId, endTokenId) = _mint(msg.sender, _quantity);
        }

        bool isSetUri = keccak256(abi.encodePacked(_jsonUri)) != keccak256(abi.encodePacked(""));
        uint256 count;
        for (uint256 i = startTokenId; i <= endTokenId; i++) {
            if (isSetUri) {
                setTokenURI(i, _jsonUri);
            }else{
                setTokenURI(i, string(abi.encodePacked(baseTokenURI, Strings.toString(i))));
            }
            emit mintedNft(msg.sender, i);
            // Set royalty to minted tokenId
            _setTokenRoyalty(count, _owner, _royaltyPercentInx100);
            mintedTokenIds[count++] = i;
        }

        bytes memory inputData = msg.data;
        emit mintNfts(msg.sender, _draftNftIds, mintedTokenIds, inputData);
    }

    function safeMint(address to, string memory uri) external onlyOwner{
        (uint256 startTokenId, ) = _safeMint(to, 1);
        setTokenURI(startTokenId, uri);
        emit mintedNft(msg.sender, startTokenId);
    }

    function mint(address to, string memory uri) external onlyOwner{
        (uint256 startTokenId, ) = _mint(to, 1);
        setTokenURI(startTokenId, uri);
        emit mintedNft(msg.sender, startTokenId);
    }

    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        normalMintPrice = _mintPrice;
    }

    function baseURI() external view returns (string memory) {
        return baseTokenURI;
    }

    // function setBaseURI(string memory _baseTokenURI) internal {
    //     baseTokenURI = _baseTokenURI;
    // }

    function setTokenURI(uint256 _tokenID, string memory _tokenURI) internal {
        if(!_exists(_tokenID)){
            revert ERC721NonexistentToken(_tokenID);
        }
        if(bytes(_tokenURI).length > 0){
            TOKEN_URI_MAPP[_tokenID] = _tokenURI;
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721Psi) returns (string memory) {
        if(!_exists(tokenId)){
            revert ERC721NonexistentToken(tokenId);
        }
        string memory tokenUri = TOKEN_URI_MAPP[tokenId];
        return bytes(tokenUri).length > 0 ? tokenUri : string(abi.encodePacked(baseTokenURI, tokenId.toString()));
    }

    function supportsInterface(bytes4 interfaceId) public view override( ERC721Psi, ERC2981 ) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function name() view public override returns (string memory){
        return _name;
    }

    function symbol() view public override returns (string memory){
        return _symbol;
    }

    function maxPerMint() view public returns (uint256){
        return MAX_PER_MINT;
    }
    
    function creator() view public returns (address){
        return _owner;
    }

    function maxSupply() view public returns (uint256){
        return MAX_SUPPLY;
    }

    // Creator withdraw native balance
    function withdraw() external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Zero Balance");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }

    // Check the balance by creator
    function getbalance() external view onlyOwner returns (uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address receiver, uint256 amount) {
        return super.royaltyInfo(_tokenId, _salePrice);
    }

}
