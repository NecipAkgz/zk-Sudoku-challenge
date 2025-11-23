#!/bin/bash

# Generate and verify all 5 Sudoku proofs using Circom + Groth16

echo "============================================"
echo "Generating and Verifying All Sudoku Proofs"
echo "============================================"
echo ""

cd circom_circuits

for i in {1..5}
do
    echo "Processing Board $i..."

    # Generate witness
    echo "  → Generating witness..."
    node sudoku_js/generate_witness.js sudoku_js/sudoku.wasm input_${i}.json witness_${i}.wtns

    if [ $? -ne 0 ]; then
        echo "  ❌ Witness generation failed for board $i"
        continue
    fi

    # Generate proof
    echo "  → Generating proof..."
    snarkjs groth16 prove sudoku_final.zkey witness_${i}.wtns proof_${i}.json public_${i}.json

    if [ $? -ne 0 ]; then
        echo "  ❌ Proof generation failed for board $i"
        continue
    fi

    # Verify proof locally
    echo "  → Verifying proof locally..."
    snarkjs groth16 verify verification_key.json public_${i}.json proof_${i}.json

    if [ $? -eq 0 ]; then
        echo "  ✅ Board $i: Proof verified successfully!"
    else
        echo "  ❌ Board $i: Proof verification failed!"
    fi

    echo ""
done

cd ..

echo "============================================"
echo "Summary:"
echo "All proofs generated in circom_circuits/"
echo "  - proof_1.json to proof_5.json"
echo "  - public_1.json to public_5.json"
echo ""
echo "To verify on-chain:"
echo "  1. Update scripts/verify_onchain.js to use desired proof"
echo "  2. Run: npx hardhat run scripts/verify_onchain.js --network arc"
echo "============================================"
