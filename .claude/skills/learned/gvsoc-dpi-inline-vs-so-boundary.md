---
name: gvsoc-dpi-inline-vs-so-boundary
description: "Access ISS state from DPI bridge via inline functions; avoid .so method calls at link boundary"
user-invocable: false
origin: auto-extracted
---

# GVSOC DPI: Inline vs .so Boundary for ISS State Access

**Extracted:** 2026-04-01
**Context:** When gvsoc_engine.cpp needs to read ISS internal state that requires method calls

## Problem

`gvsoc_engine.cpp` (compiled into `libgvsoc_rvvi.so`) cannot call ISS methods like
`insn_cache.get_insn_from_cache()` because those are compiled into model `.so` files
loaded dynamically by GVSOC — they're not available at DPI link time.

However, some ISS methods have **inline definitions in headers** with a fast-path
that only accesses struct members (no .so call) and a slow-path that calls .so methods.

## Solution

**Pattern: Use inline functions when the fast-path is guaranteed.**

Example: `InsnCache::get_insn()` (insn_cache.hpp):
- Fast-path (cache hit): `index < INSN_PAGE_SIZE` → direct struct access ✓
- Slow-path (cache miss): calls `get_insn_from_cache()` → in .so, will crash ✗

**Key insight**: Capture the data at the moment when the fast-path is guaranteed.
For instruction opcode, this means reading the insn cache BEFORE stepping — the
instruction about to retire is always in the current cache page.

```cpp
// BEFORE step — instruction at pre_pc is in cache (guaranteed fast-path)
iss_reg_t cache_idx = 0;
iss_insn_t *insn = g_wrapper->iss.insn_cache.get_insn(pre_pc, cache_idx);
uint32_t opcode = insn ? (uint32_t)insn->opcode : 0;

// Step (may change cache page)
g_gvsoc->step(g_clock_ps);

// AFTER step — insn at pre_pc may no longer be in cache (unsafe)
```

**Safe state access hierarchy:**
1. Public struct members (always safe): `iss.regfile.regs[]`, `iss.csr.mstatus.value`
2. Inline functions with guaranteed fast-path (safe when timed correctly): `insn_cache.get_insn()`
3. Virtual/non-inline methods (NEVER safe from DPI): `get_insn_from_cache()`, `access()`

## When to Use

- Adding new ISS state readback to `gvsoc_engine.cpp`
- Any new `gvsoc_engine_get_*()` function that needs more than a struct member
- When tempted to call an ISS method — check if it's inline with a struct-only fast-path
