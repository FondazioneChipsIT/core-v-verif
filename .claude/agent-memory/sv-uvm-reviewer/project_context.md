---
name: cv32e40p-svh-review-context
description: Key facts about the CV32E40P ISS-wrap SVH files reviewed for upstream PR quality
metadata:
  type: project
---

## Files

- `cv32e40p/tb/uvmt/uvmt_cv32e40p_iss_wrap_common.svh` — RVFI→RVVI wiring snippet-file
  included inside both gvsoc_wrap and imperas_wrap module bodies. Not a standalone module;
  slang errors on standalone lint are expected (missing `RVFI_IF`, `DUT_PATH` macros).
- `cv32e40p/tb/uvmt/uvmt_cv32e40p_csr_defs.svh` — CSR address defines only.
  Slang: clean 0 errors 0 warnings when linted standalone.

## RVVI_SET_TRAP_CSR pattern

The `ifndef RVVI_SET_TRAP_CSR` default (lines 16-18 of iss_wrap_common.svh) is the
SV-macro equivalent of a C++ virtual hook with a conservative default.
- GVSOC wrap defines it before `include → gets wdata-direct path (wmask=0 on trap writes).
- Imperas wrap does NOT define it → falls back to standard `RVVI_SET_CSR → inert.
- DO NOT change the logic of this ifndef block. Only comment may be edited.

## Defines in csr_defs that are defined but not wired in iss_wrap_common

Many defines exist (CSR_JVT, CSR_MCOUNTEREN, CSR_MENVCFG, CSR_MSTATEEN*, CSR_MTVT,
CSR_SMCLIC-family, CSR_TSELECT, CSR_TCONTROL, CSR_MCONTEXT, CSR_MSCONTEXT,
CSR_SCONTEXT, CSR_MCYCLE, CSR_CYCLE, CSR_CYCLEH, CSR_MIMPID, CSR_MCONFIGPTR,
CSR_CPUCTRL, CSR_SECURESEED*, CSR_MSECCFG*) that are NOT used in iss_wrap_common.
These are NOT dead code — they may be referenced by the gvsoc_wrap, imperas_wrap,
or other TB files. Do not remove them without a cross-file search.

## Why

**Why:** mstatus/mepc/mcause/mtval use RVVI_SET_TRAP_CSR instead of RVVI_SET_CSR
because on a trap-induced write the RTL hardware sets wmask=0 (the register is
written by the trap hardware, not by a CSR instruction). The standard RVVI_SET_CSR
formula uses wmask to gate the value; with wmask=0 it would always produce 0.
The trap-aware formula reads wdata directly instead.
