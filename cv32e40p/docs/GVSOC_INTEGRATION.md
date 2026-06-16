# CV32E40P GVSOC ISS Integration

This branch adds **GVSOC** as an open-source ISS reference model for CV32E40P
co-simulation, alongside the existing Imperas OVPSIM path. It is the
testbench-side counterpart of the upstream GVSOC PRs gvsoc-core#146,
gvsoc-pulp#74 and gvsoc#252.

## What this adds

- A DPI step-and-compare bridge (`uvma_rvvi_sync_bridge`) driving GVSOC over the
  standard RVVI interface, selected with `ISS=GVSOC`.
- A GVSOC reference-model wrap (`uvmt_cv32e40p_gvsoc_wrap`) built on the
  RVFI→RVVI wiring shared, unchanged in behaviour, with the Imperas wrap.
- Build/run integration (`USE_ISS=YES ISS=GVSOC`).
- The `gvsoc_rvvi` bridge as a submodule (embeds GVSOC, exposes it via the RVVI
  DPI API).

The Imperas path is untouched: it remains the default reference model
(`ISS ?= IMPERAS`); shared files change shape only behind `ifndef`-guarded macro
defaults, and the GVSOC-specific code is selected with `USE_GVSOC`.

## Status (verified) — read the framing, not just the number

| What | Result |
|------|--------|
| GVSOC FAST2 `no_pulp` DPI co-sim (last full run 2026-05-20) | **644/651 PASS (98.92%)**, **99.69% ISS-attributable** |
| Suite scope | FAST2 = **25 tests**; full `no_pulp` (Imperas) = **43 tests** |
| Cross-target build (all other GVSOC cores) | **GREEN** (287 `.so`) |
| Frozen revision point-validation (2026-06-12) | 14-test targeted + 4-config smoke, all PASS |

**Important honesty note.** The 644/651 is measured on **FAST2**, which
deliberately excludes **18 debug/interrupt/ebreak/illegal-instr tests** that the
full `no_pulp` suite Imperas runs keeps active (excluded *for GVSOC* —
DPI co-sim trap/timing divergences). And "Imperas = 100%" is
golden-by-definition (Imperas *is* the reference model), not a measured
baseline — the official Imperas counts are produced on an external Metrics
cloud, not in this repo.

So the gap to full **`no_pulp`-suite** parity is three-part:

1. **1 genuine ISS divergence** — `generic_exception_test` (`mepc`).
2. **5 DPI-bridge deadlocks** — the GVSOC bridge has no reconverge-on-mismatch
   (Imperas does); a testbench-infrastructure gap, not an ISS error.
3. **18 debug/interrupt tests** excluded from FAST2 — `no_pulp` full-suite parity
   requires bringing these back (fix or formally document).

And `no_pulp` itself is only a **bring-up scaffold**: the OpenHW v1.8.3 sign-off
runs no non-PULP config. The real OVPSIM replacement is the PULP simulation
regression — XPULP + FPU + interrupt/debug on `{CFG_P, CFG_P_F0, CFG_P_Z0}` — as
classified in the report §3.6-3.7 and sequenced in the roadmap. None of this is a
regression of the existing Imperas flow, which is unchanged.

## Where the detail lives

- **`gvsoc_vs_imperas_final_report.md`** — full GVSOC-vs-OVPSIM evaluation: what
  "Imperas baseline" means, the FAST2-vs-full suite asymmetry, the apples-to-
  apples analysis, per-failure classification, data provenance, and (§3.6-3.7)
  **how OpenHW actually runs the v1.8.3 regression** plus the migration-scope
  classification (what GVSOC must run vs what stays with the RTL/formal sign-off).
- **`gvsoc_migration_roadmap.md`** — the exact roadmap to complete the
  OVPSIM→GVSOC migration: the three parity tiers, the in-scope/out-of-scope
  classification, seven sprints (0-6), effort estimates, and the definition of
  "done".

## Open items before opening the upstream PR

1. The three ISS PRs (gvsoc-core#146 / gvsoc-pulp#74 / gvsoc#252) must land
   first — the bridge will not build from a clean clone until they do.
2. `gvsoc_rvvi` must be made public (the submodule points at it).
3. A fresh full FAST2 regression on the exact frozen ISS revision is the
   validation gate (roadmap Sprint 0).
