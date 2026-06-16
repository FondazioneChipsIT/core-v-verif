---
name: system_prompt_corrections
description: Two factual discrepancies between system prompt and actual pulp_cores.py — core name and IRQ file
type: project
---

# System Prompt Corrections (verified 2026-04-07 against pulp_cores.py)

## Correction 1: core= parameter

**System prompt says**: `core="cv32e40p"` → generates `CONFIG_GVSOC_ISS_CV32E40P=1` via `core.upper()`

**Actual code**: `core="riscv"` — CONFIG_GVSOC_ISS_CV32E40P is set MANUALLY via `add_c_flags(["-DCONFIG_GVSOC_ISS_CV32E40P=1"])`. It is NOT auto-generated from the core name.

**Why:** The GVSOC RiscvCommon base uses `core="riscv"` for the ISA decoder backend. The CV32E40P distinction is applied only via explicit compiler flag injection.

**How to apply:** When tracing how CONFIG_GVSOC_ISS_CV32E40P gets set, do not assume it comes from `core.upper()`. Look in the `add_c_flags` call in the `cv32e40p` class constructor body.

## Correction 2: IRQ file

**System prompt says**: `riscv_exceptions=True` → uses `irq_riscv.cpp`

**Actual code**: CV32E40P uses `irq_cv32e40p.cpp` (a dedicated IRQ implementation file), NOT `irq_riscv.cpp`.

**Why:** CV32E40P has a custom IRQ handling model (elw_irq_unstall, specific mip/mie behavior) that required a separate file rather than reusing the generic RISC-V IRQ file.

**How to apply:** When looking for CV32E40P IRQ behavior, search in `irq_cv32e40p.cpp`, not `irq_riscv.cpp`.
