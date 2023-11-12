const HDWalletProvider = require("@truffle/hdwallet-provider");
require('dotenv').config();

const bscProvider = "https://bsc-dataseed.binance.org/";
const ownerKey = process.env.PRIVATE_KEY;

//Test
const bscProviderTest = "https://data-seed-prebsc-2-s1.bnbchain.org:8545/";

module.exports = {

  networks: {
    bsc: {
      provider: function () {
        return new HDWalletProvider(
          ownerKey,
          bscProvider
        );
      },
      network_id: 56,
    },

    bscTest: {
      provider: function () {
        return new HDWalletProvider(
          ownerKey,
          bscProviderTest
        );
      },
      network_id: 97,
    }
  },

  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: { token: "BNB" } // See options below
  },
  plugins: ["solidity-coverage", 'truffle-plugin-verify'],
  api_keys: {
    bscscan: process.env.BSCKEY,
  },
  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.17", // Fetch exact version from solc-bin (default: truffle's version)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
};
