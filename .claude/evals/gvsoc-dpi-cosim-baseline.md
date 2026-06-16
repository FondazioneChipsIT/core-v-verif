## EVAL: gvsoc-dpi-cosim-baseline (WP-1 + WP-5)

### Phase: COMPLETE (2026-03-24)

### Capability Evals

1. [x] GVSOC engine initializes in-process via DPI (`gv::Gvsoc` in `Api_mode_sync`)
2. [x] Instruction-accurate stepping via PC-change detection (NOT instret — BUG-26)
3. [x] PC comparison DUT vs ISS produces 0 mismatches on all baseline tests
4. [x] GPR comparison DUT vs ISS produces 0 mismatches on all baseline tests
5. [x] Per-CFG config regeneration works (default/pulp/pulp_fpu produce correct misa)
6. [x] ELF path injection via `create_temp_config()` works for all test programs
7. [x] misa bit X conditional `(0x00800000 if pulpv2 else 0)` correct per CFG

### Regression Evals (8/8 PASS)

| Test | CFG | Status | Time |
|------|-----|--------|------|
| hello-world | default | PASS | 0:07 |
| fibonacci | default | PASS | 0:42 |
| dhrystone | default | PASS | 1:01 |
| riscv_arithmetic_basic_test_0 | default | PASS | 0:11 |
| riscv_arithmetic_basic_test_1 | default | PASS | 0:11 |
| illegal_instr_test | default | PASS | 4:12 |
| csr_instructions | pulp_fpu | PASS | 0:08 |
| fibonacci | pulp | PASS | 0:38 |

### Code-Based Graders

```bash
# Grader 1: SIMULATION PASSED in vsim log
grep -q "SIMULATION PASSED" vsim_results/<CFG>/<TEST>/0/vsim-<TEST>.log

# Grader 2: UVM_ERROR = 0
grep "UVM_ERROR :    0" vsim_results/<CFG>/<TEST>/0/vsim-<TEST>.log

# Grader 3: DPI library loaded
grep -q "Loading.*libgvsoc_rvvi" vsim_results/<CFG>/<TEST>/0/vsim-<TEST>.log

# Grader 4: ISS trace file created with matching instruction count
wc -l /tmp/iss_trace_<pid>.log  # should be close to DUT trace count
```

### Metrics

```
Capability:  7/7 (pass@1: 100%)
Regression:  8/8 (pass^1: 100%)
```

### Known Limitations (not blocking)

- `vpi_printf` output invisible in `-batch` mode — use file traces for diagnostics
- ISS executes ~131 extra instructions after exit device triggers
- `rvviRefCsrSet` is no-op (WP-3) — works because mtvec comes from config JSON
- `rvviRefNetSet` stores value but doesn't inject into GVSOC IRQ (WP-6)
