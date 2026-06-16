---
name: DPI Smoke Test Results 2026-03-30
description: hello-world, csr_instructions PASS; pulp_general_alu CSR[0x342/0x300/0x341] mismatch at retire 1194
type: project
---

## Smoke Test Execution Summary

Date: 2026-03-30, Time: 17:37-17:39

**Environment:** AlmaLinux, questa/2025.3, gvsoc_env_3_12, USE_ISS=YES ISS=GVSOC

### Test Results

| TEST | CFG | STATUS | RETIRES | MISMATCHES | DETAIL |
|------|-----|--------|---------|-----------|--------|
| hello-world | default | **PASS** | 10041 | 0 | PC/GPR comps 10039/10039, clean exit |
| csr_instructions | default | **PASS** | 6498 | 0 | MSTATUS R/W works correctly |
| pulp_general_alu | pulp | **FAIL** | 1194 | 17 RVVI errors | CSR divergence then PC cascades |

### Critical CSR Mismatch Pattern (pulp_general_alu @ retire #1194)

```
CSR[0x342] (mtval):   DUT=0x00000000 ISS=0x00000002
CSR[0x300] (mstatus): DUT=0x00001808 ISS=0x00001880  (MIE/MPIE bits differ)
CSR[0x341] (mepc):    DUT=0x00000000 ISS=0x00000d8a
```

Then immediate PC mismatch #1:
```
PC mismatch @ retire #1195: DUT=0x00000d8e ISS=0x00001854
```

### Root Cause Hypothesis (Revised)

**NOT** `undeclare_csr()` causing illegal exceptions. Instead:

1. **Exception/Trap Handling Desync** — When test firmware triggers trap (likely divide-by-zero, illegal instr, or alignment exception), RTL and ISS diverge in how they save exception state
2. **Specific CSRs Affected** — mepc (exception PC), mtval (trap value), mstatus (interrupt enable bits)
3. **Post-Stash D36 Integration** — Stash likely modified exception handling in GVSOC C++ code OR broke synchronization between CSR updates and trap handling

### Evidence Against Undeclare CSR Hypothesis

- hello-world and csr_instructions both PASS with 0 mismatches
- These tests execute CSR reads/writes (MSTATUS, etc.) successfully
- If undeclare_csr() caused illegal instruction exceptions, we'd see immediate trap/illegal behavior in all tests
- Instead, only exception-handling-heavy tests (pulp_general_alu, exception tests) fail

### Evidence FOR Exception/Trap Handling Desync

- Exact failure point: trap-related CSRs diverge (mepc, mtval, mstatus exception bits)
- Post-exception PC immediately diverges (CPU vs ISS follow different exception handlers)
- Pattern consistent across all "fail with 600s timeout" tests in regression (they all eventually hit exception scenarios)

### Next Diagnostic Steps

1. Examine which instruction in pulp_general_alu @ PC=0x00000d8a triggers trap
2. Check if GVSOC exception model was modified in D36 stash
3. Compare D36 changes against previous working version of exception handling in GVSOC

### Key Files to Analyze

- `/data/marco.paci/projects/core-v-verif/vendor_lib/gvsoc_rvvi/gvsoc/core/models/cpu/iss/src/csr_cv32e40p.cpp` — CSR handling
- `/data/marco.paci/projects/core-v-verif/vendor_lib/gvsoc_rvvi/gvsoc/core/models/cpu/iss/src/exec.cpp` — Exception trap handling
- D36 stash diff to identify which exception/trap logic changed

### Regresssion Implications

Pre-stash tests that PASS (hello-world, fibonacci, dhrystone, misalign, csr_instructions, csr_instr_asm) = simple arithmetic with NO exception scenarios

Post-stash tests that FAIL = Any test that encounters exception/trap scenario
- CSR access (readonly CSR raises illegal instr exception → trap)
- Performance counters (accessed via CSR)
- Exception/interrupt tests (intentionally trigger exceptions)
- PULP ALU (likely hitting exception during special operations)

### Correction Note

Previous hypothesis "undeclare_csr() removes 22 CSRs causing illegal instruction exceptions" was incorrect. The actual issue is **exception state synchronization** between RTL and ISS GVSOC post-D36 integration.
