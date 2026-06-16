---
name: gvsoc-sync-mode-pc-change-stepping
description: "GVSOC Api_mode_sync: usare PC-change detection per retire, NON instret (BUG-26: instret non auto-incrementa)"
user-invocable: false
origin: auto-extracted
---

# GVSOC Sync Mode: PC-Change Retire Detection

**Extracted:** 2026-03-24
**Updated:** 2026-03-24 — Corrected: instret does NOT work, use PC-change detection

## Problem

In `Api_mode_sync`, two approaches for retire detection DON'T work:

1. **VCD callbacks** — ring buffer has no consumer thread; callbacks registered but never invoked
2. **`csr.instret.value`** — does NOT auto-increment in GVSOC (BUG-26). It is a plain WARL register, not a hardware counter. Reading it always returns the software-written value.

## Solution

Monitor `exec.current_insn` (the PC) directly through the `IssWrapper*` pointer obtained via `get_component("soc/core")`:

```cpp
// Step until PC changes (= one instruction retired)
for (int i = 0; i < STEP_MAX_CYCLES && !g_finished; i++)
{
    iss_reg_t pre_pc = g_wrapper->iss.exec.current_insn;  // PC BEFORE step

    g_gvsoc->step(g_clock_ps);  // advance 1 clock cycle (20000 ps = 50 MHz)

    iss_reg_t post_pc = g_wrapper->iss.exec.current_insn;
    if (post_pc != pre_pc)
    {
        // Instruction at pre_pc has retired; post_pc is the next instruction
        g_retired_pc = pre_pc;
        g_step_count++;
        return 1;  // One instruction retired
    }
    // Else: pipeline stall, continue stepping
}
return 0;  // Timeout — no retire after STEP_MAX_CYCLES cycles
```

Key points:
- `exec.current_insn` = PC of the instruction being executed (read BEFORE step)
- When PC changes after `step()`, the instruction at `pre_pc` has retired
- `g_retired_pc` captures the retired instruction's PC (NOT `post_pc`)
- Access ONLY public struct members, NEVER call ISS methods (compiled in separate .so)
- Clock period: `g_clock_ps = 20000` (50 MHz = 20ns)
- Max iterations: ~2000 cycles to avoid infinite loops on stalls
- **DO NOT use `csr.instret.value`** — it does not auto-increment (BUG-26)

## When to Use

- Co-simulation GVSOC in-process (`gv::Gvsoc`, `Api_mode_sync`)
- Any scenario requiring instruction retire detection without VCD
- DPI bridge for cycle-accurate RTL vs ISS comparison (step-n-compare)
