import hre from "hardhat";

async function main() {
  const txHash =
    "0x421b2f352e20c5326c7116abd54c8dce4de05732ee6a36bd92ba17f4012b207a";

  console.log(`Checking transaction: ${txHash}`);

  const receipt = await hre.ethers.provider.getTransactionReceipt(txHash);

  if (!receipt) {
    console.log("Transaction not found or not yet mined");
    return;
  }

  console.log(`Block Number: ${receipt.blockNumber}`);
  console.log(`Status: ${receipt.status === 1 ? "✅ SUCCESS" : "❌ FAILED"}`);
  console.log(`Gas Used: ${receipt.gasUsed.toString()}`);

  if (receipt.status === 1) {
    console.log("\n🎉 PROOF VERIFIED ON-CHAIN!");
    console.log("\nTransaction Details:");
    console.log(`- Block: ${receipt.blockNumber}`);
    console.log(`- From: ${receipt.from}`);
    console.log(`- To: ${receipt.to}`);
    console.log(`- Gas Used: ${receipt.gasUsed.toString()}`);

    // Try to decode logs
    console.log(`\nLogs: ${receipt.logs.length} events emitted`);

    if (receipt.logs.length > 0) {
      console.log("\n✅ Events were emitted - verification successful!");
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
