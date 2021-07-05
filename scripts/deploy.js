async function deploy() {

    const [deployer] = await ethers.getSigners();
  
    console.log(
      "Deploying contracts with the account:",
      deployer.address
    );
  
    const Waffle = await ethers.getContractFactory("Waffle");
    const waffle = await Waffle.deploy();
    const WaffleFactory = await ethers.getContractFactory("WaffleFactory");
    const waffleFactory = await WaffleFactory.deploy();
  
    console.log("Waffle address: ", waffle.address);
    console.log("WaffleFactory address: ", waffleFactory.address);
  }