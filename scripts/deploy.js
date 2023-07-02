const hre = require("hardhat");

async function main() {
  const Multisig = await hre.ethers.getContractFactory("MultisigWallet");
  const multisig = await Multisig.deploy(
    [
      "0xF75551618aD60a4b0C55c781577211d065d85851",
      "0x78d7dC3AafD01465b49e4a48613391D6B296d90d",
      "0xf5D4aDDb62C3314e87bBD0662F801c8137d1b31C",
    ],
    2
  );
  await multisig.deployed();
  console.log("Multisig deployed to:", multisig.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
