---
name: cv32e40p-clean branch analysis
description: Structural analysis of cv32e40p-clean branch (10 commits, API refactor, WP-C removal)
type: project
---

## Branch Overview

- **Branch**: `cv32e40p-clean` (local in gvsoc/core)
- **Current HEAD** (2026-04-01): `866ff31f` (master-equivalent)
- **Branch HEAD**: `32b2e28e` (10 commits ahead)
- **Status**: NOT CHECKED OUT. Analysis only via git commands.

## Key Structural Changes

### 1. CSR API Refactor (BREAKING CHANGE)

**Signature change:**
```cpp
// Before (HEAD):
bool iss_csr_read(Iss *iss, iss_reg_t reg, iss_reg_t *value)
bool iss_csr_write(Iss *iss, iss_reg_t reg, iss_reg_t value)

// After (cv32e40p-clean):
bool iss_csr_read(Iss *iss, iss_insn_t *insn, iss_reg_t reg, iss_reg_t *value)
bool iss_csr_write(Iss *iss, iss_insn_t *insn, iss_reg_t reg, iss_reg_t value)
```

**Affected files:**
- `models/cpu/iss/src/csr.cpp` — function definition (215++++/--------)
- `models/cpu/iss/src/csr_cv32e40p.cpp` — CV32E40P subclass (83++++/--------)
- `models/cpu/iss/include/cores/cv32e40p/priv.hpp` — all csrrx handlers (+24 lines to add `insn` param)
- `models/cpu/iss/include/isa/*.hpp` — all cores' CSR handlers updated

**Why:** Likely to support instruction-level logging/tracing in future. Insn pointer allows CSR handlers to access instruction context (opcode, source registers, etc.).

### 2. WP-C Removal (Pre-fetch IRQ Check)

**Removed from** `models/cpu/iss/src/exec/exec_inorder.cpp`:
```cpp
// REMOVED from exec_instr() fast path:
#ifdef CONFIG_GVSOC_ISS_CV32E40P
    if (iss->irq.check()) {
        return;  // Pre-fetch IRQ check on fast path
    }
#endif

// REMOVED from exec_instr_check_all() pre-fetch:
#ifdef CONFIG_GVSOC_ISS_CV32E40P
    if (_this->iss.irq.check()) {
        return;  // Pre-fetch check before fetching next instruction
    }
#else
    _this->iss.irq.check();
#endif
```

**Impact:**
- IRQ timing reverts to "post-execute" (after instruction completes)
- No pre-emptive interrupt fetch on fast path or slow path
- Tests expecting pre-fetch behavior (mepc capture timing) will diverge from RTL

### 3. CV32E40P CSR Subclass Refactor

**File:** `models/cpu/iss/include/cores/cv32e40p/csr.hpp`

Changes:
- Added `void build_cv32e40p()` method (called from `Csr::build()`)
- Methods marked `override` explicitly
- `CsrReg tinfo` no longer declared inline in header
- Constructor simplified (all setup deferred to `build()`)

**File:** `models/cpu/iss/src/csr_cv32e40p.cpp`

New logic in `build_cv32e40p()`:
- Undeclares CSRs not in CV32E40P (S-mode, U-mode, NMI, Vector)
- Declares `tinfo` register (0x7A4, value=0x4)
- Sets write masks from config or RTL defaults
- Handles FPU feature gating (mstatus FS field)

### 4. Build System & Ancillary Changes

**Large additions:**
- `rv32v_timed.hpp`: +2284 lines (vector ISA, likely PulpV2-specific)
- `rv32Xfaux.hpp`, `rv32Xfvec.hpp`: +6 lines each
- `engine/include/vp/stats/stats*.hpp` — new stats infrastructure
- `engine/src/stats.cpp` — +326 lines

**Build files:**
- `CMakeLists.txt`: +21 lines (new modules)
- `cmake/vp_model.cmake`: -4 lines (simplified rules)

## File Inventory

### CV32E40P Files Present in Branch

All key files exist:
```
✓ models/cpu/iss/include/cores/cv32e40p/class.hpp
✓ models/cpu/iss/include/cores/cv32e40p/csr.hpp
✓ models/cpu/iss/include/cores/cv32e40p/priv.hpp
✓ models/cpu/iss/include/cores/cv32e40p/regfile.hpp
✓ models/cpu/iss/include/cores/cv32e40p/__init__.py
```

### Files Changed (Relative to HEAD)

| File | Status | Lines |
|------|--------|-------|
| `csr.cpp` | Modified | 215+++ / ------- |
| `csr_cv32e40p.cpp` | Modified | 83+++ / ------- |
| `csr.hpp` | Modified | +12 |
| `priv.hpp` (CV32E40P) | Modified | +24 |
| `regfile.hpp` | Modified | +10 |
| `exec_inorder.cpp` | Modified | -24 (WP-C removal) |
| `corev.hpp` | Modified | +65 |
| `class.hpp` | New | +1 |

## Compilation Risks

### Risk 1: API Compatibility
- **Severity**: HIGH
- **Test**: Ensure all call sites of `iss_csr_read/write` updated
- **Mitigation**: Branch appears to have done this systematically

### Risk 2: WP-C Removal
- **Severity**: MEDIUM (functional impact, not build)
- **Test**: IRQ timing tests will diverge from RTL
- **Mitigation**: Expected behavior in clean branch; revert if needed

### Risk 3: Vector ISA Integration
- **Severity**: LOW (likely opt-in via #ifdef)
- **Test**: Verify it doesn't affect CV32E40P compilation
- **Mitigation**: Check rv32v_timed.hpp for PulpV2-only guards

### Risk 4: Stats/Clock Engine Integration
- **Severity**: LOW
- **Test**: Linker may fail if symbols not properly exported
- **Mitigation**: Inspect CMakeLists.txt for link rules

## Next Steps (for user)

1. **Safe analysis**: Already done via git (no checkout needed)
2. **Compile test**: Temporary checkout or separate branch
3. **Baseline test**: Run `make gvsoc` and `make test TEST=hello-world CFG=default ISS=GVSOC COMP=NO`
4. **Compare**: Results vs HEAD
5. **Decision**: Rebase, merge, or keep as reference

## Notes

- **Why branch exists**: Likely alternative integration path that eliminates WP-C (IRQ pre-fetch timing fix)
- **API design philosophy**: Adding `insn` parameter enables future instruction-level CSR logging (useful for formal verification or advanced debugging)
- **Branch age**: Recent (commits dated around session start, likely created this week)
- **Status**: Appears complete and self-consistent (all handlers updated together)

---
**Last updated**: 2026-04-01 (analysis only, no modifications made)
