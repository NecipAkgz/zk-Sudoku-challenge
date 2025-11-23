import hre from "hardhat";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  if (!fs.existsSync("deployment.json")) {
    console.error("deployment.json not found. Run deploy.js first.");
    process.exit(1);
  }

  const deployment = JSON.parse(fs.readFileSync("deployment.json", "utf8"));
  const sudokuVerifierAddress = deployment.sudokuVerifier;

  console.log(`Connecting to SudokuVerifier at ${sudokuVerifierAddress}...`);
  const SudokuVerifier = await hre.ethers.getContractAt(
    "SudokuVerifier",
    sudokuVerifierAddress
  );

  // Read Proof and Public Signals (keeping numbers as strings)
  const proofPath = path.join(__dirname, "../circom_circuits/proof_2.json");
  const publicPath = path.join(__dirname, "../circom_circuits/public_2.json");

  if (!fs.existsSync(proofPath) || !fs.existsSync(publicPath)) {
    console.error("Proof or public signals file not found.");
    process.exit(1);
  }

  // Read files as text and parse manually to preserve big numbers as strings
  const proofText = fs.readFileSync(proofPath, "utf8");
  const publicText = fs.readFileSync(publicPath, "utf8");

  const proof = JSON.parse(proofText);
  const publicSignals = JSON.parse(publicText);

  console.log("Submitting REAL proof for verification...");
  console.log(`Commitment: ${publicSignals[0]}`);

  // Format proof for Solidity
  // Groth16 proof structure:
  // pA: [x, y]
  // pB: [[x0, x1], [y0, y1]] - note the coordinate swap for pB
  // pC: [x, y]

  const pA = [proof.pi_a[0], proof.pi_a[1]];
  const pB = [
    [proof.pi_b[0][1], proof.pi_b[0][0]],
    [proof.pi_b[1][1], proof.pi_b[1][0]],
  ];
  const pC = [proof.pi_c[0], proof.pi_c[1]];
  const pubSignals = [publicSignals[0]];

  try {
    const tx = await SudokuVerifier.verifySudokuProof(pA, pB, pC, pubSignals);
    console.log(`Transaction sent: ${tx.hash}`);
    console.log("Waiting for confirmation...");

    const receipt = await tx.wait();
    console.log(`Transaction confirmed in block ${receipt.blockNumber}`);

    // Check for events
    const filter = SudokuVerifier.filters.ProofVerified();
    const events = await SudokuVerifier.queryFilter(filter, receipt.blockHash);

    if (events.length > 0) {
      console.log("✅ Proof Verified Event emitted!");
      console.log("🎉 SUCCESS! On-chain verification completed!");
    } else {
      console.log("⚠️ Transaction succeeded but no event found (check logs)");
    }
  } catch (error) {
    console.error("❌ Verification transaction failed:");
    if (error.data) {
      console.error("Revert reason:", error.data);
    } else {
      console.error(error.message || error);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
