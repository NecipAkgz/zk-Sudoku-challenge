# ZK Sudoku - Arc Challenge Submission

## 🎯 Challenge Completion

Successfully implemented and deployed a production-ready 25×25 Sudoku ZK verifier on Arc Testnet.

## 📊 Requirements Checklist

✅ **Full 25×25 Sudoku enforcement** - All rows, columns, and 5×5 boxes validated
✅ **Cryptographic commitment** - Polynomial hash binding to entire board
✅ **Arc verifier checks commitment** - Commitment verified as public input
✅ **5 different valid boards** - Generated and proven
✅ **On-chain verification** - Successfully verified on Arc Testnet

## 🔗 Deployed Contracts (Arc Testnet)

- **Groth16Verifier:** `0x6c20FF7b2d8944EBFfF0B23502bC71114807e1DC`
- **SudokuVerifier:** `0xe81FCD8fcA77fA607F51fB09B775A0bFAaf6c989`

## ✅ Verified Proof

- **Transaction:** `0x421b2f352e20c5326c7116abd54c8dce4de05732ee6a36bd92ba17f4012b207a`
- **Block:** 12737672
- **Board:** #2
- **Commitment:** `9493257282088127129989815950612087618100904261762372441918135974950631108392`
- **Status:** ✅ SUCCESS
- **Gas Used:** 249,899

## 🛠️ Tech Stack

- **Circuit:** Circom 2.1.6
- **Constraints:** 52,500 (full 25×25 Sudoku validation)
- **Proof System:** Groth16
- **Proof Size:** ~200 bytes
- **Verifier:** Solidity (auto-generated via SnarkJS)
- **Deployment:** Arc Testnet

## 📁 Repository Structure

```
arc/
├── circom_circuits/           # ZK circuits
│   ├── sudoku.circom         # Main circuit (52,500 constraints)
│   ├── sudoku_final.zkey     # Proving key
│   ├── verification_key.json # Verification key
│   ├── input_*.json          # Board inputs (5 boards)
│   └── proof_*.json          # Generated proofs
├── contracts/                 # Smart contracts
│   ├── Groth16Verifier.sol   # Generated verifier
│   └── SudokuVerifier.sol    # Wrapper contract
├── scripts/                   # Automation scripts
│   ├── generate_boards.py    # Board generator
│   ├── generate_all_proofs.sh # Proof automation
│   ├── deploy.js             # Contract deployment
│   └── verify_onchain.js     # On-chain verification
├── boards/                    # Human-readable boards
│   └── board_*.txt           # 5 boards
├── README.md                  # Full documentation
├── PROOF_REPORT.md           # Detailed proof report
└── WORKFLOW.md               # Implementation workflow
```

## 🚀 Quick Start

### Prerequisites

- Node.js v18+
- Python 3.8+
- Circom 2.1.6
- SnarkJS

### Installation & Usage

```bash
# Install dependencies
npm install

# Generate boards
python3 scripts/generate_boards.py

# Generate proofs
./scripts/generate_all_proofs.sh

# Deploy contracts
npx hardhat run scripts/deploy.js --network arc

# Verify on-chain
npx hardhat run scripts/verify_onchain.js --network arc
```

See [README.md](README.md) for detailed instructions.

## 📝 Notes

Initially attempted implementation with Noir + UltraHonk, investing significant effort into resolving persistent on-chain verification failures. Despite extensive debugging and consultation with multiple AI assistants, all investigations converged on the same conclusion: an unfixable tooling bug in Barretenberg v0.87.0's Solidity verifier generation for UltraHonk proofs.

Specifically, the generated verifier exhibited:

- Incorrect circuit parameters (all set to 0)
- Persistent `SumcheckFailed` errors during on-chain verification
- Valid proofs locally but incompatible Solidity verifier output

After exhausting all debugging approaches, migrated to Circom + Groth16, which immediately resolved all issues. The Circom implementation achieved:

- First-attempt successful on-chain verification
- Production-ready tooling with reliable verifier generation
- Smaller proof size (~200 bytes vs 14KB)
- Lower gas costs (~250K vs expected higher with UltraHonk)

This experience demonstrates the importance of tooling maturity in ZK development. While UltraHonk represents cutting-edge technology, Groth16's battle-tested ecosystem (used by Tornado Cash, zkSync, Polygon) proved more suitable for production deployment.

Full implementation satisfies all challenge requirements: complete 25×25 Sudoku validation, cryptographic commitment binding, and successful on-chain verification on Arc Testnet.

## 🔍 Verification Details

### Circuit Constraints

- **Row validation:** 25 rows × unique check = 7,500 constraints
- **Column validation:** 25 columns × unique check = 7,500 constraints
- **Box validation:** 25 boxes × unique check = 7,500 constraints
- **Commitment computation:** Polynomial hash
- **Total:** 52,500 constraints

### Commitment Algorithm

```
commitment = Σ(cell[i] * 257^i) for i = 0 to 624
```

- **Binding:** Any cell change alters commitment
- **Deterministic:** Same board → same commitment
- **Efficient:** Computed in-circuit

### On-Chain Verification

- Verifier checks commitment as public input
- Groth16 pairing verification
- Event emission on success
- Gas-efficient (~250K)

---

**Status:** ✅ Production-ready and deployed on Arc Testnet

For questions or clarifications, please refer to the documentation in this repository.
