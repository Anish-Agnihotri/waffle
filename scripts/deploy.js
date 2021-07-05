async function deploy() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const number = ethers.utils.parseEther("0.1");

  const WaffleFactory = await ethers.getContractFactory("WaffleFactory");
  const waffleFactory = await WaffleFactory.deploy(
      number,
      "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4",
      "0xa36085F69e2889c224210F603D836748e7dC0088",
      "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9"
  );
  await waffleFactory.deployed();

  console.log("WaffleFactory address: ", waffleFactory.address);
}

deploy()
  .then(() => process.exit(0))
  .catch((error) => {
      console.error(error);
      process.exit(1);
  });