#!/bin/bash

# Script to generate proofs for all 5 boards

echo "=========================================="
echo "Generating proofs for all 5 boards"
echo "=========================================="

cd circuits

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
    ../node_modules/.bin/bb.js prove -b ./target/circuits.json -w ./target/witness.gz -o ./target/proof_$i

    if [ $? -ne 0 ]; then
        echo "❌ Failed to generate proof for board $i"
        continue
    fi

    # Verify proof
    echo "Verifying proof..."
    ../node_modules/.bin/bb.js verify -k ./target/vk -p ./target/proof_$i

    if [ $? -eq 0 ]; then
        echo "✅ Board $i: Proof generated and verified successfully!"
    else
        echo "❌ Board $i: Proof verification failed!"
    fi
done

echo ""
echo "=========================================="
echo "All proofs generated!"
echo "=========================================="
echo ""
echo "Proof files:"
ls -lh target/proof_*
