// Imports
require("@nomiclabs/hardhat-waffle");

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    hardhat: {
      forking: {
        // Kovan RPC endpoint
        url: "",
        blockNumber: 25725290,
      },
    },
  },
};
