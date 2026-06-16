---
name: BUG-29b Investigation State
description: State of BUG-29b investigation (hello-world/pulp DPI PC desync at retire #414)
type: project
---

## BUG-29b: hello-world/pulp DPI co-sim PC desync

**Symptom (from project_gvsoc_bugs.md)**: 3304 PC mismatches starting at retire #414.
DUT PC=0x176, ISS PC=0x16a. Trigger: `cv.beqimm x9,1,0x176` — branch taken in DUT (x9=1) but not in GVSOC (x9=0).

**Why:** Investigation was blocked: the vsim log on disk (Apr 7 09:07 run) shows a different failure — null foreign function pointer crash at retire #1 (`rvviDutGprSet`). This matches BUG-28 pattern (wrong testbench compilation), NOT the described retire #414 PC desync.

**How to apply:** The test must be re-run with `make test TEST=hello-world CFG=pulp USE_ISS=YES ISS=GVSOC COMP=NO` to reproduce the failure. The trace_core.log is empty (only header) — simulation exited before logging any instructions.

## Key findings so far

- `gvsoc_config_pulp.json`: `mstatus_write_mask=0x21888` (note 0x20000 = TW bit, suspicious for CV32E40P)
- `isa: "rv32imc"` — no PULP in ISA string, but `vp_component` uses cv32e40p core_v2 model with PULP built in
- `fpu_in_isa: false` — correct for pulp (no FPU)
- The Apr 1 regression CSV never ran hello-world/pulp; BUG-29b was observed in D49 review session

## Status

OPEN — investigation incomplete. Need fresh log reproducing retire #414 desync.
Re-run command: `make test TEST=hello-world CFG=pulp USE_ISS=YES ISS=GVSOC COMP=NO`
