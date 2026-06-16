#!/bin/bash
# GVSOC_TRACE regression — 31 test pairs
source /etc/profile.d/modules.sh 2>/dev/null
module load "${QUESTA_MODULE:-questa/2025.3}" 2>/dev/null
eval "$(micromamba shell hook --shell=bash)" 2>/dev/null
micromamba activate "${MAMBA_ENV:-gvsoc_env_3_12}" 2>/dev/null

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

PASS=0
FAIL=0
RESULTS=""
MAX_PARALLEL=4

run_test() {
  local test=$1
  local cfg=$2
  local logdir="vsim_results/${cfg}/${test}.gvsoc_trace"

  make test TEST=${test} CFG=${cfg} ISS=GVSOC_TRACE COMP=NO 2>&1 > /tmp/gvsoc_trace_${test}_${cfg}.log
  local rc=$?

  if grep -q "SIMULATION PASSED" /tmp/gvsoc_trace_${test}_${cfg}.log 2>/dev/null; then
    echo "PASS ${test}/${cfg}"
  elif grep -q "ALL TRACE COMPARISONS PASSED" /tmp/gvsoc_trace_${test}_${cfg}.log 2>/dev/null; then
    echo "PASS ${test}/${cfg}"
  else
    echo "FAIL ${test}/${cfg}"
  fi
}

echo "Starting GVSOC_TRACE regression: ${#TESTS[@]} tests, max ${MAX_PARALLEL} parallel"
echo "============================================================"

pids=()
for entry in "${TESTS[@]}"; do
  test=$(echo $entry | awk '{print $1}')
  cfg=$(echo $entry | awk '{print $2}')

  run_test "$test" "$cfg" &
  pids+=($!)

  if [ ${#pids[@]} -ge $MAX_PARALLEL ]; then
    wait "${pids[0]}"
    pids=("${pids[@]:1}")
  fi
done

# Wait for remaining
for pid in "${pids[@]}"; do
  wait $pid
done

echo "============================================================"
echo "GVSOC_TRACE regression complete"
