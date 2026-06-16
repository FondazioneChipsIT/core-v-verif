# CLAUDE.md

Functional verification for CORE-V RISC-V cores (CV32E40P). Shared infra in `lib/`, `mk/`, `vendor_lib/`.

## Simulation Commands (from `cv32e40p/sim/uvmt/`)

```bash
make comp                                              # Compile testbench
make test TEST=hello-world                             # Run test
make test TEST=<t> USE_ISS=YES ISS=GVSOC              # DPI co-simulation
make test TEST=<t> ISS=GVSOC_TRACE COMP=NO            # Trace comparison (no USE_ISS)
make test TEST=<t> COMP=NO                             # Skip recompile
```

**Env**: `CV_SIMULATOR=vsim`, `QUESTA_HOME=/tools/siemens/questa_2025.3/questasim`, `CV_SW_TOOLCHAIN=/opt/riscv/corev-openhw-gcc-modded/`, `CV_SW_PREFIX=riscv64-unknown-elf-`.

**Prereq**: `module load questa/2025.3` (setta `SALT_LICENSE_SERVER`) prima di ogni `make comp/test` — su shell fresh `vsim` fallisce con "Invalid license environment".

## ISS Modes

- **ISS=GVSOC_TRACE**: RTL-only sim → standalone GVSOC → `compare_traces.py`. 31/31 PASS (via `run_gvsoc_trace_regress.sh`).
- **ISS=GVSOC**: DPI co-sim via `libgvsoc_rvvi.so`, step-n-compare. Due metriche **distinte** (assi diversi):
    - DPI multi-config (10 cfg, test×cfg): **135/146 (92.5%)**
    - FAST2 `no_pulp` (test×seed, 2026-05-20): **644/651 (98.92%)**; ISS-attributable **649/651 (99.69%)**
  Known-limitation buckets + storico fix (D48/D49…): `cv32e40p/docs/gvsoc_vs_imperas_final_report.md`.
- **No ISS**: `USE_ISS=NO`.

## GVSOC Build (from `vendor_lib/gvsoc_rvvi/`)

```bash
micromamba run -n gvsoc_env_3_12 make gvsoc            # Compile GVSOC
micromamba run -n gvsoc_env_3_12 make                   # Compile libgvsoc_rvvi.so
```

## Key Files

| File | Purpose |
|------|---------|
| `vendor_lib/gvsoc_rvvi/rvvi_api2gvsoc.cpp` | DPI bridge (RVVI API for GVSOC) |
| `vendor_lib/gvsoc_rvvi/gvsoc_engine.cpp` | Embedded GVSOC engine |
| `vendor_lib/gvsoc_rvvi/rvvi_trace2api.sv` | SV-side DPI step-n-compare |
| `cv32e40p/tb/uvmt/uvmt_cv32e40p_gvsoc_wrap.sv` | GVSOC wrap module (FPU/ZFINX params, D49) |
| `cv32e40p/tb/uvmt/uvmt_cv32e40p_iss_wrap_common.svh` | Shared RVFI→RVVI wiring (GVSOC + Imperas) |
| `bin/compare_traces.py` | Trace comparison tool |

## Memory Map

RAM: 0x00000000 (4MB) | Entry: 0x80 | STDOUT: 0x10000000 | EXIT: 0x20000000

## Key Compile Defines

`CV32E40P_RVFI`, `CV32E40P_RVVI`, `USE_ISS`, `USE_GVSOC`, `CV32E40P_TRACE_EXECUTION`, `NO_PULP`/`PULP`/`FPU`.

## Coding Style

[OpenHW SV/UVM style](https://github.com/openhwgroup/core-v-verif/blob/cv32e40p_v1.8.3/docs/CodingStyleGuidelines.md). `_c` suffix for classes, `_pkg` for packages.

## Agentic Workflow

Fully agentic. MAI fare lavoro che un agente può fare. Dispatch rules: `~/.claude/rules/common/dispatch-rules.md`.

**Retrieval (post-MCP, 2026-06-25)**: i 3 server MCP KB sono **DISBANDATI** (vedi `~/.claude/rules/common/mcp-retrieval.md`). Ora:
- **Codice** (simboli/stringhe/segnali) → `ripgrep`/grep + `ctags`.
- **Prosa** (KB, bug DB, mappa CSR, doc GVSOC) → `cvv-kb search "<query>"` (SQLite FTS5 daemonless; `cvv-kb reindex` dopo modifiche al KB).
- **Memoria** → `MEMORY.md` + `memory/*.md`. **Spec** → `Read` del PDF mirato.

**Studio repo**: PRIMA di implementare/spiegare, `cvv-kb search` (prosa) + grep/ctags (codice). MAI implementare senza contesto.

**Flusso PR (post-Forgejo)**: diretto `local → fork GitHub → PR upstream`. Gate di review = `/code-review` prima dei push su branch e delle PR (Forgejo disbandato). Test/regressioni lunghi → in background (Bash `run_in_background` / `claude --bg`): sopravvivono a `/compact`.

**10 agenti CV32E40P**: sim-operator, trace-analyzer, gvsoc-developer, gvsoc-debugger, cv32e40p-rtl-expert, test-generator, gvsoc-regression-orchestrator (parallel Phase 0/1/2), gvsoc-parallel-runner, gvsoc-worker, gvsoc-cv32e40p.

**Regressione**: `gvsoc-regression-orchestrator` usa dispatch parallelo (batch=4 runner haiku). Phase 0: compile. Phase 1: parallel test. Phase 2: sequential fix loop solo sui FAIL.

**Review automatica**: dopo OGNI implementazione, lanciare reviewer (python-reviewer, code-reviewer, sv-uvm-reviewer).

Memory: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/MEMORY.md`.
