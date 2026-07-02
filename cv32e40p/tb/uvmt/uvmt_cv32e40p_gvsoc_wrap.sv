
`ifndef __UVMT_CV32E40P_GVSOC_WRAP_SV__
`define __UVMT_CV32E40P_GVSOC_WRAP_SV__

`define DUT_PATH dut_wrap.cv32e40p_tb_wrapper_i
`define RVFI_IF  `DUT_PATH.rvfi_i

`define STRINGIFY(x) `"x`"

////////////////////////////////////////////////////////////////////////////
// Assign the rvvi CSR values from RVFI - CSR = (wdata & wmask) | (rdata & ~wmask)
////////////////////////////////////////////////////////////////////////////
`define RVVI_SET_CSR(CSR_ADDR, CSR_NAME) \
    bit csr_``CSR_NAME``_wb; \
    wire [31:0] csr_``CSR_NAME``_w; \
    wire [31:0] csr_``CSR_NAME``_r; \
    assign csr_``CSR_NAME``_w = `RVFI_IF.rvfi_csr_``CSR_NAME``_wdata &   `RVFI_IF.rvfi_csr_``CSR_NAME``_wmask; \
    assign csr_``CSR_NAME``_r = `RVFI_IF.rvfi_csr_``CSR_NAME``_rdata & ~(`RVFI_IF.rvfi_csr_``CSR_NAME``_wmask); \
    assign rvvi.csr[0][0][``CSR_ADDR]    = csr_``CSR_NAME``_w | csr_``CSR_NAME``_r; \
    assign rvvi.csr_wb[0][0][``CSR_ADDR] = csr_``CSR_NAME``_wb; \
    always @(rvvi.csr[0][0][``CSR_ADDR]) begin \
        csr_``CSR_NAME``_wb = 1; \
    end \
    always @(posedge rvvi.clk) begin \
        if (`RVFI_IF.rvfi_valid && csr_``CSR_NAME``_wb) begin \
            csr_``CSR_NAME``_wb <= 0; \
        end \
    end

