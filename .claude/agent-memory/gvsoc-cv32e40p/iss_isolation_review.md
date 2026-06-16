---
name: iss_isolation_review
description: ISS shared-file isolation review — CV32E40P contamination analysis, single genuine risk identified (2026-04-07)
type: project
---

# ISS Isolation Review — 2026-04-07

## Conclusion

CV32E40P modifications are properly isolated in 8 of 9 files reviewed. One genuine isolation risk identified.

## Single Genuine Isolation Risk

**File**: `gvsoc/core/models/cpu/iss/src/csr.cpp`, lines 101-108 (`Csr::build()`)

**Issue**: `mhpmcounter[i]` and `mcountinhibit` declared with `write_mask=0` in the BASE CLASS `Csr::build()`, not inside any `#ifdef CONFIG_GVSOC_ISS_CV32E40P` guard.

**Effect**: All cores using the base `Csr` class (PulpV2, GAP9) silently lose the ability to write these CSRs. Previously these had `mask=-1` (fully writable).

**CV32E40P**: unaffected — `Cv32e40pCsr::build_cv32e40p()` overrides with correct values.

**Fix tier**: `#ifdef CONFIG_GVSOC_ISS_CV32E40P` guard in `csr.cpp` to restore `mask=-1` as default for other cores (4-line change).

## Global-Correct Additions (safe, no action needed)

In `include/csr.hpp` (`CsrAbtractReg`):
- `write_illegal = false` — defaults off, harmless
- `set_write_mask()` / `write_mask` — only active if explicitly called
- `virtual mstatus_read_fixup() {}` — no-op for all non-CV32E40P cores

In `src/csr.cpp`:
- `mhartid` (0xF14) / `mimpid` (0xF13) silent write ignore — spec-correct (read-only per RISC-V priv spec §2.2)

## All Files — Status

| File | Risk | Action |
|------|------|--------|
| `src/exception.cpp` | BASSO — GATED | NONE |
| `include/csr.hpp` | MEDIO — global-correct | DOCUMENT |
| `include/cores/cv32e40p/csr.hpp` | NESSUNO — file-isolated | NONE |
| `include/isa/priv.hpp` | NESSUNO — upstream unchanged | NONE |
| `include/cores/cv32e40p/priv.hpp` | NESSUNO — file-isolated | NONE |
| `src/lsu.cpp` | NESSUNO — no CV32E40P changes | NONE |
| `src/csr.cpp` | MEDIO — 10 GATED + 1 global-specific | DOCUMENT + REFACTOR |
| `src/csr_cv32e40p.cpp` | NESSUNO — entire file gated | NONE |
| `pulp_cores.py` | BASSO — class hierarchy isolated | DOCUMENT |
