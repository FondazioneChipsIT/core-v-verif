#!/usr/bin/env python3
import sys
import re
import json


def get_trace_data(filename):
    """Parse a trace file into a list of {pc, ins, regs, raw} dicts."""
    instr_list = []
    pc_ins_pat = re.compile(r'([0-9a-fA-F]{8})\s+([0-9a-fA-F]{8})')
    reg_pat = re.compile(r'([a-zA-Z0-9]+)=([0-9a-fA-F]{8})')

    try:
        with open(filename, 'r') as f:
            for line in f:
                match = pc_ins_pat.search(line)
                if match:
                    # Skip RTL cancelled instructions ("(C)"): they reached execute but
                    # were aborted; GVSOC does not trace them, so skipping keeps alignment.
                    if '(C) ' in line:
                        continue
                    pc = match.group(1).lower()
                    instr = match.group(2).lower()
                    regs = {}
                    for r_match in reg_pat.finditer(line):
                        reg_name = r_match.group(1).lower()
                        reg_val = r_match.group(2).lower()
                        if reg_name != 'x0':
                            regs[reg_name] = reg_val
                    if pc != "00000000" or instr != "00000000":
                        instr_list.append({'pc': pc, 'ins': instr, 'regs': regs, 'raw': line.strip()})
    except FileNotFoundError:
        print(f"Error: file not found: {filename}", file=sys.stderr)
        sys.exit(1)
    return instr_list


def detect_loop(data, threshold=100):
    """Return the dominant PC if the trace tail is a tight loop, else None."""
    if len(data) < threshold:
        return None
    last_pc = data[-1]['pc']
    count = sum(1 for e in data[-threshold:] if e['pc'] == last_pc)
    if count >= threshold * 0.9:
        return last_pc
    return None


