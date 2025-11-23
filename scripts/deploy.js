const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("Starting deployment process...");

  // 1. Deploy UltraVerifier (Verifier.sol)
  console.log("Deploying UltraVerifier...");
  const Verifier = await hre.ethers.getContractFactory("Verifier");
  const verifier = await Verifier.deploy();
  await verifier.waitForDeployment();
  const verifierAddress = await verifier.getAddress();
  console.log(`UltraVerifier deployed to: ${verifierAddress}`);

  // 2. Deploy SudokuVerifier
  console.log("Deploying SudokuVerifier...");
  const SudokuVerifier = await hre.ethers.getContractFactory("SudokuVerifier");
  const sudokuVerifier = await SudokuVerifier.deploy(verifierAddress);
  await sudokuVerifier.waitForDeployment();
  const sudokuVerifierAddress = await sudokuVerifier.getAddress();
  console.log(`SudokuVerifier deployed to: ${sudokuVerifierAddress}`);

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    sudokuVerifier: sudokuVerifierAddress,
    ultraVerifier: verifierAddress,
    timestamp: new Date().toISOString(),
  };

  fs.writeFileSync("deployment.json", JSON.stringify(deploymentInfo, null, 2));

  console.log("Deployment info saved to deployment.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
