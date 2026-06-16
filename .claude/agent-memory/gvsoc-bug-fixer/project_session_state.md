---
name: project_session_state
description: Stato granulare del lavoro in corso — aggiornato 2026-03-26 SESSION 4 (WP-9)
type: project
---

# Stato sessione — 2026-03-26 SESSION 4 (WP-9 fix applicato)

## Fix applicati

### COMPLETATI (fix applicato, verifica in corso)

**D20 (WP-9 — GVSOC premature exit pseudo-deadlock)**
- Root cause: BridgeUser::has_ended() sets g_finished=true but NOT g_running=false
  → gvsoc_engine_is_running() returns true → rvviRefEventStep keeps calling gvsoc_engine_step()
  → step returns 0 immediately (g_finished) but DUT keeps comparing against dead ISS
  → vpi_control(vpiFinish,0) doesn't stop Questa immediately → runs for hours (1h49m per 1000 retires)
- Fix 1: gvsoc_engine.cpp BridgeUser::has_ended(): added g_running=false after g_finished=true
- Fix 2: rvvi_bridge.cpp rvviRefEventStep(): added gvsoc_engine_shutdown() call + changed vpi_control(vpiFinish,0) → vpi_control(vpiFinish,1)
- Files modified:
  - vendor_lib/gvsoc_rvvi/gvsoc_engine.cpp (BridgeUser::has_ended, line ~80)
  - vendor_lib/gvsoc_rvvi/rvvi_bridge.cpp (rvviRefEventStep, line ~448)
- Rebuild: SUCCESS (both .o recompiled, libgvsoc_rvvi.so rebuilt)
- Verification: IN PROGRESS (background tasks bpj5dygjp + b24u5qaiv)
  - pulp_post_increment_load_store/pulp — expect FAST completion (<5min vs old 1h49m)
  - hello-world/default — baseline regression check

**D21 (mcause/scause azzeramento illegale su MRET/SRET)**
- Agent a475ae38811faf09b still running (last seen building OK at 17:09)
- Root cause: core.cpp lines 128/148 — mret_handle() clears mcause, sret_handle() clears scause
- Fix: remove those two lines
- Status: UNKNOWN (agent may have completed after context was cut)

## WP-9 Root Cause Summary

### Class 1: GVSOC premature exit (pulp_post_increment_load_store type) — FIXED by D20
- GVSOC runs speculatively ahead during DUT stall cycles
- Encounters PULP opcodes → may exit early via exit device (0x20000000)
- After D20: has_ended() sets g_running=false → rvviRefEventStep stubs immediately
- vpi_control(vpiFinish,1) terminates Questa promptly

### Class 2: Extremely slow (custom_opcode_illegal_test type) — SEPARATE ISSUE
- NOT a true deadlock — runs fully but takes ~2h
- 10 UVM_ERROR: mscratch mismatch (DUT=0x0, ISS=0x18364 at PC=0x1b00)
- Cause: dense trap loop + 2 log lines per trap × thousands of traps = slow
- Separate fix needed for CSR mismatch

## Test results expected after D20

| Test | CFG | Expected | Evidence |
|------|-----|----------|---------|
| hello-world | default | PASS (no regression) | baseline |
| pulp_post_increment_load_store | pulp | FAST + possible PASS/FAIL | step-ahead issue resolved |
| custom_opcode_illegal_test | pulp | FAIL (CSR mismatch) | different issue |

## Prossimi passi (dopo D20 verifica)

1. Check D21 status (mhpmcounter29 fix)
2. If D20 baseline OK: commit D20
3. Investigate custom_opcode_illegal_test mscratch mismatch
4. Run broader regression (5+ tests) to check D20 impact

## Sessioni precedenti

### Sessione 3 — 2026-03-26 17:52
- D20 attempt (mhpmcounter CSR write_illegal=true) — via sub-agent, status UNKNOWN
- D21 (mcause azzeramento) — agent a475ae38811faf09b still running

### Sessione 2 — 2026-03-26 15:15 (post-compaction)
- 21 PASS, 2 WONTFIX, 2 FAIL, ~10 DEADLOCK (WP-8)
- Fix D13-D18b aplicati

### Sessione 1 — 2026-03-26 12:58
- WP-8 regressione DPI baseline, 21 PASS
