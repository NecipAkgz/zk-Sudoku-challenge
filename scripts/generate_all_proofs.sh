#!/bin/bash

# Script to generate proofs for all 5 boards using native bb

echo "=========================================="
echo "Generating proofs for all 5 boards (Native bb)"
echo "=========================================="

# Ensure bb is in path
source ~/.zshrc

cd circuits

# Clean previous build to ensure consistency
echo "Cleaning previous build..."
rm -rf target
nargo compile

for i in {1..5}; do
    echo ""
    echo "==================== Board $i ===================="

    # Copy Prover file
    echo "Copying Prover_$i.toml..."
    cp -f Prover_$i.toml Prover.toml

    # Execute witness
    echo "Executing witness..."
    nargo execute witness 2>&1 | grep -E "(Circuit output|successfully|error)"

    if [ $? -ne 0 ]; then
        echo "❌ Failed to execute witness for board $i"
        continue
    fi

    # Generate proof
    echo "Generating proof..."
    bb prove -b ./target/circuits.json -w ./target/witness.gz -o ./target/proof_$i

    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate proof for board $i"
        continue
    fi

    # Generate VK (only needed once)
    if [ $i -eq 1 ]; then
        echo "Generating Verification Key..."
        bb write_vk -b ./target/circuits.json -o ./target/vk
    fi

    # Verify proof locally
    echo "Verifying proof locally..."
    bb verify -k ./target/vk -p ./target/proof_$i

    if [ $? -eq 0 ]; then
        echo "✅ Board $i: Proof generated and verified successfully!"
    else
        echo "❌ Board $i: Proof verification failed!"
    fi
done

echo ""
echo "=========================================="
echo "All proofs generated and verified locally!"
echo "=========================================="
echo ""
echo "Proof files:"
ls -lh target/proof_*
