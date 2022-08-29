// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { parseBytes32String } = require("ethers/lib/utils");
const hre = require("hardhat");

async function main() {
  const [owner, otherAccount] = await ethers.getSigners();

  const Link = await hre.ethers.getContractFactory("Link");
  const link = await Link.deploy();

  const DEX = await hre.ethers.getContractFactory("Wallet");
  const dex = await DEX.deploy();

  await link.deployed();
  console.log(`Deployed ${await link.symbol()}`);
  console.log(`Balance of owner ${await link.balanceOf(owner.address)}`);



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
