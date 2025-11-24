# Lessons Learned: ZK-Sudoku Challenge

Quick takeaways from building a 25×25 ZK Sudoku verifier.

---

## 1. Choose Proven Tools

**What I learned:** Cutting-edge ≠ Production-ready

- Started with Noir + UltraHonk (recommended in challenge)
- Hit unfixable tooling bugs
- Switched to Circom + Groth16 → immediate success

**Takeaway:** For production, choose battle-tested tools.

---

## 2. Start Simple, Test Often

**Don't:**

```
Build everything at once → debug for hours
```

**Do:**

```
Build small → test → scale up → test again
```

**My approach:**

1. Test with 9×9 first
2. Scale to 25×25
3. Test locally before on-chain

---

## 3. Know When to Pivot

**Red flags:**

- Same error after multiple attempts
- Multiple sources confirm it's a tooling bug
- No progress for hours

**My pivot:**

- Spent hours debugging Noir
- All paths led to: tooling bug
- Switched to Circom → success in hours

**Lesson:** Sometimes starting over is faster than debugging.

---

## 4. Debugging Strategies

**ZK circuits are hard to debug:**

- No console.log()
- Cryptic errors
- Tooling bugs look like code bugs

**What worked:**

1. Simplify to isolate (test 9×9 instead of 25×25)
2. Compare implementations (Noir vs Circom)
3. Ask community + AI assistants
4. Know when it's not your code

---

## 5. Commitment Design

**Don't overcomplicate:**

- Poseidon hash: Overkill for Sudoku
- Polynomial hash: Simple, efficient, works

**Requirements:**

- ✅ Binding
- ✅ Deterministic
- ✅ Efficient

**Chosen:** Polynomial hash (`Σ(cell[i] × 257^i)`)

---

## 6. Gas Optimization

**Contract too large?**

```javascript
optimizer: {
  enabled: true,
  runs: 1  // Optimize for size
}
```

**Groth16 advantages:**

- Small proofs (~200 bytes)
- Constant verification time
- Predictable gas (~250K)

---

## Key Takeaways

1. **Tooling matters** - Choose proven over innovative
2. **Iterate quickly** - Start simple, test often
3. **Pivot when stuck** - Don't waste time on unfixable bugs
4. **Keep it simple** - Good enough > Perfect

---

## Resources

- **Circom Docs:** https://docs.circom.io/
- **SnarkJS:** https://github.com/iden3/snarkjs

---

**Remember:** Every expert was once a beginner who didn't give up. 🚀
