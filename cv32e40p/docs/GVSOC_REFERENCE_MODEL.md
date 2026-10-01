# GVSOC reference model

The UVM testbench of the CV32E40P can use the CV32E40P model of [GVSOC](https://github.com/gvsoc/gvsoc) as its
reference model, in place of ImperasDV. The model runs inside the simulator, driven through the RVVI API by the
[gvsoc_rvvi](https://github.com/marpac3/gvsoc_rvvi) bridge: after each instruction that the RTL retires, the model
executes its next instruction and the bridge compares the two states.

With `USE_ISS` and `USE_GVSOC` defined, `uvmt_cv32e40p_tb.sv` instantiates `uvmt_cv32e40p_gvsoc_wrap` (`gvsoc_dv`) in
place of `uvmt_cv32e40p_imperas_dv_wrap`, and calls its `ref_init`.
`cv32e40p/tb/uvmt/gvsoc.flist` lists the files to compile: the SystemVerilog side of the bridge
(`${GVSOC_BRIDGE_HOME}/sv/gvsoc_rvvi.f`), the decision monitor and the wrapper.

## The wrapper

`uvmt_cv32e40p_gvsoc_wrap.sv` drives the RVVI trace from RVFI, where the core reports each instruction it retires, and
instantiates `rvvi_trace2api` of the bridge, which steps the model on each retired instruction and runs the
comparisons. For each instruction it takes from RVFI:

- `valid`, `order`, `insn`, `trap`, `intr`, `mode`, `debug_mode`, `ixl` and `pc_rdata`;
- the value of each CSR, `(wdata & wmask) | (rdata & ~wmask)`. The tracer reports what a trap writes to `mepc`,
  `mcause`, `mtval` and parts of `mstatus` with wmask 0 and the new value in wdata, so for those bits the wrapper
  takes wdata. The `csr_wb` bit of a CSR is set while its value is new, and at the start, so that the first
  instruction reports every CSR;
- the GPRs and FPRs written by the instruction, up to two of each.

The wrapper also reports to the bridge each write accepted on the data bus (`rvviDutBusWrite`), and the bridge
compares them in order with the stores of the model. At the end of the test the testbench counts the mismatches as
errors, as with ImperasDV, and the errors of the bridge outside the comparisons (`RVVI_METRIC_ERRORS`), such as a
CSR write that the model refused.

`ref_init` loads the ELF of the test (`+elf_file`) in the model, then:

- declares volatile the CSRs that depend on timing, `cycle(h)`, `mcycle(h)`, `mip`, `mhpmcounter(h)3..31` and
  `hpmcounter(h)3..31`, and the loads from the random number generator and the cycle counter of the testbench
  (`0x15001000`-`0x15001007`): an instruction that reads one gets the value that the RTL read;
- enables the comparison of the other CSRs that RVFI reports, `mhpmevent3..31` included, and of `fflags`, `frm` and
  `fcsr` with the FPU;
- sets `mtvec`, which at reset comes from the `mtvec_addr_i` input of the core, from the `+mtvec_addr` plusarg.

## The decision monitor

The model takes interrupts and debug requests by itself, at the same points as the RTL controller.
`uvmt_cv32e40p_gvsoc_decision_monitor.sv` gives it what it needs through the decision-point extension of the RVVI API
of the bridge, and never what the RTL decided. At each edge of the free-running clock of the core it reports:

- `irq_i`, masked with the interrupts of the core, and `debug_req_i`, when they change (`rvviRefNetSet`);
- the decision point of the cycle that just ended, from the state of the controller: `BOOT_SET`, `FIRST_FETCH`,
  `SLEEP`, `FLUSH_WB` with a `wfi`, `DECODE` with a valid instruction and no taken branch, bus error or failed fetch,
  and `DECODE_HWLOOP` with a valid instruction (`rvviRefDecisionPoint`);
- the copies of the pins that the RTL makes at this edge (`rvviRefNetGroupSample`): `irq_i` into `irq_q` when the
  gated clock of the core runs, `debug_req_i` into `debug_req_q` on the free-running clock. The model makes the same
  copies, so that it decides on the same values as the RTL.

Each decision point carries the number of the next instruction to leave ID, counted by the monitor, and the model
applies it before the instruction that RVFI retires with that number (`order`). This works only if RVFI retires the
instructions in the order they leave ID: at each instruction that RVFI retires the monitor checks its `order` and
`pc`, and stops the test with a FATAL if it is not the oldest instruction that left ID and has not retired yet.

## Build configurations

The `gvsoc` tag of a configuration in `cv32e40p/tests/cfg/` holds the options of `gvrun` for the model, as `ovpsim`
holds those of OVPsim. It names the target of the bridge whose model has the RTL parameters of the configuration
(`FPU`, `ZFINX`, `COREV_PULP`, `COREV_CLUSTER`, `NUM_MHPMCOUNTERS`):

| Configurations | Target |
|---|---|
| default, no_pulp | `cv32e40p_cosim` |
| num_mhpmcounter_29 | `cv32e40p_cosim_mhpm29` |
| pulp | `cv32e40p_cosim_pulp` |
| pulp_fpu | `cv32e40p_cosim_pulp_fpu` |
| pulp_fpu_zfinx | `cv32e40p_cosim_pulp_fpu_zfinx` |
| pulp_cluster | `cv32e40p_cosim_pulp_cluster` |
| pulp_cluster_fpu | `cv32e40p_cosim_pulp_cluster_fpu` |
| pulp_cluster_fpu_zfinx | `cv32e40p_cosim_pulp_cluster_fpu_zfinx` |

The `_1cyclat` and `_2cyclat` configurations use the target of their base configuration. Nothing checks that the
target matches the `compile_flags` of the same file: they are kept aligned by hand, as for `ovpsim`.

## Running

`ISS` selects the reference model of `USE_ISS=YES` (`mk/uvmt/uvmt.mk`): `IMPERAS`, the default, or `GVSOC`, which
needs `SIMULATOR=vsim` and sets `USE_ISS=YES` unless it is given. With `GVSOC`, `mk/uvmt/vsim.mk`:

- defines `USE_GVSOC`, compiles `gvsoc.flist` and loads the library of the bridge, `GVSOC_RVVI_MODEL` (`-sv_lib`);
- before each simulation runs `gen_gvsoc_config`: `gvrun prepare`, with the `gvsoc` tag of the configuration, the ELF
  of the test, the `+mtvec_addr` plusarg of the test if any, and `stop_on_exit=false` so that the model runs past the
  end of the test like the RTL, writes the platform configuration in `<run directory>/gvsoc`. `GVSOC_CONFIG` points
  the bridge to it.

`mk/README.md` lists the variables of the flow.

## ISA coverage

With `COV=YES` the ISA coverage comes from `uvma_isacov`, which reads the instructions from the RVFI agent.

`fflags`, `frm` and `fcsr` are supported with RV32F or Zfinx, so the RVFI agent and `uvma_isacov` see their accesses.

`uvme_rv32f_isa_covg` adds the RV32F, Zcf and Zfinx instructions: it decodes them from the `uvma_isacov` transactions
and samples one covergroup per instruction. RVFI reports the integer registers only, so the operand values are
covered for every operand with Zfinx, and only on the GPR side with F.

`uvme_rv32x_isa_covg` does the same for Xpulp (XPULPV2, and `cv.elw` with `COREV_CLUSTER`). The hardware loops are
covered by `uvme_rv32x_hwloop_covg`.

## Tests

Self-checking programs in `cv32e40p/tests/programs/custom/`, not in the regression lists:

- `pulp_cluster_elw_test`: `cv.elw` on plain memory, where it reads like `lw`, on the pulp_cluster configurations. In
  co-simulation it needs an RTL whose RVFI follows a `cv.elw` through EX and WB.
