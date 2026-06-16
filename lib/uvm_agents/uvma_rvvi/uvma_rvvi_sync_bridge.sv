
/**
 * Module uvma_rvvi_sync_bridge
 *
 * Monitors the rvviTrace interface and drives the RVVI DPI API each cycle.
 * Replaces proprietary trace2api modules with an open-source equivalent.
 *
 * Per-retire sequence:
 *   1. Push GPR/FPR/CSR write-back data (architectural retire guard)
 *   2. Push pending interrupt nets (always; IRQs are asynchronous)
 *   3. Notify bridge of DUT retirement (rvviDutRetire or rvviDutTrap)
 *   4. On trap: consume the extra ISS exception-dispatch step silently
 *   5. Step reference model and compare PC/GPR/CSR/FPR (non-trap only)
 */
module uvma_rvvi_sync_bridge
  import rvviApiPkg::*;
#(
    parameter int ILEN    = 32,
    parameter int XLEN    = 32,
    parameter int FLEN    = 32,
    parameter int VLEN    = 256,
    parameter int NHART   = 1,
    parameter int RETIRE  = 1
)
(
    rvviTrace  rvvi
);

    int client_id;

    initial begin
        // RVVI v1.37: client_register requires recv_nets/recv_memory flags.
        // Step-n-compare does not consume net_pop/mem_access_pop events, so both 0.
        client_id = rvvi.client_register(1'b0, 1'b0);
    end

