# Project Session State — sim-operator

**Date**: 2026-04-01 (continued from 2026-03-27)
**Session**: D41/D42/D43 bridge fixes validation (Baseline DPI regression)

## Current Work: D41/D42/D43 Baseline Regression

### Objective
Validate three new bridge fixes (D41, D42, D43) with comprehensive baseline DPI regression on 11 critical tests spanning three configurations: default (7 tests), pulp (1 test), pulp_fpu (3 tests).

### Test List (11 tests)
| # | Test | CFG | Status |
|---|------|-----|--------|
| 1 | hello-world | default | IN_PROGRESS |
| 2 | fibonacci | default | PENDING |
| 3 | dhrystone | default | PENDING |
| 4 | riscv_arithmetic_basic_test_0 | default | PENDING |
| 5 | riscv_arithmetic_basic_test_1 | default | PENDING |
| 6 | illegal_instr_test | default | PENDING |
| 7 | csr_instructions | default | PENDING |
| 8 | fibonacci | pulp | PENDING |
| 9 | csr_instructions | pulp_fpu | PENDING |
| 10 | cv32e40p_readonly_csr_access_test | pulp_fpu | PENDING |
| 11 | mhpmcounter29_csr_access_test_1 | pulp_fpu | PENDING |

### Execution Parameters
- **Command**: `make test TEST=<TEST> CFG=<CFG> USE_ISS=YES ISS=GVSOC COMP=NO`
- **Timeout per test**: 600 seconds
- **Expected completion time**: ~2026-04-01 12:50 UTC (approximately 2 hours from start 10:50 UTC)
- **Background task ID**: btp5vbct5
- **Output file**: `/tmp/claude-1036/-data-marco-paci-projects-core-v-verif/c3d3d9ac-4e84-47ea-ab1f-6e2f5c6dffde/tasks/btp5vbct5.output`

### Result Verification Method
1. For each test, grep the vsim log: `vsim_results/<CFG>/<TEST>/0/vsim-<TEST>.log`
2. Extract UVM_ERROR count: `grep "# UVM_ERROR :" <LOG> | tail -1 | awk '{print $NF}'`
3. Classification:
   - `UVM_ERROR = 0` → PASS
   - `UVM_ERROR > 0` → FAIL
   - Exit code 124 → TIMEOUT (600s)
   - No log file → INCOMPLETE

### Expected Results
All 11 tests EXPECTED TO PASS (0 UVM_ERROR) if D41/D42/D43 fixes are working correctly. Historical baseline (2026-03-26 post-D20/D21): hello-world, fibonacci, dhrystone, CSR tests, illegal_instr_test all PASS with 0 UVM_ERROR.

---

## Previous Session Summary (2026-03-27 and earlier)

### D20+D21 Fix Validation — COMPLETED
- **D20**: RVVI_PREMATURE_EXIT_DEADLOCK fix — eliminated 1h 49m hang on pulp_post_increment_load_store
- **D21**: mcountinhibit volatile handling — ensures counter-inhibit sync without stale cache
- **Result**: Both hello-world and pulp_post_increment_load_store PASS with 0 UVM_ERROR

### D16 Fix Validation — COMPLETED
- **D16**: void'(rvviRefEventStep) in illegal instruction trap path
- **Result**: illegal_instr_test PASS with 0 UVM_ERROR, zero CSR mismatches

### DPI Regression Summary (2026-03-27)
- **PASS**: 19/23 tests
- **SKIP**: 3 tests (firmware bugs, too large)
- **FAIL**: 4 tests (mostly 2cyclat config, 1 no_pulp)

### DPI Regressio Summary (2026-04-01 01:42 UTC)
- **PASS**: 31/40 directed tests
- **FAIL**: 9/40 (debug/interrupt tests — WONTFIX known timing issues)
- **NO_LOG**: 2/40 (pulp_fpu_zfinx config)

---

## Modified Files (Session 2026-04-01)
- `/tmp/dpi_baseline_regress.sh` — Baseline regression script (created in previous session, now executing)

## Key Artifacts
- **Regression script**: `/tmp/dpi_baseline_regress.sh`
- **Test directory**: `/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/`
- **Vsim results**: `vsim_results/<CFG>/<TEST>/0/`
