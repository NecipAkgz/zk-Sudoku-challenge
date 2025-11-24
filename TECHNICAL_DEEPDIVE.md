# Technical Deep-Dive: 25×25 ZK Sudoku

A production-ready Zero-Knowledge Sudoku verifier for 25×25 grids on Arc blockchain.

---

## Overview

**Challenge:** Build a ZK verifier for 25×25 Sudoku with cryptographic commitments on Arc.

**Result:** ✅ Successfully deployed and verified on-chain (~250K gas)

**Tech Stack:**

- Circuit: Circom 2.1.6
- Proof System: Groth16
- Constraints: 52,500
- Proof Size: ~200 bytes

---

## The Migration Story

### Initial Attempt: Noir + UltraHonk

Started with Noir because it was recommended in the challenge example.

**The Problem:**

After hours of debugging, hit an unfixable bug in Barretenberg v0.87.0:

- Verifier generation broken (all parameters set to 0)
- `SumcheckFailed` errors on-chain
- Proofs worked locally but failed on-chain

**Root Cause:** Tooling bug in `bb`'s Solidity verifier generation for UltraHonk.

### The Pivot: Circom + Groth16

**Why switch?**

- Battle-tested (Tornado Cash, zkSync, Polygon use it)
- Reliable verifier generation
- Proven to work in production

**Migration:**

1. Rewrote circuit in Circom (~1 hour)
2. Setup proving/verification keys (~1 hour)
3. Generated and tested proofs (~1 hour)
4. **Result:** First-attempt on-chain success! ✅

---

## Circuit Architecture

```
Input: solution[625] (private) + expectedCommitment (public)
  ↓
├─ Row Validation (25 × 350 constraints)
├─ Column Validation (25 × 350 constraints)
├─ Box Validation (25 × 350 constraints)
└─ Commitment Verification
  ↓
Output: Valid proof if all constraints satisfied
```

**Total:** 52,500 constraints

---

## Cryptographic Commitment

**Formula:**

```
commitment = Σ(solution[i] × 257^i) for i = 0 to 624
```

**Why polynomial hash?**

- ✅ Binding (changing any cell changes commitment)
- ✅ Deterministic (same board = same commitment)
- ✅ Efficient (minimal constraints)
- ✅ Good enough for Sudoku (no need for Poseidon/Keccak)

---

## On-Chain Verification

**Deployed Contracts (Arc Testnet):**

- Groth16Verifier: `0x6c20FF7b2d8944EBFfF0B23502bC71114807e1DC`
- SudokuVerifier: `0xe81FCD8fcA77fA607F51fB09B775A0bFAaf6c989`

**Verified Transaction:**

```
TX: 0x421b2f352e20c5326c7116abd54c8dce4de05732ee6a36bd92ba17f4012b207a
Block: 12737672
Gas: 249,899
Status: ✅ SUCCESS
```

---

## Key Learnings

1. **Tooling Maturity Matters**

   - Proven tools > Cutting-edge tools
   - Groth16 worked, UltraHonk didn't

2. **Know When to Pivot**

   - Spent hours debugging Noir
   - Switched to Circom → success in hours
   - Sometimes starting over is faster

3. **Keep It Simple**
   - Polynomial hash > Poseidon (for this use case)
   - Efficient > Perfect

---

## Performance

| Metric           | Value      |
| ---------------- | ---------- |
| Constraints      | 52,500     |
| Proof Size       | ~200 bytes |
| Proof Generation | ~5 seconds |
| Gas Cost         | 249,899    |

---

## Resources

- **Deployed Contracts:** Arc Testnet
- **Circom Docs:** https://docs.circom.io/
- **SnarkJS:** https://github.com/iden3/snarkjs

---

**Author:** Neco
**Date:** November 2025
