# Lessons Learned: Building ZK-Sudoku on Arc

A practical guide for developers attempting similar ZK challenges.

---

## TL;DR

- ✅ Choose battle-tested tools over cutting-edge ones
- ✅ Start simple, add complexity gradually
- ✅ Have a backup plan (alternative proof systems)
- ✅ Test locally before deploying on-chain
- ✅ Document everything as you go

---

## 1. Tooling Selection

### What I Learned

**Initial Choice: Noir + UltraHonk**

- Pros: Modern syntax, no trusted setup
- Cons: Beta tooling, verifier generation bugs

**Final Choice: Circom + Groth16**

- Pros: Production-tested, reliable verifier generation
- Cons: Trusted setup (but public ceremonies exist)

### Recommendation

For production systems:

```
Reliability > Innovation
Proven > Cutting-edge
Working > Perfect
```

**Questions to Ask:**

- Has this been used in production?
- Are there successful examples?
- How active is the community?
- What's the debugging experience like?

---

## 2. Circuit Development

### Start Simple

**Don't:**

```circom
// Trying to build everything at once
template ComplexSudoku() {
    // 625 cells + commitment + validation all together
}
```

**Do:**

```circom
// Build incrementally
template CheckUnique9() { ... }  // Test with 9 first
template CheckUnique25() { ... } // Scale up
template Sudoku25x25() { ... }   // Compose
```

### Test Incrementally

1. **Unit test** individual components
2. **Integration test** composed circuits
3. **Local verification** before deployment
4. **On-chain test** with small examples first

---

## 3. Debugging Strategies

### The Challenge

ZK circuits are hard to debug:

- No console.log()
- Constraint failures are cryptic
- Tooling bugs look like code bugs

### Strategies That Worked

**1. Simplify to Isolate**

```
Full circuit failing?
→ Test just row validation
→ Test with 9×9 instead of 25×25
→ Test with hardcoded values
```

**2. Compare Implementations**

```
Noir version working locally?
→ Port to Circom
→ Compare constraint counts
→ Verify same logic
```

**3. Consult Multiple Sources**

- AI coding assistants (different perspectives)
- Community Discord
- GitHub issues
- Documentation examples

**4. Know When to Pivot**

Spent 2+ weeks on Noir debugging:

- Tried different `bb` versions
- Manually patched verifier contracts
- Consulted multiple AI assistants
- All pointed to same conclusion: tooling bug

**Decision:** Pivot to Circom → Success in 1 day

---

## 4. Commitment Design

### Requirements

1. Binding (changing input changes commitment)
2. Deterministic (same input = same commitment)
3. Efficient (low constraint count)

### What I Tried

**Option 1: Poseidon Hash**

- ✅ Cryptographically secure
- ❌ High constraint count
- ❌ Overkill for this use case

**Option 2: Polynomial Hash**

- ✅ Efficient (minimal constraints)
- ✅ Binding property
- ✅ Deterministic
- ✅ Good enough for Sudoku

**Chosen:** Polynomial hash with base 257

### Lesson

**Perfect is the enemy of good.**

You don't always need cryptographic-grade hashes. For Sudoku:

- Collision resistance: not critical (honest prover)
- Binding: critical (achieved with polynomial hash)
- Efficiency: critical (achieved with simple arithmetic)

---

## 5. Gas Optimization

### Contract Size

**Problem:** Verifier contract too large for deployment

**Solutions:**

1. Optimize Solidity compiler settings

   ```javascript
   optimizer: {
     enabled: true,
     runs: 1  // Optimize for size, not runtime
   }
   ```

2. Use Groth16 (smaller verifier than UltraHonk)

3. Remove unnecessary functions

### Verification Cost

**Groth16 Advantages:**

- Constant-size proofs (~200 bytes)
- Constant verification time
- Predictable gas (~250K)

**Result:** Deployable and affordable on Arc Testnet

---

## 6. Documentation

### What Worked

**1. Document as You Go**

- Don't wait until the end
- Capture decisions and rationale
- Note dead ends and why they failed

**2. Multiple Formats**

- Inline code comments (for developers)
- README (for users)
- Technical deep-dive (for reviewers)
- Lessons learned (for community)

**3. Be Honest**

- Share failures, not just successes
- Explain pivots and why
- Help others avoid same mistakes

---

## 7. Community Engagement

### What Helped

**1. Ask for Help**

- Discord communities
- AI coding assistants
- GitHub discussions

**2. Share Progress**

- Post updates
- Ask specific questions
- Contribute back

**3. Accept Feedback**

- Admin's review was valuable
- Community suggestions helped
- Iterate based on input

---

## 8. Time Management

### Reality Check

**Initial Estimate:** 1 week
**Actual Time:** 3+ weeks

**Breakdown:**

- Noir implementation: 1 week
- Debugging Noir: 2 weeks
- Circom migration: 1 day
- Testing & deployment: 2 days
- Documentation: 1 day

### Lesson

**Budget extra time for:**

- Tooling issues (biggest unknown)
- Learning curve (new tech)
- Debugging (always longer than expected)
- Documentation (don't skip this!)

---

## 9. When to Pivot

### Red Flags

- Same error after multiple fix attempts
- No progress for several days
- Community reports similar issues
- Multiple sources confirm it's a known bug

### Decision Framework

```
Is it my code? → Debug more
Is it the tooling? → Try workarounds
Workarounds failing? → Consider alternatives
Alternative exists? → Pivot
No alternative? → Wait for fix or abandon
```

### My Pivot

**Trigger:** All debugging paths exhausted
**Decision:** Switch to Circom
**Result:** Success in <24 hours
**Lesson:** Sometimes starting over is faster than debugging

---

## 10. Production Readiness

### Checklist

- [ ] Circuit tested with multiple inputs
- [ ] Local verification successful
- [ ] On-chain verification successful
- [ ] Gas costs acceptable
- [ ] Code documented
- [ ] Deployment reproducible
- [ ] Edge cases considered

### My Results

- ✅ 5 boards tested
- ✅ Local verification: 100% success
- ✅ On-chain: Verified on Arc Testnet
- ✅ Gas: ~250K (acceptable)
- ✅ Documentation: Complete
- ✅ Reproducible: Scripts provided
- ⚠️ Edge cases: Basic coverage

---

## Key Takeaways

1. **Tooling matters more than you think**

   - Choose proven over innovative
   - Have a backup plan

2. **Iterate quickly**

   - Start simple
   - Test often
   - Pivot when stuck

3. **Document everything**

   - Future you will thank you
   - Community will benefit
   - Reviewers will appreciate it

4. **Know when to quit**

   - Debugging has diminishing returns
   - Sometimes starting over is faster
   - Don't be afraid to pivot

5. **Community is key**
   - Ask for help
   - Share learnings
   - Give back

---

## For Future Challengers

### If You're Attempting This Challenge

**Week 1:**

- Choose your proof system carefully
- Start with 9×9 to validate approach
- Test locally before scaling

**Week 2:**

- Scale to 25×25
- Test with multiple boards
- Debug any issues

**Week 3:**

- Deploy to testnet
- Verify on-chain
- Document everything

### If You Get Stuck

1. Simplify the problem
2. Test with known-good examples
3. Ask the community
4. Consider alternatives
5. Don't be afraid to pivot

---

## Resources

- **This Project:** [GitHub Link]
- **Circom Docs:** https://docs.circom.io/
- **SnarkJS:** https://github.com/iden3/snarkjs
- **Arc Discord:** [Link]

---

**Remember:** Every expert was once a beginner who didn't give up.

Good luck! 🚀
