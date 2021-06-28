# Waffle

Waffle is a simple primitive for NFT raffles inspired by [Jon Itzler](https://twitter.com/jonitzler/status/1408472539182120967).

1. NFT Owners can specify the number of available raffle slots, and price per slot.
2. Entrants can deposit and withdraw until all slots are filled.
3. Owners can raffle the NFT and select a winner at any point (slots filled or not).

Additionally:

1. Owners can delete a raffle so long as a winner hasn't been selected.

## Run locally

Edit the necessary RPC endpoints and private keys in `hardhat.config.js`. It is recommended to run the test suite against Chainlink's [Kovan or Rinkeby](https://docs.chain.link/docs/vrf-contracts/) deployments, to remove the need to simulate Chainlink VRF responses.

```bash
# Install dependencies
npm install

# Run tests
npx hardhat test
```

## Status

- [X] Base `Waffle.sol` contract
- [X] Base `WaffleFactory.sol` contract
- [ ] Testing suite

## Architecture

`Waffle.sol` is a full-fledged raffle system that enables the deposit, withdrawal, and post-raffle disbursement of an `ERC721` NFT. Randomness during winner selection is guaranteed through the use of a [Chainlink VRF oracle](https://docs.chain.link/docs/chainlink-vrf/).

`WaffleFactory.sol` is the factory deployed for child `Waffle.sol` instances. It simplifies the deployment of a raffle and ensures that deployers pre-fund `Waffle.sol` instances with the `LINK` necessary to retrieve a random result from the Chainlink oracle.

## Extensions + Limitations

1. Extension: Can include an automatic raffle timestamp to force a raffle to occur, regardless of whether a NFT owner chooses or not. Or, can remove the ability to delete a raffle.
2. Limitation: When too many slots are filled, you can hit the upper limit for gas on successive `transfer` calls when deleting a raffle.

## Credits

[Freepik](https://www.flaticon.com/free-icon/stroopwafel_3531066?term=waffle&page=1&position=3&page=1&position=3&related_id=3531066&origin=search#) for the icon.
