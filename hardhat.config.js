// Imports
require("@nomiclabs/hardhat-waffle");


// Go to https://www.alchemyapi.io, sign up, create
// a new App in its dashboard, and replace "KEY" with its key
const INFURA_API_KEY = "";

// Replace this private key with your Ropsten account private key
// To export your private key from Metamask, open Metamask and
// go to Account Details > Export Private Key
// Be aware of NEVER putting realnpx  Ether into testing accounts
const KOVAN_PRIVATE_KEY = "";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.0",
  networks: {
    kovan: {
      url: `https://kovan.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [`0x${KOVAN_PRIVATE_KEY}`]
    },
    hardhat: {
      forking: {
        // Kovan RPC endpoint
        url: "",
        blockNumber: 25725290,
      },
    },
  },
};
