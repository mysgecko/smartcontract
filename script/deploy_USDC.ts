import { ethers as ethershardhat, upgrades } from 'hardhat';
import { Wallet, getDefaultProvider, ethers } from 'ethers';
import Create2Deployer from '@axelar-network/axelar-gmp-sdk-solidity/artifacts/contracts/deploy/Create2Deployer.sol/Create2Deployer.json';
import Create3Deployer from '@axelar-network/axelar-gmp-sdk-solidity/artifacts/contracts/deploy/Create3Deployer.sol/Create3Deployer.json';
import { chainScans } from '../explorerscan';
import { networkConfig } from "../hardhat.config";
require('dotenv').config();

function getEvmChains() {
  return chainScans.map((chain) => ({ ...chain }));
}

function encodeInitData() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  const unlockTime = currentTimestampInSeconds + 60;
  
  // Encode the function call
  const initFunction = 'initialize(uint256)';
  const initData = ethers.utils.defaultAbiCoder.encode(['uint256'], [unlockTime]);
  const initSignature = ethers.utils.keccak256(ethers.utils.toUtf8Bytes(initFunction)).slice(0, 10);   // Remove 0x
  return initSignature + initData.substring(2);
}

async function main() {
  // const token = await ethershardhat.deployContract('contracts/MGEKUSDCToken.sol:MGEKUSDCToken', 
  //                                           ['MysGecko-USDC', 'USDC', ethershardhat.parseEther("9999999")]);
  // await token.waitForDeployment();
  // console.log(ethershardhat.parseEther("9999999"));
  // console.log('MysGecko-USDC Contract Deployed at ' + token.target);

  const CONST_ADDRESS_DEPLOYER_ADDR = '0x98b2920d53612483f91f12ed7754e51b4a77919e';

  const evmChains = getEvmChains();

  // console.log(networkConfig.networks['base-mainnet']);
  for (const chain of evmChains) {
    console.log("chain.network: ", `${chain.network}`);
    console.log(networkConfig.networks[`${chain.network}`].url);
    const wallet = new Wallet(process.env.WALLET_KEY as string);
    const provider = getDefaultProvider(networkConfig.networks[`${chain.network}`].url);
    const connectedWallet = wallet.connect(provider);
    const deployerContract = await new ethers.Contract(CONST_ADDRESS_DEPLOYER_ADDR, Create2Deployer.abi, connectedWallet);
    
    console.log("deployerContract: ", deployerContract.target);
    // encodeInitData();
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
