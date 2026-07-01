// =============================================================================
// uvmt_cv32e40p_rvvi_text_tracer.sv
//
// RTL-only RVVI-TEXT trace generator.  Drives the rvviTrace interface
// from the DUT RVFI -- reusing the shared uvmt_cv32e40p_iss_wrap_common.svh
// wiring -- and emits dut.rvvi through the librvvi_text.so DPI shim.  NO GVSOC,
// NO ISS, NO step-n-compare: this is the DUT-only writer.
//
// Compiled under RVVI_TRACE, in two modes: RTL-only (no USE_ISS), where this
// module is the sole producer on the rvvi interface and emits dut.rvvi on its
// own; and dual-trace co-sim (USE_ISS also defined), where a co-sim wrap on
// the same rvvi_if drives it for step-n-compare and this module compiles its
// driving wiring out (`ifndef USE_ISS), reads the interface, and remains the
// sole dut.rvvi producer while the bridge writes ref.rvvi.
//
// The RVFI->RVVI macros below are a guarded copy of the ones in
// uvmt_cv32e40p_gvsoc_wrap.sv (kept identical).  They are duplicated rather than
// shared to avoid touching the production co-sim wrap; `ifndef guards let the
// two coexist harmlessly if both files are ever compiled together.  TODO:
// extract the shared macros into a common .svh once sim-validated.
// =============================================================================

`ifndef __UVMT_CV32E40P_RVVI_TEXT_TRACER_SV__
`define __UVMT_CV32E40P_RVVI_TEXT_TRACER_SV__

`ifndef DUT_PATH
`define DUT_PATH dut_wrap.cv32e40p_tb_wrapper_i
`endif
`ifndef RVFI_IF
`define RVFI_IF  `DUT_PATH.rvfi_i
`endif
`ifndef STRINGIFY
`define STRINGIFY(x) `"x`"
`endif

// CSR = (wdata & wmask) | (rdata & ~wmask), with write-back pulse on change.
`ifndef RVVI_SET_CSR
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
`endif

// Trap-written CSRs (mepc/mcause/mtval/mstatus): hardware trap writes set
// wmask=0, so take wdata directly; otherwise use the standard formula.
`ifndef RVVI_SET_TRAP_CSR
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
`endif

`ifndef RVVI_SET_CSR_VEC
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
`endif

`ifndef RVVI_WRITE_IRQ
`define RVVI_WRITE_IRQ(IRQ_NAME, IRQ_IDX) \
    wire   irq_``IRQ_NAME; \
    assign irq_``IRQ_NAME = `DUT_PATH.irq_i[IRQ_IDX]; \
    always @(irq_``IRQ_NAME) begin \
        void'(rvvi.net_push(`STRINGIFY(``IRQ_NAME), irq_``IRQ_NAME)); \
    end
`endif

`include "uvmt_cv32e40p_csr_defs.svh"

module uvmt_cv32e40p_rvvi_text_tracer
  #(
     parameter int ILEN   = 32,
     parameter int XLEN   = 32,
     parameter int FPU    = 0,    // 0 -> FLEN 0 (no FPU), else FLEN 32
     parameter int ZFINX  = 0,    // accepted for API symmetry with the wraps
     parameter int NHART  = 1,
     parameter int RETIRE = 1
    )
    (
        // RTL-only: sole producer, drives the interface below.  Dual-trace:
        // read-only alongside the co-sim wrap (see header).  Which mode
        // applies is a compile-time fact (`ifdef USE_ISS below).
        rvviTrace  rvvi
    );

    // librvvi_text.so DPI shim (RTL-only writer; no GVSOC dependency).
    import "DPI-C" function void rvviTextOpen(input string path,
                                              input int unsigned ilen,
                                              input int unsigned xlen,
                                              input int unsigned flen,
                                              input int unsigned vlen,
                                              input int unsigned nhart,
                                              input int unsigned retire);
    import "DPI-C" function void rvviTextSetGpr (input int unsigned idx,  input longint unsigned value);
    import "DPI-C" function void rvviTextSetFpr (input int unsigned idx,  input longint unsigned value);
    import "DPI-C" function void rvviTextSetCsr (input int unsigned addr, input longint unsigned value);
    import "DPI-C" function void rvviTextSetMode(input int unsigned mode);
    import "DPI-C" function void rvviTextWrite  (input longint unsigned pc,
                                                 input longint unsigned insn,
                                                 input byte unsigned    isTrap);
    import "DPI-C" function void rvviTextClose();

    localparam int FLEN = (FPU != 0) ? 32 : 0;

    // Register an RVVI client so interrupt/haltreq nets have a consumer here
    // too; we drain and discard them (no reference model). Needed in both
    // modes: net_push() broadcasts to every registered client's queue
    // (rvviTrace.sv), so in dual-trace the nets gvsoc_wrap pushes land in
    // this client's queue as well -- left undrained they'd grow unbounded.
    // This tracer never pushes its own nets in dual-trace (its driving
    // `include below compiles out), it only drains.
    int client_id;
    initial begin
        client_id = rvvi.client_register(1'b1, 1'b0);
    end

    // Open dut.rvvi (override path with +rvvi_text_dut=<path>) and write header.
    string dut_path = "dut.rvvi";
    initial begin
        void'($value$plusargs("rvvi_text_dut=%s", dut_path));
        rvviTextOpen(dut_path, ILEN, XLEN, FLEN, 0, NHART, RETIRE);
    end

    // Flush and close at end of simulation.
    final begin
        rvviTextClose();
    end

    // Common RVFI->RVVI wiring: drives rvvi.{valid,pc,insn,trap,mode,x_*,f_*,csr*}
    // from the DUT RVFI.  Same include the GVSOC/Imperas wraps use.  Compiled
    // in only when USE_ISS is NOT defined: in dual-trace the co-sim wrap on
    // this same rvvi_if already includes it, and a second copy would
    // double-drive every rvvi.csr[]/mode[] net the shared macros touch.
    // NOTE: must stay a plain `ifdef (not a generate-if guarding the
    // `include) -- the shared .svh has its own top-level generate region,
    // and SystemVerilog disallows nesting one generate scope inside another.
