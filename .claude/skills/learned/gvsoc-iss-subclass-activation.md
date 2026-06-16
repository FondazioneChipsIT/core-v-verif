---
name: gvsoc-iss-subclass-activation
description: "5-file sequence to activate a core-specific ISS CSR subclass in GVSOC build"
user-invocable: false
origin: auto-extracted
---

# GVSOC ISS Core-Specific Subclass Activation

**Extracted:** 2026-03-27
**Context:** When adding a new core-specific CSR subclass to GVSOC ISS

## Problem
GVSOC ISS has a base `Csr` class shared across all cores. Core-specific behavior
(CV32E40P write masks, reset values, non-existent CSR removal) was previously
done via `#ifdef` blocks in the shared `csr.cpp`. The correct approach is a
dedicated subclass, but activating it requires coordinated changes across 5 files.

## Solution

1. **CMakeLists.txt** — Add the subclass .cpp to ISS_FILES:
   `"${F_GVSOC_ISS_DIR}/src/csr_cv32e40p.cpp"`

2. **cores/<core>/class.hpp** — Change include and member type:
   ```cpp
   #include <cpu/iss/include/cores/cv32e40p/csr.hpp>  // not base csr.hpp
   Cv32e40pCsr csr;  // not Csr csr;
   ```

3. **cores/<core>/csr.hpp** — Declare subclass. Note: base Csr methods are NOT virtual,
   so don't use `override`. Access callbacks use function pointers, not vtable.

4. **include/csr.hpp** (base) — Add public API for subclass access:
   - `set_write_mask(mask)` — write_mask is protected in CsrAbtractReg
   - `undeclare_csr(addr)` — regs map is private in Csr

5. **Python config** (`pulp_cores.py`) — Add all CSR parameters the subclass reads
   via `cfg->get_child_int()`. Missing keys return 0, so use `cfg_int_or()` fallback.

## When to Use
- Adding a new core target to GVSOC with core-specific CSR behavior
- Moving #ifdef blocks from shared csr.cpp into a dedicated subclass
