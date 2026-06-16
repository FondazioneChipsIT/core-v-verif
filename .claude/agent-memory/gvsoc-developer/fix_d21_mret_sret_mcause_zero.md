---
name: fix_d21_mret_sret_mcause_zero
description: D21: remove illegal mcause/scause zeroing in mret_handle/sret_handle in core.cpp
type: project
---

## Fix D21: mcause/scause not cleared by MRET/SRET

**File**: `vendor_lib/gvsoc_rvvi/gvsoc/core/models/cpu/iss/src/core.cpp`

**Root cause**: Two non-compliant assignments:
- Line 128 (before fix) in `mret_handle()`: `this->iss.csr.mcause.value = 0;`
- Line 148 (before fix) in `sret_handle()`: `this->iss.csr.scause.value = 0;`

**Why wrong**: RISC-V Privileged spec v1.13 — mcause/scause are written ONLY on trap entry. MRET/SRET only modify mstatus MIE/MPIE/MPP and restore pc from mepc/sepc. Zeroing cause registers on return causes mismatches when the same trap is triggered in a loop (e.g. illegal CSR access in mhpmcounter tests).

**Symptom**: `mhpmcounter29_csr_access_test_1/pulp_fpu` — illegal CSR access -> mcause=0x2, MRET executed, GVSOC mcause=0 vs RTL mcause=0x2.

**Fix applied**: Deleted both assignments completely (no ifdef guard needed — fix is spec-compliant for all RISC-V targets, not CV32E40P-specific).

**Commit**: `dcb6dcd1` in `gvsoc/core` submodule (branch `cv32e40p-standalone`)

**Why:** The standard says MRET/SRET are return-from-exception instructions. They restore privilege and enable interrupts — they have no architectural side-effect on cause CSRs.

**How to apply:** When adding new xRET handlers, never zero xCAUSE. Only trap entry (exception.cpp Exception::raise()) may write mcause/scause.
