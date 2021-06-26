# Waffle

### Possible extensions

1. Potential gas optimization: can abstract out the need for a `WaffleFactory.sol` and instead rely solely on a mapping of `uint256 => WaffleStruct` that contains details about the raffle, participants, and bids.
2. Can include an automatic raffle timestamp to force a raffle to occur.

### Limitations

1. Too many slots available, hit upper limit on gas for txfer
2. Chainlink VRF fee is currently hardcoded to the `0.1` LINK requirement for `Kovan` or `Rinkeby`.