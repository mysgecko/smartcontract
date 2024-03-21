# smartcontract
MysGecko Smart Contract

- To create a new Node.js project, run:  
npm init --y  

To install Hardhat, run:  
npm install --save-dev hardhat  

To create a new Hardhat project, run:  
npx hardhat  
✔ What do you want to do? · Create a TypeScript project  
✔ Hardhat project root: · .../mysgecko-blockchain  
✔ Do you want to add a .gitignore? (Y/n) · y  
✔ Do you want to install this sample project's dependencies with npm (@nomicfoundation/hardhat-toolbox)? (Y/  n) · y  

Configuring Hardhat with Base in hardhat.config.ts  

- To install @nomicfoundation/hardhat-toolbox, run:  
npm install --save-dev @nomicfoundation/hardhat-toolbox  

- To install dotenv, run:  
npm install --save-dev dotenv  

- Once you have dotenv installed, you can create a .env file with the following content:  
WALLET_KEY=<YOUR_PRIVATE_KEY>  

- To add the OpenZeppelin Contracts library to your project, run:  
npm install --save @openzeppelin/contracts  

- Required libs:
# Create an empty hardhat.config.js
npm install --save-dev @nomicfoundation/hardhat-toolbox  
npm install --save-dev @nomicfoundation/hardhat-ethers  
npm install --save-dev @nomicfoundation/hardhat-chai-matchers  
npm install --save-dev @openzeppelin/hardhat-upgrades  
npm install --save-dev hardhat-gas-reporter   # https://betterprogramming.pub/how-i-optimized-gas-costs-by-75-b850ac3cff72  
npm install --save-dev erc721psi    # https://github.com/estarriolvetch/ERC721Psi  
npm install --save-dev mocha  
npm install --save-dev solidity-coverage  
npm install --save-dev @axelar-network/axelar-gmp-sdk-solidity  
  
npm install --save uuid  
npm install --save web3  
npm install --save @openzeppelin/contracts  
npm install --save @openzeppelin/contracts-upgradeable  
# npm install --save-dev @openzeppelin/hardhat-upgrades  

- To compile the contract using Hardhat, run:
npx hardhat compile --show-stack-traces

- Deploy testnet:
npx hardhat run --network blast-sepolia scripts/deploy_IngotNFTCollectionFactory.ts
npx hardhat run --network blast-sepolia scripts/deploy_NftMarketPlaceAuction.ts

- Deploy mainnet:
If you'd like to deploy to mainnet, you'll modify the command like so:
npx hardhat run scripts/deploy.ts --network base-mainnet

- Verify
Now, you can verify your contract. Grab the deployed address and run:
npx hardhat verify --network blast-sepolia <deployed_address>

- Tests
npx hardhat test
