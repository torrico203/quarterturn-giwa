require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();

// GIWA Sepolia (테스트넷) — https://docs.giwa.io
//   Chain ID  : 91342
//   RPC       : https://sepolia-rpc.giwa.io
//   Explorer  : https://sepolia-explorer.giwa.io (Blockscout)
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.28',
    settings: { optimizer: { enabled: true, runs: 200 }, evmVersion: 'cancun' },
  },
  networks: {
    giwaSepolia: {
      url: 'https://sepolia-rpc.giwa.io',
      chainId: 91342,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
    },
  },
  etherscan: { enabled: false },
  blockscout: {
    enabled: true,
    customChains: [
      {
        network: 'giwaSepolia',
        chainId: 91342,
        urls: {
          apiURL: 'https://sepolia-explorer.giwa.io/api',
          browserURL: 'https://sepolia-explorer.giwa.io',
        },
      },
    ],
  },
  sourcify: { enabled: false },
};