def compare(json_mode=False):
    rtl_file = sys.argv[-2]
    gvsoc_file = sys.argv[-1]

    rtl_data = get_trace_data(rtl_file)
    iss_data = get_trace_data(gvsoc_file)

    loop_pc = detect_loop(iss_data)
    rtl_count = len(rtl_data)
    gvsoc_count = len(iss_data)

    if not json_mode:
        print(f"--- Comparing: {rtl_count} RTL vs {gvsoc_count} GVSOC ---")

    # Separate RTL/GVSOC indices to handle the exception-tracing offset: GVSOC traces
    # a faulting instruction before the trap, RTL cancels it. On a PC mismatch, try
    # advancing GVSOC by one step to re-sync.
    ri = 0
    gi = 0
    step = 0
    while ri < rtl_count and gi < gvsoc_count:
        r = rtl_data[ri]
        g = iss_data[gi]

        if r['pc'] != g['pc']:
            # GVSOC traced a faulting instruction RTL cancelled: if gi+1 matches RTL, skip it.
            if gi + 1 < gvsoc_count and iss_data[gi + 1]['pc'] == r['pc']:
                gi += 1
                continue

            last_pc = rtl_data[ri-1]['pc'] if ri > 0 else 'START'
            i = step
            if json_mode:
                result = {
                    "status": "loop" if loop_pc else "divergence",
                    "summary": f"PC mismatch at step {i}: RTL={r['pc']} GVSOC={g['pc']}",
                    "rtl_count": rtl_count,
                    "gvsoc_count": gvsoc_count,
                    "divergence_step": i,
                    "last_common_pc": last_pc,
                    "divergence_pc_rtl": r['pc'],
                    "divergence_pc_rtl_ins": r['ins'],
                    "divergence_pc_gvsoc": g['pc'],
                    "divergence_pc_gvsoc_ins": g['ins'],
                    "loop_pc": loop_pc,
                    "next_actions": [
                        "check if loop_pc matches mtvec base (exception handler loop)",
                        "search for diverging CSR write before last_common_pc"
                    ],
                    "artifacts": [rtl_file, gvsoc_file]
                }
                print(json.dumps(result, indent=2))
            else:
                print(f"\n[!] PC DIVERGENCE at step {i}:")
                print(f"    RTL PC:   {r['pc']} (insn: {r['ins']})")
                print(f"    GVSOC PC: {g['pc']} (insn: {g['ins']})")
                print(f"\n    Last common PC: {last_pc}")
                if loop_pc:
                    print(f"    [LOOP] GVSOC stuck at PC {loop_pc}")
            sys.exit(1)

        i = step
        if r['ins'] != g['ins']:
            # Only flag an ELF mismatch when BOTH show a 32-bit insn (bits[1:0]==0b11):
            # for RVC (16-bit) the raw words can differ at the same PC yet agree on regs.
            rtl_is_32bit   = (int(r['ins'], 16) & 0x3) == 0x3
            gvsoc_is_32bit = (int(g['ins'], 16) & 0x3) == 0x3
            both_32bit = rtl_is_32bit and gvsoc_is_32bit
            if both_32bit:
                if json_mode:
                    result = {
                        "status": "elf_mismatch",
                        "summary": f"Opcode mismatch at step {i} (PC {r['pc']}): RTL={r['ins']} GVSOC={g['ins']} - different ELF binaries",
                        "rtl_count": rtl_count,
                        "gvsoc_count": gvsoc_count,
                        "divergence_step": i,
                        "last_common_pc": r['pc'],
                        "divergence_pc_rtl": r['pc'],
                        "divergence_pc_rtl_ins": r['ins'],
                        "divergence_pc_gvsoc": g['pc'],
                        "divergence_pc_gvsoc_ins": g['ins'],
                        "loop_pc": loop_pc,
                        "next_actions": [
                            "GVSOC trace was generated with a different CFG/ELF than the RTL trace",
                            "Re-run: make test TEST=<test> CFG=<cfg> ISS=GVSOC_TRACE COMP=NO"
                        ],
                        "artifacts": [rtl_file, gvsoc_file]
                    }
                    print(json.dumps(result, indent=2))
                else:
                    print(f"\n[!] ELF MISMATCH at step {i} (PC {r['pc']}):")
                    print(f"    Opcode RTL:   {r['ins']}")
                    print(f"    Opcode GVSOC: {g['ins']}")
                    print(f"    Traces are from different ELF images (CFG mismatch).")
                sys.exit(1)

        common_regs = set(r['regs'].keys()) & set(g['regs'].keys())
        for reg in common_regs:
            if r['regs'][reg] != g['regs'][reg]:
                if json_mode:
                    result = {
                        "status": "divergence",
                        "summary": f"Register {reg} mismatch at step {i} (PC {r['pc']})",
                        "rtl_count": rtl_count,
                        "gvsoc_count": gvsoc_count,
                        "divergence_step": i,
                        "last_common_pc": r['pc'],
                        "divergence_pc_rtl": r['pc'],
                        "divergence_pc_rtl_ins": r['ins'],
                        "divergence_pc_gvsoc": g['pc'],
                        "divergence_pc_gvsoc_ins": g['ins'],
                        "trigger_register": reg,
                        "rtl_value": r['regs'][reg],
                        "gvsoc_value": g['regs'][reg],
                        "rtl_raw": r['raw'],
                        "gvsoc_raw": g['raw'],
                        "loop_pc": loop_pc,
                        "next_actions": [
                            f"check GVSOC model for CSR/register {reg} computation",
                            "inspect +/-20 instructions around divergence_step for root cause"
                        ],
                        "artifacts": [rtl_file, gvsoc_file]
                    }
                    print(json.dumps(result, indent=2))
                else:
                    print(f"\n[!] DATA DIVERGENCE at step {i} (PC {r['pc']}):")
                    print(f"    Register {reg} mismatch:")
                    print(f"    RTL {reg}:   {r['regs'][reg]}")
                    print(f"    GVSOC {reg}: {g['regs'][reg]}")
                    print(f"    RTL raw:   {r['raw']}")
                    print(f"    GVSOC raw: {g['raw']}")
                sys.exit(1)

        ri += 1
        gi += 1
        step += 1

    # The loop exits when either trace is consumed; trailing entries in the longer one
    # are acceptable (post-test cleanup/shutdown only one side logged).
    remaining_rtl = rtl_count - ri
    remaining_gvsoc = gvsoc_count - gi
    shorter_consumed = remaining_rtl == 0 or remaining_gvsoc == 0
    status = "success" if shorter_consumed else "count_mismatch"
    if json_mode:
        result = {
            "status": status,
            "summary": f"{step} instructions verified (PC + data)",
            "rtl_count": rtl_count,
            "gvsoc_count": gvsoc_count,
            "divergence_step": None,
            "loop_pc": loop_pc,
            "next_actions": [] if status == "success" else [
                f"remaining RTL={remaining_rtl} GVSOC={remaining_gvsoc}: investigate missing instructions"
            ],
            "artifacts": [rtl_file, gvsoc_file]
        }
        print(json.dumps(result, indent=2))
    else:
        print(f"\nSUCCESS: {step} instructions verified (PC and data match).")

    if status != "success":
        sys.exit(1)


if __name__ == "__main__":
    json_mode = "--json" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if len(args) < 2:
        print("Usage: compare_traces.py [--json] <rtl_log> <gvsoc_log>", file=sys.stderr)
        sys.exit(1)
    sys.argv = [sys.argv[0]] + args
    compare(json_mode=json_mode)