`ifdef USE_GVSOC
    // GVSOC-specific batch DPI: collapses step + 4 compares into one crossing.
    // Returns a bitmask: 0x01=step 0x02=PC 0x04=GPR 0x08=CSR 0x10=FPR.
    import "DPI-C" function int rvviRefRetireAndCompare(
        input int unsigned  hartId,
        input longint unsigned dutPc,
        input int unsigned  dutInsn,
        input byte unsigned debugMode);
`endif

    // Debug counters
    longint unsigned retire_count = 0;
    int unsigned err_count = 0;
    localparam int unsigned MAX_ERR_LOG = 10;

    always @(posedge rvvi.clk) begin
        for (int h=0; h<NHART; h++) begin
            for (int r=0; r<RETIRE; r++) begin
                if (rvvi.valid[h][r]) begin
                    retire_count++;

                    // Diagnostic heartbeat (opt-in): first 5 retires, then every 1000th.
                    // Enable with +rvvi_sync_bridge_verbose on the simulator command line.
                    if ($test$plusargs("rvvi_sync_bridge_verbose") &&
                        (retire_count <= 5 || (retire_count % 1000 == 0)))
                        $display("[sync_bridge] retire #%0d: PC=0x%08x insn=0x%08x trap=%0b order=%0d",
                                 retire_count, rvvi.pc_rdata[h][r], rvvi.insn[h][r],
                                 rvvi.trap[h][r], rvvi.order[h][r]);

                    // Skip GPR/FPR/CSR push for pipeline-flush artifacts (PC=0x0).
                    // Trap retires (trap=1, PC!=0) are always allowed through.
                    if (rvvi.trap[h][r] || rvvi.pc_rdata[h][r] != 0) begin

                        // 1. Push GPR changes from DUT to Bridge.
                        // x0 is hardwired to zero - skip it even if x_wb[0] is flagged.
                        for (int i=1; i<32; i++) begin
                            if (rvvi.x_wb[h][r][i]) begin
                                rvviDutGprSet(h, i, rvvi.x_wdata[h][r][i]);
                            end
                        end

                        // 2. Push FPR changes from DUT to Bridge
                        for (int i=0; i<32; i++) begin
                            if (rvvi.f_wb[h][r][i]) begin
                                rvviDutFprSet(h, i, rvvi.f_wdata[h][r][i]);
                            end
                        end

                        // 3. Push CSR changes from DUT to Bridge (sparse scan).
                        begin
                            automatic int wb_total = $countones(rvvi.csr_wb[h][r]);
                            if (wb_total > 0) begin
                                automatic int wb_found = 0;
                                for (int i = 0; i < 4096 && wb_found < wb_total; i++) begin
                                    if (rvvi.csr_wb[h][r][i]) begin
                                        rvviDutCsrSet(h, i, rvvi.csr[h][r][i]);
                                        wb_found++;
                                    end
                                end
                            end
                        end

                    end // architectural retire guard

                    // 4. Push Nets/Interrupts - always, IRQ changes are asynchronous
                    begin
                        string name;
                        longint unsigned value;
                        longint unsigned pslot;
                        while (rvvi.net_pop(client_id, name, value, pslot)) begin
                            rvviRefNetSet(rvviRefNetIndexGet(name), value, pslot);
                        end
                    end

                    // 5. Notify Bridge of DUT retirement
                    if (rvvi.trap[h][r]) begin
                        // csr_wb for exception CSRs is asserted one delta-cycle after
                        // the trap-retire posedge, so step 3 reads csr_wb=0 and misses
                        // mepc/mcause/mtval.  Push them explicitly here from the
                        // combinatorially-stable rvvi.csr values, which use the
                        // RVVI_SET_TRAP_CSR macro (wdata direct when wmask==0) to give
                        // the correct value even on the first exception.
                        rvviDutCsrSet(h, 12'h300, rvvi.csr[h][r][12'h300]);  // mstatus (MPIE/MIE updated on trap)
                        rvviDutCsrSet(h, 12'h341, rvvi.csr[h][r][12'h341]);  // mepc   (trap-CSR macro)
                        rvviDutCsrSet(h, 12'h342, rvvi.csr[h][r][12'h342]);  // mcause (trap-CSR macro)
                        rvviDutCsrSet(h, 12'h343, rvvi.csr[h][r][12'h343]);  // mtval
                        rvviDutTrap(h, rvvi.pc_rdata[h][r], rvvi.insn[h][r]);
                        // GVSOC models exceptions as two ISS steps: (1) faulting
                        // instruction, (2) jump to mtvec.  Consume step 1 silently here;
                        // the handler retire consumes step 2 normally.  No comparison.
                        void'(rvviRefEventStep(h));
                    end else if (rvvi.pc_rdata[h][r] != 0) begin
                        rvviDutRetire(h, rvvi.pc_rdata[h][r], rvvi.insn[h][r], rvvi.debug_mode[h][r]);
                    end

                    // 6. Step Reference Model + 7. Comparisons
                    // Skipped on trap retires (handled above) and PC=0 flush artifacts.
                    if (!rvvi.trap[h][r] && rvvi.pc_rdata[h][r] != 0) begin
                        // Batch DPI: step + all compares in one crossing.
                        // Bit 0 (step) is checked first; if it fails the other bits
                        // are meaningless and only the step error is reported.
                        automatic int cmp_result = rvviRefRetireAndCompare(
                            h,
                            rvvi.pc_rdata[h][r],
                            rvvi.insn[h][r],
                            rvvi.debug_mode[h][r]);
                        if (!(cmp_result & 32'h01)) begin
                            if (err_count < MAX_ERR_LOG) begin
                                $error("RVVI Bridge: rvviRefEventStep FAILED for hart %0d at retire #%0d (PC=0x%08x)",
                                       h, retire_count, rvvi.pc_rdata[h][r]);
                                err_count++;
                            end
                        end else begin
                            if (!(cmp_result & 32'h02) && err_count < MAX_ERR_LOG) begin
                                $error("RVVI Mismatch: PC at retire #%0d order=%0d (DUT PC=0x%08x)",
                                       retire_count, rvvi.order[h][r], rvvi.pc_rdata[h][r]);
                                err_count++;
                            end
                            if (!(cmp_result & 32'h04) && err_count < MAX_ERR_LOG) begin
                                $error("RVVI Mismatch: GPR at retire #%0d order=%0d (DUT PC=0x%08x)",
                                       retire_count, rvvi.order[h][r], rvvi.pc_rdata[h][r]);
                                err_count++;
                            end
                            if (!(cmp_result & 32'h08) && err_count < MAX_ERR_LOG) begin
                                $error("RVVI Mismatch: CSR at retire #%0d order=%0d (DUT PC=0x%08x)",
                                       retire_count, rvvi.order[h][r], rvvi.pc_rdata[h][r]);
                                err_count++;
                            end
                            if (!(cmp_result & 32'h10) && err_count < MAX_ERR_LOG) begin
                                $error("RVVI Mismatch: FPR at retire #%0d order=%0d (DUT PC=0x%08x)",
                                       retire_count, rvvi.order[h][r], rvvi.pc_rdata[h][r]);
                                err_count++;
                            end
                        end
                    end
                end
            end
        end
    end

endmodule
