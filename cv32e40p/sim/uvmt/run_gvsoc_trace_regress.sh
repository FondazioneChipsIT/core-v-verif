#!/bin/bash
# GVSOC_TRACE regression (debug/triage tool, not the maintained co-sim path):
# per test, RTL-only sim -> standalone gvrun -> bin/compare_traces.py.
source /etc/profile.d/modules.sh 2>/dev/null
module load "${QUESTA_MODULE:-questa/2025.3}" 2>/dev/null
eval "$(micromamba shell hook --shell=bash)" 2>/dev/null
micromamba activate "${MAMBA_ENV:-gvsoc_env_3_12}" 2>/dev/null

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Tests grouped by cfg (order matters: first per cfg compiles the testbench).
TESTS=(
  "hello-world default"
  "fibonacci default"
  "dhrystone default"
  "misalign default"
  "illegal default"
  "riscv_ebreak_test_0 default"
  "riscv_arithmetic_basic_test_0 default"
  "riscv_arithmetic_basic_test_1 default"
  "illegal_instr_test default"
  "csr_instructions default"
  "csr_instr_asm default"
  "cv32e40p_csr_access_test default"
  "cv32e40p_readonly_csr_access_test default"
  "requested_csr_por default"
  "modeled_csr_por default"
  "hpmcounter_basic_test default"
  "hpmcounter_hazard_test default"
  "perf_counters_instructions default"
  "mhpmcounter29_csr_access_test_1 default"
  "generic_exception_test default"
  "isa_fcov_holes default"
  "fibonacci pulp"
  "pulp_general_alu pulp"
  "pulp_hardware_loop pulp"
  "pulp_bit_manipulation pulp"
  "pulp_multiply_accumulate pulp"
  "pulp_post_increment_load_store pulp"
  "custom_opcode_illegal_test pulp"
  "csr_instructions pulp_fpu"
  "cv32e40p_csr_access_test pulp_fpu"
  "cv32e40p_readonly_csr_access_test pulp_fpu"
)

MAX_PARALLEL=4
RESULTS_FILE=$(mktemp /tmp/gvsoc_trace_results.XXXXXX)
LOGDIR=${GVSOC_TRACE_LOGDIR:-/tmp}

# PASS = compare_traces.py "SUCCESS: N instructions verified" with N>=1.
# N==0 means an empty RTL trace (nothing compared) -> FAIL, not a pass.
detect_pass() { grep -qE "SUCCESS:[[:space:]]*[1-9][0-9]* instructions verified" "$1" 2>/dev/null; }

run_test() {
  local test=$1 cfg=$2 comp=$3
  local log="${LOGDIR}/gvsoc_trace_${test}_${cfg}.log"
  make test TEST="${test}" CFG="${cfg}" ISS=GVSOC_TRACE COMP="${comp}" > "${log}" 2>&1
  if detect_pass "${log}"; then
    echo "PASS ${test}/${cfg}" >> "${RESULTS_FILE}"
  else
    echo "FAIL ${test}/${cfg}" >> "${RESULTS_FILE}"
  fi
}

echo "Starting GVSOC_TRACE regression: ${#TESTS[@]} tests, max ${MAX_PARALLEL} parallel"
echo "Results file: ${RESULTS_FILE}"
echo "============================================================"

declare -A CFG_COMPILED
pids=()
for entry in "${TESTS[@]}"; do
  test=$(echo "$entry" | awk '{print $1}')
  cfg=$(echo "$entry" | awk '{print $2}')

  if [ -z "${CFG_COMPILED[$cfg]}" ]; then
    # First test of this cfg compiles the TB serially (COMP=YES); the rest run
    # COMP=NO in parallel, so no build race.
    echo "[comp] CFG=${cfg} via TEST=${test} (COMP=YES, serial) ..."
    run_test "$test" "$cfg" "YES"
    CFG_COMPILED[$cfg]=1
  else
    run_test "$test" "$cfg" "NO" &
    pids+=($!)
    if [ ${#pids[@]} -ge $MAX_PARALLEL ]; then
      wait "${pids[0]}"
      pids=("${pids[@]:1}")
    fi
  fi
done

for pid in "${pids[@]}"; do wait "$pid"; done

echo "============================================================"
P=$(grep -c '^PASS ' "${RESULTS_FILE}" 2>/dev/null)
F=$(grep -c '^FAIL ' "${RESULTS_FILE}" 2>/dev/null)
echo "GVSOC_TRACE regression complete: ${P}/${#TESTS[@]} PASS, ${F} FAIL"
if [ "${F}" -gt 0 ]; then
  echo "--- FAILURES ---"
  grep '^FAIL ' "${RESULTS_FILE}"
fi
echo "Per-test logs: ${LOGDIR}/gvsoc_trace_<test>_<cfg>.log"
