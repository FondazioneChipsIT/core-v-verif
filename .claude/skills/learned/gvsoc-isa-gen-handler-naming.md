---
name: gvsoc-isa-gen-handler-naming
description: "GVSOC ISA gen: L= controls trace label only, handler name = Instr label.replace('.','_') + '_exec'"
user-invocable: false
origin: auto-extracted
---

# GVSOC ISA Generator Handler Naming Convention

**Extracted:** 2026-04-01
**Context:** When investigating missing handlers or adding new instructions to GVSOC ISA models

## Problem
The GVSOC ISA generator `Instr()` class accepts an `L=` parameter that appears to control handler naming. This leads to the false assumption that `Instr('LB_POSTINC', ..., L='cv.lb')` generates a handler named `cv_lb_exec`. In reality, `L=` only sets the disassembly trace label.

## Solution
From `isa_gen.py:855-863`:
```python
if L != None:
    self.trace_label = L      # L= -> trace label ONLY
else:
    self.trace_label = label
self.name = label.replace('.', '_')   # handler base = instruction label
self.set_exec_label(self.name)        # handler = name + '_exec'
```

**Rules:**
- Handler name = first parameter of `Instr()` with `.` replaced by `_`, + `_exec`
- `L=` parameter only affects disassembly output (trace label)
- Multiple instructions with same `L=` have DIFFERENT handlers (one per instruction name)

**Examples:**
| Instr() call | Handler name | Trace label |
|---|---|---|
| `Instr('LB_POSTINC', ..., L='cv.lb')` | `LB_POSTINC_exec` | `cv.lb` |
| `Instr('lp.endi', ..., L='cv.endi')` | `lp_endi_exec` | `cv.endi` |
| `Instr('cv.starti', ...)` | `cv_starti_exec` | `cv.starti` |

## When to Use
- When adding new instructions to `isa_cv32e40pv2.py` or any ISA gen file
- When debugging "undefined symbol" errors for handler functions
- When investigating which handler a decoded instruction dispatches to
- When an agent claims handlers are "missing" based on L= values
