
`ifndef __UVMT_CV32E40P_GVSOC_WRAP_SV__
`define __UVMT_CV32E40P_GVSOC_WRAP_SV__

// RVFI->RVVI macros (shared with uvmt_cv32e40p_rvvi_text_tracer.sv) and
// CSR address definitions.
`include "uvmt_cv32e40p_rvfi2rvvi_macros.svh"
`include "uvmt_cv32e40p_csr_defs.svh"

module uvmt_cv32e40p_gvsoc_wrap
  import uvm_pkg::*;
  import cv32e40p_pkg::*;
  import rvviApiPkg::*;
  #(
     // FPU gates the FP-CSR compare policy in ref_init and the RVVI-TEXT
     // header FLEN. ZFINX is declared for API symmetry with imperas_dv_wrap
     // (the FP-CSR policy is the same with or without it).
     parameter FPU   = 0,
     parameter ZFINX = 0
    )
    (
        rvviTrace  rvvi // RVVI SystemVerilog Interface
    );

    // Declared here so Questa resolves the DPI context within this module scope.
    import "DPI-C" function int rvviRefIsFinished();

    // Custom extension, not part of the vendored RVVI API: called from
    // ref_init below BEFORE rvviRefInit() so the bridge knows to skip opening
    // dut.rvvi (the SV tracer on this same rvvi_if is the sole dut.rvvi
    // producer when RVVI_TRACE is also compiled in).
    import "DPI-C" function void rvviBridgeSetRefOnly(input byte unsigned refOnly);

    // Custom extension: CFG-derived FLEN for the RVVI-TEXT PARAMS header.
    // Also called before rvviRefInit(); without it the bridge falls back to
    // FLEN 32 and its header diverges from the tracer's on no-FPU configs.
    import "DPI-C" function void rvviBridgeSetFlen(input int unsigned flen);

    // Instantiate Open-Source Sync Bridge. The RVFI data-memory view feeds
    // the bridge's volatile memory window sync (rvviRefMemorySetVolatile).
    rvvi_trace2api #(
        .NHART(1),
        .RETIRE(1)
    )
    gvsoc_sync(
        .rvvi          (rvvi),
        .dut_mem_addr  (`RVFI_IF.rvfi_mem_addr),
        .dut_mem_rmask (`RVFI_IF.rvfi_mem_rmask),
        // Tracer-fidelity sidecar (+rvvi_tracer_fidelity): raw rvfi_intr
        // bundle and rvfi_dbg entry cause from the core tracer. rvfi_intr
        // needs the tracer patch that drives it (undriven upstream);
        // rvfi_dbg has always been driven.
        .dut_intr      (`RVFI_IF.rvfi_intr),
        .dut_dbg       (`RVFI_IF.rvfi_dbg)
    );

    ////////////////////////////////////////////////////////////////////////////
    // ISS completion watchdog.
    //
    // When the firmware writes to the exit device, rvviRefEventStep() schedules
    // $finish via vpi_control. If the DUT enters WFI before that $finish is
    // processed, the clocked always block in rvvi_trace2api never fires
    // again and the simulator hangs. This initial block polls rvviRefIsFinished()
    // and forces $finish from a non-clocked context, which the simulator can
    // always service regardless of DUT clock state.
    ////////////////////////////////////////////////////////////////////////////
    initial begin
        #1000000; // 1 ms: allow UVM env init and ref_init to complete
        forever begin
            #100000; // 100 us poll interval
            if (rvviRefIsFinished()) begin
                `uvm_info(info_tag, "ISS finished - forcing $finish to unblock WFI", UVM_NONE)
                $finish(0);
            end
        end
    end

    string info_tag = "GVSOC_wrap";

    // Common RVFI->RVVI wiring (CSRs, GPRs, FPRs, debug, IRQs)
    `include "uvmt_cv32e40p_iss_wrap_common.svh"

    /////////////////////////////////////////////////////////////////////////////
    // REF control
    /////////////////////////////////////////////////////////////////////////////
    task ref_init;
        string test_program_elf;
        reg [31:0] hart_id;
        bit [63:0] mtvec_addr_i;

        if (!rvviVersionCheck(RVVI_API_VERSION)) begin
            `uvm_fatal(info_tag, $sformatf("Expecting RVVI API version %0d.", RVVI_API_VERSION))
        end

        if ($value$plusargs("elf_file=%s", test_program_elf)) begin
`ifdef RVVI_TRACE
            // Dual-trace: the SV tracer alongside this wrap is the sole
            // dut.rvvi producer -- tell the bridge to open ref.rvvi only.
            // Must run before rvviRefInit(), where the file-open decision
            // happens; sequential task order guarantees that.
            rvviBridgeSetRefOnly(8'd1);
`endif
            rvviBridgeSetFlen((FPU != 0) ? 32 : 0);
            `uvm_info(info_tag, $sformatf("Loading ELF: %0s", test_program_elf), UVM_NONE)
            if (!rvviRefInit(test_program_elf)) begin
                `uvm_fatal(info_tag, "rvviRefInit failed")
            end
        end else begin
            `uvm_fatal(info_tag, "No elf_file plusarg specified")
        end

        hart_id = 32'h0000_0000;

        // --- Volatile CSRs: hardware-updated, cannot be predicted per-retire ---
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_CYCLE_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_CYCLEH_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_INSTRET_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, 32'hC82));              // instreth user-mode shadow
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MCYCLE_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MCYCLEH_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MINSTRET_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MINSTRETH_ADDR));
        // mip reflects async interrupt state; cannot be predicted.
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MIP_ADDR));
        // Debug scratchpads are written in debug mode only.
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_DSCRATCH0_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_DSCRATCH1_ADDR));
        // HPM counters and events are not modeled by the ISS.
        for (int i = 0; i < 29; i++) begin
            void'(rvviRefCsrSetVolatile(hart_id, 32'hB03 + i));  // mhpmcounter3..31
            void'(rvviRefCsrSetVolatile(hart_id, 32'hB83 + i));  // mhpmcounterh3..31
            void'(rvviRefCsrSetVolatile(hart_id, 32'h323 + i));  // mhpmevent3..31
        end

        // --- Volatile memory: TB virtual-peripheral registers no functional
        // model can predict (random-number generator @ 0x15001000, cycle
        // counter @ 0x15001004). Same window the Imperas wrap declares; a
        // DUT load from here has its rd copied into the ISS instead of
        // compared (bridge volatile memory window sync).
        void'(rvviRefMemorySetVolatile('h15001000, 'h15001007));

        // --- Compared CSRs: modeled by the GVSOC engine ---
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MISA_ADDR,          RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MSTATUS_ADDR,       RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MIE_ADDR,           RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MTVEC_ADDR,         RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MCOUNTINHIBIT_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MSCRATCH_ADDR,      RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MEPC_ADDR,          RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MCAUSE_ADDR,        RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MTVAL_ADDR,         RVVI_TRUE));
        // Debug CSRs.
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_DCSR_ADDR,          RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_DPC_ADDR,           RVVI_TRUE));
        // Trigger and implementation-ID CSRs - ISS reset values match RTL.
        // mimpid is excluded: the RTL step-compare path does not check it.
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_TDATA1_ADDR,    RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_TINFO_ADDR,     RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MVENDORID_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MARCHID_ADDR,   RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MHARTID_ADDR,   RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_TSELECT_ADDR,   RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_TDATA2_ADDR,    RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_TDATA3_ADDR,    RVVI_TRUE));
        // Hwloop CSRs (PULP builds). On non-PULP builds both sides hold the
        // reset value, so the compare never fires.
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_LPSTART0_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_LPEND0_ADDR,   RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_LPCOUNT0_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_LPSTART1_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_LPEND1_ADDR,   RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_LPCOUNT1_ADDR, RVVI_TRUE));
        // FP status CSRs (FPU builds only). Flag accrual (fflags / fcsr[4:0])
        // is not bit-exact between the RTL FPU and the ISS float model (e.g.
        // underflow raised on exact denormal results, invalid accrued by
        // trapped FP encodings), so only the explicitly-written rounding mode
        // is compared: frm in full, fcsr masked to its frm field. fflags stays
        // out of the compare set until the ISS flag semantics are aligned.
        if (FPU != 0) begin
            void'(rvviRefCsrCompareEnable(hart_id, `CSR_FRM_ADDR,  RVVI_TRUE));
            void'(rvviRefCsrCompareEnable(hart_id, `CSR_FCSR_ADDR, RVVI_TRUE));
            void'(rvviRefCsrCompareMask(hart_id, `CSR_FCSR_ADDR, 64'hE0));
        end

        // --- Interrupt/debug nets ---
        // Asynchronous interrupt grouping (group 1) and debug halt request (group 4).
        rvviRefNetGroupSet(rvviRefNetIndexGet("MSWInterrupt"),        1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("MTimerInterrupt"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("MExternalInterrupt"),  1);
        for (int i = 0; i < 16; i++)
            rvviRefNetGroupSet(rvviRefNetIndexGet($sformatf("LocalInterrupt%0d", i)), 1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("haltreq"),             4);

        // CV32E40P reset value for mtvec is 0x1 (vectored, base=0x0).
        mtvec_addr_i = 64'h1;
        if ($value$plusargs("mtvec_addr=%0x", mtvec_addr_i)) begin
            `uvm_info(info_tag, $sformatf("mtvec set to 0x%08x (from plusarg)", mtvec_addr_i), UVM_NONE)
        end else begin
            `uvm_info(info_tag, $sformatf("mtvec set to 0x%08x (reset default)", mtvec_addr_i), UVM_NONE)
        end
        rvviRefCsrSet(hart_id, `CSR_MTVEC_ADDR, mtvec_addr_i);

        `uvm_info(info_tag, "GVSOC ref_init complete", UVM_NONE)
    endtask

endmodule

`endif