////////////////////////////////////////////////////////////////////////////
// Assign RVVI CSR values for trap-written CSRs (mepc, mcause, mtval).
//
// Hardware trap writes set wmask=0 in RVFI; the standard formula would then
// yield rdata (stale), not the new trap value. Use wdata directly when
// wmask==0; fall back to the standard (wdata & wmask) | (rdata & ~wmask)
// formula for explicit CSR-write instructions.
////////////////////////////////////////////////////////////////////////////
`define RVVI_SET_TRAP_CSR(CSR_ADDR, CSR_NAME) \
    bit csr_``CSR_NAME``_wb; \
    wire [31:0] csr_``CSR_NAME``_wdata_raw; \
    wire [31:0] csr_``CSR_NAME``_wmask_raw; \
    wire [31:0] csr_``CSR_NAME``_rdata_raw; \
    assign csr_``CSR_NAME``_wdata_raw = `RVFI_IF.rvfi_csr_``CSR_NAME``_wdata; \
    assign csr_``CSR_NAME``_wmask_raw = `RVFI_IF.rvfi_csr_``CSR_NAME``_wmask; \
    assign csr_``CSR_NAME``_rdata_raw = `RVFI_IF.rvfi_csr_``CSR_NAME``_rdata; \
    assign rvvi.csr[0][0][``CSR_ADDR]    = (csr_``CSR_NAME``_wmask_raw == 32'h0) \
        ? csr_``CSR_NAME``_wdata_raw \
        : (csr_``CSR_NAME``_wdata_raw & csr_``CSR_NAME``_wmask_raw) \
          | (csr_``CSR_NAME``_rdata_raw & ~csr_``CSR_NAME``_wmask_raw); \
    assign rvvi.csr_wb[0][0][``CSR_ADDR] = csr_``CSR_NAME``_wb; \
    always @(rvvi.csr[0][0][``CSR_ADDR]) begin \
        csr_``CSR_NAME``_wb = 1; \
    end \
    always @(posedge rvvi.clk) begin \
        if (`RVFI_IF.rvfi_valid && csr_``CSR_NAME``_wb) begin \
            csr_``CSR_NAME``_wb <= 0; \
        end \
    end

`define RVVI_SET_CSR_VEC(CSR_ADDR, CSR_NAME, CSR_ID) \
    bit csr_``CSR_NAME````CSR_ID``_wb; \
    wire [31:0] csr_``CSR_NAME````CSR_ID``_w; \
    wire [31:0] csr_``CSR_NAME````CSR_ID``_r; \
    assign csr_``CSR_NAME````CSR_ID``_w = `RVFI_IF.rvfi_csr_``CSR_NAME``_wdata[``CSR_ID] &   `RVFI_IF.rvfi_csr_``CSR_NAME``_wmask[``CSR_ID]; \
    assign csr_``CSR_NAME````CSR_ID``_r = `RVFI_IF.rvfi_csr_``CSR_NAME``_rdata[``CSR_ID] & ~(`RVFI_IF.rvfi_csr_``CSR_NAME``_wmask[``CSR_ID]); \
    assign rvvi.csr[0][0][``CSR_ADDR]    = csr_``CSR_NAME````CSR_ID``_w | csr_``CSR_NAME````CSR_ID``_r; \
    assign rvvi.csr_wb[0][0][``CSR_ADDR] = csr_``CSR_NAME````CSR_ID``_wb; \
    always @(rvvi.csr[0][0][``CSR_ADDR]) begin \
        csr_``CSR_NAME````CSR_ID``_wb = 1; \
    end \
    always @(posedge rvvi.clk) begin \
        if (`RVFI_IF.rvfi_valid && csr_``CSR_NAME````CSR_ID``_wb) begin \
            csr_``CSR_NAME````CSR_ID``_wb <= 0; \
        end \
    end

////////////////////////////////////////////////////////////////////////////
// Assign the NET IRQ values from the core irq inputs
////////////////////////////////////////////////////////////////////////////
`define RVVI_WRITE_IRQ(IRQ_NAME, IRQ_IDX) \
    wire   irq_``IRQ_NAME; \
    assign irq_``IRQ_NAME = `DUT_PATH.irq_i[IRQ_IDX]; \
    always @(irq_``IRQ_NAME) begin \
        void'(rvvi.net_push(`STRINGIFY(``IRQ_NAME), irq_``IRQ_NAME)); \
    end

////////////////////////////////////////////////////////////////////////////
// CSR definitions
////////////////////////////////////////////////////////////////////////////
`include "uvmt_cv32e40p_csr_defs.svh"

module uvmt_cv32e40p_gvsoc_wrap
  import uvm_pkg::*;
  import cv32e40p_pkg::*;
  import rvviApiPkg::*;
  #(
     // FPU/ZFINX: declared for API symmetry with imperas_dv_wrap.
     // rvvi_trace2api has no CMP_FPR knob - FPR comparison is
     // unconditional but harmless on non-FPU builds (zeros vs zeros).
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

    // Instantiate Open-Source Sync Bridge
    rvvi_trace2api #(
        .NHART(1),
        .RETIRE(1)
    )
    gvsoc_sync(rvvi);

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

        // Counters are hardware-updated and cannot be predicted cycle-accurately.
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_CYCLE_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_CYCLEH_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_INSTRET_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MCYCLE_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MCYCLEH_ADDR));
        // mip reflects async interrupt state; cannot be predicted.
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MIP_ADDR));

        // HPM counters and events are not modeled by the ISS.
        for (int i = 0; i < 29; i++) begin
            void'(rvviRefCsrSetVolatile(hart_id, 32'hB03 + i));  // mhpmcounter3..31
            void'(rvviRefCsrSetVolatile(hart_id, 32'hB83 + i));  // mhpmcounterh3..31
            void'(rvviRefCsrSetVolatile(hart_id, 32'h323 + i));  // mhpmevent3..31
        end

        // Enable comparison for CSRs modeled by the GVSOC engine.
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MISA_ADDR,          RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MSTATUS_ADDR,       RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MIE_ADDR,           RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MTVEC_ADDR,         RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MCOUNTINHIBIT_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MSCRATCH_ADDR,      RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MEPC_ADDR,          RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MCAUSE_ADDR,        RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_MTVAL_ADDR,         RVVI_TRUE));

        // dcsr/dpc: all bits volatile because debug-entry timing and dcsr.cause
        // are not modeled cycle-accurately by the ISS. CompareEnable is still set
        // so the infrastructure tracks these CSRs; the volatile mask suppresses
        // any effective comparison until ISS coverage improves.
        void'(rvviRefCsrSetVolatileMask(hart_id, `CSR_DCSR_ADDR, 32'hFFFFFFFF));
        void'(rvviRefCsrSetVolatileMask(hart_id, `CSR_DPC_ADDR,  32'hFFFFFFFF));

        // Asynchronous interrupt grouping (group 1) and debug halt request (group 4).
        rvviRefNetGroupSet(rvviRefNetIndexGet("MSWInterrupt"),        1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("MTimerInterrupt"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("MExternalInterrupt"),  1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt0"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt1"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt2"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt3"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt4"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt5"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt6"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt7"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt8"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt9"),     1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt10"),    1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt11"),    1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt12"),    1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt13"),    1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt14"),    1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("LocalInterrupt15"),    1);
        rvviRefNetGroupSet(rvviRefNetIndexGet("haltreq"),             4);

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

        // Retire-counter high words and debug scratchpads are volatile.
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MINSTRET_ADDR));   // auto-increments
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_MINSTRETH_ADDR));
        void'(rvviRefCsrSetVolatile(hart_id, 32'hC82));              // instreth user-mode shadow (high word)
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_DSCRATCH0_ADDR));  // debug-mode only
        void'(rvviRefCsrSetVolatile(hart_id, `CSR_DSCRATCH1_ADDR));  // debug-mode only
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_DCSR_ADDR, RVVI_TRUE));
        void'(rvviRefCsrCompareEnable(hart_id, `CSR_DPC_ADDR,  RVVI_TRUE));

        // Memory-mapped device regions - exclude from memory comparison.
        void'(rvviRefMemorySetVolatile(64'h20000000, 64'h20000003));  // exit device
        void'(rvviRefMemorySetVolatile(64'h15000000, 64'h15001007));  // timer / debug module

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
