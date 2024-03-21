import { ethers } from 'hardhat';

async function main() {

  const COLL_NAME = '_colName';
  const COLL_SYMBOL = '_colSymbol';
  const MAX_PER_MINT = 300;
  const MAX_SUP = 300;
  const NORMAL_MINT_PRICE_FREE = 0;
  const ROYALTY_PERCENTAGE = 20;
  const WHITELIST_FLAG = 0;
  const HIDDEN_URI = 'https://hiddlen.uri';
  const TOKEN_URI_BASE = 'https://test.xyz/';
  console.log(COLL_NAME, COLL_SYMBOL, " ", MAX_PER_MINT, MAX_SUP, NORMAL_MINT_PRICE_FREE, ROYALTY_PERCENTAGE, WHITELIST_FLAG, HIDDEN_URI);

  // const nft = await ethers.deployContract('contracts/IngotERC721Collection1.sol:IngotERC721Collection1', [COLL_NAME, COLL_SYMBOL, " ", MAX_PER_MINT, MAX_SUP, NORMAL_MINT_PRICE_FREE, ROYALTY_PERCENTAGE, WHITELIST_FLAG, HIDDEN_URI]);
  
  // const nft = await ethers.deployContract('contracts/IngotERC721Collection3Old.sol:IngotERC721Collection3', [COLL_NAME, COLL_SYMBOL]);
  
  const nft = await ethers.deployContract('contracts/IngotERC721Collection3Old.sol:NFT', []);

  await nft.waitForDeployment();

  console.log('NFT Contract Deployed at ' + nft.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
