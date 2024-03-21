import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import { chainScans } from './explorerscan';
require('@openzeppelin/hardhat-upgrades');
require("hardhat-gas-reporter")
require('dotenv').config();

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.21',
    settings: {
      optimizer: {
        enabled: true,
        runs: 2000, // Adjust the runs value as needed
      },
    },
  },
  sourcify: {
    enabled: false
  },
  allowUnlimitedContractSize: true,
  gasReporter: {
    outputFile: "report/gas-report.txt",
    enabled: true,
    onlyCalledMethods: true,
    showTimeSpent: true,
    currency: 'USD',
    noColors: true,
    gasPrice: 2200,
    token: "ETH",
    // coinmarketcap: process.env.COIN_MARKETCAP_API_KEY || ""
  },
  networks: {
    // BASE
    'base-mainnet': {
      url: process.env.BASE_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'base-mainnet': {
      url: process.env.BASE_MAINNET_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'base-sepolia': {
      url: process.env.BASE_SEPOLIA_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'op-sepolia': {
      url: process.env.OP_SEPOLIA_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'op-mainnet': {
      url: process.env.OP_MAINNET_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    // BLAST
    'blast-sepolia': {
      url: process.env.BLAST_SOPELIA_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'blast-mainnet': {
      url: process.env.BLAST_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    // POLYGON
    'polygon-mumbai': {
      url: process.env.POLYGON_MUMBAI_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'polygon-mainnet': {
      url: process.env.POLYGON_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    // ETHER
    'ether-sepolia': {
      url: process.env.ETHER_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    'ether-mainnet': {
      url: process.env.ETHER_SOPELIA_RPC_URL,
      accounts: [process.env.WALLET_KEY as string],
      gasPrice: 1000000000,
    },
  },
  defaultNetwork: 'hardhat',
  etherscan: {
    apiKey: {
      "base-goerli": "PLACEHOLDER_STRING",
      "base-sepolia": process.env.BASESCAN_API_KEY as string,
      "base-mainnet": process.env.BASESCAN_API_KEY as string,
      "op-sepolia": process.env.BASESCAN_API_KEY as string,
      "op-mainnet": process.env.BASESCAN_API_KEY as string,
      "blast-sepolia": "blast_sepolia",
      "blast-mainnet": process.env.BLASTSCAN_API_KEY as string,
      "polygon-mumbai": process.env.POLYGONSCAN_API_KEY as string,
      "polygon-mainnet": process.env.POLYGONSCAN_API_KEY as string,
      "ether-sepolia": "-------",
      "ether-mainnet": process.env.ETHERSCAN_API_KEY as string,
    },
    customChains: chainScans
  },
};

export default config;
export const networkConfig = config;