`ifndef USE_ISS
    `include "uvmt_cv32e40p_iss_wrap_common.svh"

    // The shared include gates mtval wiring behind `ifdef USE_GVSOC; the RTL-only
    // RVVI_TRACE path must drive it here, else trap lines emit mtval=0 (undriven).
    `RVVI_SET_TRAP_CSR(`CSR_MTVAL_ADDR, mtval)
`endif

    // Per-retire: extract the architectural write-set and emit one RVVI-TEXT line.
    // Mirrors the DUT-side push loop of rvvi_trace2api.sv, minus all rvviRef*/ISS
    // steps -- the line goes straight to the DUT-only writer.
    always @(posedge rvvi.clk) begin
        for (int h = 0; h < NHART; h++) begin
            for (int r = 0; r < RETIRE; r++) begin
                if (rvvi.valid[h][r]) begin
                    // Skip pipeline-flush artifacts (PC=0); always allow traps.
                    if (rvvi.trap[h][r] || rvvi.pc_rdata[h][r] != 0) begin

                        // GPR write-set (x0 hardwired zero -> skip).
                        for (int i = 1; i < 32; i++)
                            if (rvvi.x_wb[h][r][i])
                                rvviTextSetGpr(i, rvvi.x_wdata[h][r][i]);

                        // FPR write-set.
                        for (int i = 0; i < 32; i++)
                            if (rvvi.f_wb[h][r][i])
                                rvviTextSetFpr(i, rvvi.f_wdata[h][r][i]);

                        // CSR write-set (sparse scan over the 4096-bit wb vector).
                        begin
                            automatic int wb_total = $countones(rvvi.csr_wb[h][r]);
                            if (wb_total > 0) begin
                                automatic int wb_found = 0;
                                for (int i = 0; i < 4096 && wb_found < wb_total; i++)
                                    if (rvvi.csr_wb[h][r][i]) begin
                                        rvviTextSetCsr(i, rvvi.csr[h][r][i]);
                                        wb_found++;
                                    end
                            end
                        end

                        // Trap exception CSRs lag csr_wb by one delta cycle; push
                        // the combinatorially-stable rvvi.csr values explicitly
                        // (same as rvvi_trace2api.sv on the trap path).
                        if (rvvi.trap[h][r]) begin
                            rvviTextSetCsr(`CSR_MSTATUS_ADDR, rvvi.csr[h][r][`CSR_MSTATUS_ADDR]);
                            rvviTextSetCsr(`CSR_MEPC_ADDR,    rvvi.csr[h][r][`CSR_MEPC_ADDR]);
                            rvviTextSetCsr(`CSR_MCAUSE_ADDR,  rvvi.csr[h][r][`CSR_MCAUSE_ADDR]);
                            rvviTextSetCsr(`CSR_MTVAL_ADDR,   rvvi.csr[h][r][`CSR_MTVAL_ADDR]);
                        end

                        // Privilege MODE column -- free from the rvvi interface.
                        rvviTextSetMode(rvvi.mode[h][r]);

                        // Emit one line: TRAP for synchronous exceptions, else RET.
                        rvviTextWrite(rvvi.pc_rdata[h][r], rvvi.insn[h][r],
                                      rvvi.trap[h][r] ? 8'd1 : 8'd0);
                    end // architectural retire guard

                    // Drain (and discard) the interrupt/haltreq nets the common
                    // wiring pushed; without a reference model nobody else pops.
                    begin
                        string name;
                        longint unsigned value;
                        longint unsigned pslot;
                        while (rvvi.net_pop(client_id, name, value, pslot)) begin
                            // discard: no reference model consumes the nets here
                        end
                    end
                end
            end
        end
    end

endmodule : uvmt_cv32e40p_rvvi_text_tracer

`endif // __UVMT_CV32E40P_RVVI_TEXT_TRACER_SV__
