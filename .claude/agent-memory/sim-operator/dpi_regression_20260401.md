---
name: DPI Regression 2026-04-01
description: Regressione DPI completa 2026-04-01 — 31/40 PASS, baseline stabile
type: project
---

## Risultati

| CFG | PASS | FAIL | TIMEOUT | NO_LOG | Rate |
|-----|------|------|---------|--------|------|
| default | 21 | 7 | 0 | 0 | 75% |
| pulp | 7 | 0 | 0 | 0 | 100% |
| pulp_fpu | 3 | 0 | 0 | 0 | 100% |
| pulp_fpu_zfinx | 0 | 0 | 0 | 2 | N/A (NO_LOG) |
| **TOTALE** | **31** | **7** | **2** | **2** | **77.5%** |

## Note

- **Baseline valid: 31/38 PASS (81.6%)** escludendo pulp_fpu_zfinx (config non compilata)
- **Stabilità confermata**: identico a 2026-03-28 (21/28 default, 7/7 pulp, 3/3 fpu)
- **WONTFIX noti (7)**: IRQ timing (branch_zero, interrupt_*), debug timing (debug_test*, generic_exception_test)
- **pulp_fpu_zfinx issue**: vmap-19 "Failed to access library 'work'" — testbench non compilato per questa config
  - **Azione**: `make comp CFG=pulp_fpu_zfinx` oppure togliere righe 99-102 da gvsoc_regression.sh

## Dettagli fallimenti default

1. generic_exception_test (16s) — require external interrupt stimulus
2. branch_zero (601s TIMEOUT) — IRQ timing desync GVSOC-post vs RTL-live
3. debug_test (45s) — debug mechanism timing incomplete
4. debug_test_trigger (10s) — debug trigger timing
5. debug_test_boot_set (7s) — debug boot set timing
6. interrupt_bootstrap (600s TIMEOUT) — IRQ timing
7. interrupt_test (600s TIMEOUT) — IRQ timing

## File risultati

- CSV: `/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/gvsoc_regression_results_20260401_014239.csv`
- Report: `/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/REGRESSION_REPORT_20260401.txt`

## Timeline

- T+0: regressione lanciata
- T+10min: 13/40 test PASS (CFG=default primis)
- T+20min: 14/40 test PASS (generic_exception_test FAIL)
- T+30min: 32 righe CSV (test CFG=default quasi completi)
- T+50min: completato CFG=default, inizio PULP
- T+60min: completato PULP (7/7 PASS)
- T+65min: completato FPU (3/3 PASS)
- T+70min: NON_LOG ZFINX (2/2)
- **Totale runtime: ~70 minuti**

## Why

Regressione su DPI (ISS=GVSOC) con timeout 600s per test, 40 test totali su 4 config. Usato script gvsoc_regression.sh. Baseline è stabilizzato a 31/38 test validi; i 7 fallimenti sono dovuti a limite architetturale (IRQ timing desync GVSOC-post vs RTL-live). ZFINX è un problema di compilazione, non di ISS.

## How to apply

- Considerare baseline DPI stabile a **81.6%** (31/38 test)
- WONTFIX definitivi per IRQ + debug: non perseguire ulteriormente senza architettura
- Se future regressione cala sotto 81%, investigare con trace-analyzer (not agenti precedenti)
