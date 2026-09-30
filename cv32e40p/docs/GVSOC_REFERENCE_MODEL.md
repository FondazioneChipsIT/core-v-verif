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
errors, as with ImperasDV.

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
