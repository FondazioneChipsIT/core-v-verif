# CLAUDE.md

Guidance for Claude Code sessions working in this repository.

## What this repo is

Fork of `openhwgroup/core-v-verif` focused on CV32E40P functional verification
with **GVSOC as the RVVI reference model** (DPI co-simulation, step-and-compare).
The GVSOC bridge lives in `vendor_lib/gvsoc_rvvi/` (git submodule) and carries
its own documentation — that is the primary reference for the co-sim work.

## Read these first (submodule docs)

| Doc | Content |
|-----|---------|
| `vendor_lib/gvsoc_rvvi/docs/ARCHITECTURE.md` | Bridge lifecycle, retire-based stepping, RVVI conformance |
| `vendor_lib/gvsoc_rvvi/docs/GVSOC_ENGINE.md` | GVSOC engine/ISS internals, boot, integration levers |
| `vendor_lib/gvsoc_rvvi/docs/TESTING.md` | How to run tests, quick_val gate |
| `vendor_lib/gvsoc_rvvi/docs/RVVI_TEXT_TRACING.md` | RVVI text tracing (RTL-only / bridge-emit / dual-trace) |
| `vendor_lib/gvsoc_rvvi/docs/DEBUG_COSIM.md` | Debugging the co-sim (gdb attach via `GVSOC_RVVI_GDB_WAIT`, Questa C-debug findings) |

## Environment (shared server)

```bash
micromamba activate gvsoc_env_3_12          # before any Python/GVSOC work
export CV_SW_TOOLCHAIN=/opt/riscv/corev-openhw-gcc-modded-v0.1   # riscv64-unknown-elf-
export CV_SIMULATOR=vsim                    # Questa 2025.3 (/tools/siemens/questa_2025.3/questasim)
```

Never install packages system-wide; use micromamba environments.

## Simulation commands (run from `cv32e40p/sim/uvmt/`)

```bash
make comp                                            # compile testbench
make test TEST=hello-world                           # RTL only
make test TEST=hello-world USE_ISS=YES ISS=GVSOC     # co-sim step-and-compare
make test TEST=hello-world ISS=GVSOC_TRACE COMP=NO   # trace comparison (RTL vs GVSOC standalone)
make test TEST=... CFG=pulp                          # TB configs: pulp / pulp_fpu / pulp_fpu_zfinx
```

- The **iss_v2** reference core is the default (`GVSOC_ISS_V2 ?= YES` in
  `mk/Common.mk`); set `GVSOC_ISS_V2=NO` for the legacy v1 core.
- Gotcha: per-CFG TB objects are NOT interchangeable between RTL-only and
  co-sim runs — recompile when switching.

## GVSOC bridge (`vendor_lib/gvsoc_rvvi/`)

- Rebuild after ANY C++ change:
  `cd vendor_lib/gvsoc_rvvi && micromamba run -n gvsoc_env_3_12 make gvsoc && micromamba run -n gvsoc_env_3_12 make`
  Always let it rebuild **all** `.so` variants (v1/v2/zfinx share sources; a
  stale variant causes ABI skew and deadlocks at the first retire).
- Bridge C++: `rvvi_api2gvsoc.cpp` (RVVI API implementation, shared by all
  variants) + `gvsoc_engine_v2.cpp` (iss_v2 engine) / `gvsoc_engine.cpp` (v1).
- ISS models (sub-submodule `gvsoc/`): common core in
  `gvsoc/core/models/cpu/iss_v2/`, CV32E40P personality (CSR/IRQ/exceptions) in
  `gvsoc/pulp/pulp/cpu/iss_v2/cores/cv32e40p/`.
- Validation gate: `test/quick_val.sh <outdir>` — one run of every test type in
  each TB config. Read the SUMMARY only AFTER the `quick_val end:` line.
- Formatter/tracer unit tests: `make check-rvvi`.

## Git topology

- Super repo remote: `chipsit` (internal); upstream: `openhwgroup/core-v-verif`.
- `vendor_lib/gvsoc_rvvi` → `marpac3/gvsoc_rvvi`, branch `main`.
- Sub-submodules `gvsoc/`, `gvsoc/core`, `gvsoc/pulp` → FondazioneChipsIT forks,
  branches `mpaci/cv32e40p-*`.
- After cross-repo changes, commit innermost-first and bump the gitlinks up the
  chain: core/pulp → gvsoc → gvsoc_rvvi → super repo.

## Conventions

- Commit style: `<type>: <description>` (feat / fix / chore / docs / test), no
  AI attribution lines.
- Large artifacts (waveforms, regression logs, validation evidence) go OUTSIDE
  the repo (e.g. `/data2/<user>/validation-evidence/`), never committed.
- Trace files can exceed 100k lines — grep them, never read them whole.
