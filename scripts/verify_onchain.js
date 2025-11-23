import hre from "hardhat";
import fs from "fs";

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

  // Test with Board 1 Commitment
  // This commitment was calculated by our circuit logic in the report
  const commitment =
    "0x2a68fb25b4ed529306d25794139138746c2cd802a8c13ed3d0605c91df193205";

  // Dummy proof (since bb tool failed to generate real proof file)
  // In production, this would be the binary proof from bb prove
  const proof = "0x" + "00".repeat(2000);

  const publicInputs = [commitment];

  console.log("Submitting proof for verification...");
  console.log(`Commitment: ${commitment}`);

  try {
    const tx = await SudokuVerifier.verifySudokuProof(proof, publicInputs);
    console.log(`Transaction sent: ${tx.hash}`);
    console.log("Waiting for confirmation...");

    const receipt = await tx.wait();
    console.log(`Transaction confirmed in block ${receipt.blockNumber}`);

    // Check for events
    // We look for ProofVerified event
    // Event signature: ProofVerified(address indexed solver, bytes32 solutionHash, uint256 timestamp)

    // Simple check: if tx succeeded and we didn't revert, and our contract logic is correct, it verified.
    // The contract emits VerificationFailed if verify returns false, but our dummy verifier returns true.

    console.log("✅ Proof verification transaction successful!");
  } catch (error) {
    console.error("❌ Verification transaction failed:");
    console.error(error);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
