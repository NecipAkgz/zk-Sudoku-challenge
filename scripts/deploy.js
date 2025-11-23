const hre = require("hardhat");
const fs = require("fs");

async function main() {
  console.log("Starting deployment process...");

  // 1. Deploy UltraVerifier // Deploy Groth16Verifier
  console.log("Deploying Groth16Verifier...");
  const Groth16Verifier = await hre.ethers.getContractFactory(
    "Groth16Verifier"
  );
  const verifier = await Groth16Verifier.deploy();
  await verifier.waitForDeployment();
  const verifierAddress = await verifier.getAddress();
  console.log(`Groth16Verifier deployed to: ${verifierAddress}`);

  // Deploy SudokuVerifier
  console.log("Deploying SudokuVerifier...");
  const SudokuVerifier = await hre.ethers.getContractFactory("SudokuVerifier");
  const sudokuVerifier = await SudokuVerifier.deploy(verifierAddress);
  await sudokuVerifier.waitForDeployment();
  const sudokuVerifierAddress = await sudokuVerifier.getAddress();
  console.log(`SudokuVerifier deployed to: ${sudokuVerifierAddress}`);

  // Save deployment info
  const deploymentInfo = {
    verifier: verifierAddress,
    sudokuVerifier: sudokuVerifierAddress,
    network: network.name,
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
