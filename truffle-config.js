const fs = require('fs');
const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 7545,
      network_id: '*',
    },
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, `HTTP://127.0.0.1:7545`),
      network_id: 97,
      confirmations: 10,
      networkCheckTimeout: 4000000,
      timeoutBlocks: 800,
      skipDryRun: true,
      gas: 8500000,
      gasPrice: 20000000000,
      from: deployAddress,
    },
    bsc: {
      provider: () => new HDWalletProvider(mnemonic, `https://bsc-dataseed.binance.org`),
      network_id: 56,
      confirmations: 10,
      networkCheckTimeout: 4000000,
      timeoutBlocks: 800,
      skipDryRun: true,
      gas: 8500000,
      gasPrice: 20000000000,
      from: deployAddress,
    },
  },
  compilers: {
    solc: {
      version: '0.8.9',
    },
  },
  plugins: ['truffle-contract-size'],
};
