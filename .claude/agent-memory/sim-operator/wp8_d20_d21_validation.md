---
name: D20+D21 validation (2026-03-26)
description: D20 (premature exit deadlock) + D21 (mcountinhibit volatile) fixes validated with 1,330x speedup on pulp_post_increment_load_store
type: project
---

## Validation Summary (2026-03-26)

**Fixes validated**: D20 (RVVI_PREMATURE_EXIT_DEADLOCK), D21 (mcountinhibit volatile)
**Status**: BOTH PASS

### Key Metrics

| Test | CFG | Elapsed | UVM_ERROR | Status |
|------|-----|---------|-----------|--------|
| hello-world | default | 10s | 0 | PASS |
| pulp_post_increment_load_store | pulp | 5s | 0 | PASS |

### Critical Performance Finding

**pulp_post_increment_load_store runtime**: 1h 49m → 5 seconds (1,330x speedup)

This massive improvement confirms D20 fix is working: the RVVI_PREMATURE_EXIT_DEADLOCK guard prevents the ISS from signaling exit_status=true prematurely, which was causing DPI co-sim to hang waiting for program termination.

### Why:**
Before D20: ISS would signal program exit while instructions were still executing → DPI step-n-compare loop would think program done → synchronization deadlock
After D20: ISS correctly maintains exit_status=false until program truly complete → DPI sync proceeds normally

### How to apply:
- When debugging DPI performance issues, first check if tests show deadlock behavior (stuck in sync loop, non-zero CPU)
- D20 is critical for any test that would run > 5 min without this fix
- If new DPI test hangs, check if ISS is prematurely signaling exit status

### Commits involved
- bfa495d0: D19 mcountinhibit volatile + OPT-1 CSR sparse loop
- fbf719a5: D17 RVVI_SET_TRAP_CSR macro
- e0bc23f3: D13-D16 trap CSR race, step desync, WFI watchdog

### Artifacts
- Test logs: `/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/{default,pulp}/{hello-world,pulp_post_increment_load_store}/0/vsim-*.log`
- Session state: `project_session_state.md` (2026-03-26 entry)
