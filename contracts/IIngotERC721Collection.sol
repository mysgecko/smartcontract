// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

////////////////////////////
// Define Error - START //
////////////////////////////

////////////////////////////
// Define Error - END  //
////////////////////////////

interface IIngotERC721Collection {
    function initialize(string memory _colName, string memory _colSymbol, string memory _baseTokenURI,
        uint32 _maxPerMint, uint256 _maxSupply, uint256 _normalMintPrice, uint96 _royaltyPercentInx100, 
        uint8 _whitelistControlFlag) external;

    function normalMintNFTs(bool _isSafeMint,
        string memory _jsonUri, uint32 _quantity, uint96 _royaltyPercentInx100,
        string memory _draftNftIds, uint32 maxWlMint, bytes memory whitelistSignature) payable external  ;

    // function safeMint(address to, string memory uri) external{
    // }

    // function mint(address to, string memory uri) external {
    // }

    // function reveal() external {
    // }

    // function setMintPrice(uint256 _mintPrice) external {
    // }

    // function baseURI() external view returns (string memory) {
    // }

    // function setTokenURI(uint256 _tokenID, string memory _tokenURI) internal {
    // }

    // function tokenURI(uint256 tokenId) public view virtual override(ERC721Psi) returns (string memory) {
    // }

    // function supportsInterface(bytes4 interfaceId) public view override( ERC721Psi, ERC2981 ) returns (bool) {
    //     return super.supportsInterface(interfaceId);
    // }

    // function name() view public override returns (string memory){
    // }

    // function symbol() view public override returns (string memory){
    // }

    // function maxPerMint() view public returns (uint256){
    // }
    
    // function creator() view public returns (address){
    // }

    // function maxSupply() view public returns (uint256){
    // }

    // // Creator withdraw native balance
    // function withdraw() external payable {
    // }

    // // Check the balance by creator
    // function getbalance() external view returns (uint256) {
    // }

    // function royaltyInfo(uint256 _tokenId, uint256 _salePrice) public view virtual override returns (address receiver, uint256 amount) {
    // }

}
