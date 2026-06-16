## EVAL DEFINITION: gvsoc-dpi-full-regression (WP-8)

### Phase: DEFINED (2026-03-24) — not yet executed

### Capability Evals

1. [ ] All 6 CFGs produce correct `gvsoc_config.json` (misa, fpu_in_isa, mimpid)
2. [ ] CSR comparisons pass for mhpmcounter volatile marking (WP-4)
3. [ ] Tests with exceptions (illegal_instr, csr_access) pass PC/GPR compare
4. [ ] Zfinx configs produce correct ISA (no F extension in misa)

### Regression Evals (26 test/CFG pairs)

**CFG=default** (10 tests):
- [ ] hello-world
- [ ] fibonacci
- [ ] dhrystone
- [ ] riscv_arithmetic_basic_test_0
- [ ] riscv_arithmetic_basic_test_1
- [ ] csr_instructions
- [ ] illegal_instr_test
- [ ] illegal
- [ ] misalign
- [ ] generic_exception_test (WONTFIX — needs IRQ stimuli)

**CFG=no_pulp** (1 test):
- [ ] csr_instructions

**CFG=pulp** (3 tests):
- [ ] csr_instructions
- [ ] hello-world
- [ ] fibonacci

**CFG=pulp_fpu** (6 tests):
- [ ] csr_instructions
- [ ] hello-world
- [ ] cv32e40p_csr_access_test
- [ ] mhpmcounter29_csr_access_test_1
- [ ] mhpmcounter29_csr_access_test_2
- [ ] all_csr_por (TOO_LARGE — may skip or extend timeout)

**CFG=pulp_fpu_zfinx** (3 tests):
- [ ] csr_instructions
- [ ] cv32e40p_readonly_csr_access_test (NEEDS_WORK — BUG-25)
- [ ] mhpmcounter29_csr_access_test_1

**CFG=pulp_fpu_zfinx_2cyclat** (3 tests):
- [ ] csr_instructions
- [ ] cv32e40p_csr_access_test
- [ ] mhpmcounter29_csr_access_test_1

### Code-Based Graders

```bash
# Run all tests for a CFG
for TEST in <list>; do
    make test TEST=$TEST CFG=$CFG USE_ISS=YES ISS=GVSOC COMP=NO
    grep -q "SIMULATION PASSED" vsim_results/$CFG/$TEST/0/vsim-$TEST.log \
        && echo "PASS: $TEST/$CFG" \
        || echo "FAIL: $TEST/$CFG"
done
```

### Success Metrics

- Target: >= 22/26 PASS (excluding WONTFIX, TOO_LARGE, NEEDS_WORK)
- Regression: 8/8 baseline must remain PASS after any fix
- pass@3 >= 90% for capability evals

### Known Classifications (pre-existing)

| Test | CFG | Classification | Reason |
|------|-----|---------------|--------|
| generic_exception_test | default | WONTFIX | Needs interrupt stimuli |
| all_csr_por | pulp_fpu | TOO_LARGE | 5M+ instructions |
| cv32e40p_readonly_csr_access_test | pulp_fpu_zfinx | NEEDS_WORK | BUG-25 |
