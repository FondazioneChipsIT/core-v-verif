#!/bin/bash

# --------------------------------------------------------------------------------------
# Variables
# --------------------------------------------------------------------------------------
pass_count=0
fail_count=0
failed=0

# --------------------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------------------
check_log () {
    log=$1
    simulation_passed="$2"
    test_name=$3
    pass_cond=0
    failed=0

    if grep -qi "Errors:\s\+0" ${log}; then
    if grep -q "${simulation_passed}" ${log}; then
      ((pass_cond+=1))
    fi
    fi

    if [[ ${pass_cond} == 1 ]]; then
      echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Test PASSED: ${test_name} Log: ${log}"
      return 0
    else
      echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Test FAILED: ${test_name} Log: ${log}"
      failed=1
    fi

}

incr_test_counts () {
    if [[ ${failed} == "0" ]]; then
        ((pass_count+=1))
    else
        ((fail_count+=1))
    fi
}

# --------------------------------------------------------------------------------------
# Builds
# --------------------------------------------------------------------------------------

# Build:clean_fw 
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make clean-bsp clean_test_programs CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make clean-bsp clean_test_programs CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:corev-dv 
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make clean_riscv-dv comp_corev-dv CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=NO  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make clean_riscv-dv comp_corev-dv CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=NO  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p 
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# --------------------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------------------

# --> Test: branch_zero : Build: uvmt_cv32e40p : Branch test with zero offsets
  
# --> Test (Index: 0): make test COREV=YES TEST=branch_zero : Branch test with zero offsets
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=branch_zero CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=branch_zero CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/branch_zero//0/vsim-branch_zero.log


# failed=0
check_log ${log} "SIMULATION PASSED" branch_zero
incr_test_counts

# --> Test: corev_rand_arithmetic_base_test : Build: uvmt_cv32e40p : Generated corev-dv arithmetic test (reduced 5 seeds)
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv arithmetic test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//0/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv arithmetic test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//1/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv arithmetic test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//2/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv arithmetic test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//3/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv arithmetic test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//4/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts

# --> Test: corev_rand_instr_long_stall : Build: uvmt_cv32e40p : Generated corev-dv random instruction test with long stalls (reduced 4 seeds)
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall : Generated corev-dv random instruction test with long stalls (reduced 4 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_long_stall//0/vsim-corev_rand_instr_long_stall.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_long_stall
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall : Generated corev-dv random instruction test with long stalls (reduced 4 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_long_stall//1/vsim-corev_rand_instr_long_stall.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_long_stall
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall : Generated corev-dv random instruction test with long stalls (reduced 4 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_long_stall//2/vsim-corev_rand_instr_long_stall.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_long_stall
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall : Generated corev-dv random instruction test with long stalls (reduced 4 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_long_stall//3/vsim-corev_rand_instr_long_stall.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_long_stall
incr_test_counts

# --> Test: corev_rand_instr_test : Build: uvmt_cv32e40p : Generated corev-dv random instruction test (reduced 5 seeds)
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//0/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//1/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//2/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//3/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//4/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts

# --> Test: corev_rand_jump_stress_test : Build: uvmt_cv32e40p : Generated corev-dv jump stress test (reduced 5 seeds)
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//0/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//1/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//2/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//3/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test (reduced 5 seeds)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//4/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts

# --> Test: csr_instr_asm : Build: uvmt_cv32e40p : CSR instruction assembly test
  
# --> Test (Index: 0): make test COREV=YES TEST=csr_instr_asm : CSR instruction assembly test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=csr_instr_asm CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=csr_instr_asm CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/csr_instr_asm//0/vsim-csr_instr_asm.log


# failed=0
check_log ${log} "SIMULATION PASSED" csr_instr_asm
incr_test_counts

# --> Test: csr_instructions : Build: uvmt_cv32e40p : CSR instruction test
  
# --> Test (Index: 0): make test COREV=YES TEST=csr_instructions : CSR instruction test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=csr_instructions CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=csr_instructions CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/csr_instructions//0/vsim-csr_instructions.log


# failed=0
check_log ${log} "SIMULATION PASSED" csr_instructions
incr_test_counts

# --> Test: cv32e40p_csr_access_test : Build: uvmt_cv32e40p : CSR Access Mode Test
  
# --> Test (Index: 0): make test COREV=YES TEST=cv32e40p_csr_access_test : CSR Access Mode Test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=cv32e40p_csr_access_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=cv32e40p_csr_access_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/cv32e40p_csr_access_test//0/vsim-cv32e40p_csr_access_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" cv32e40p_csr_access_test
incr_test_counts

# --> Test: cv32e40p_readonly_csr_access_test : Build: uvmt_cv32e40p : CSR Read-only Access Mode Test
  
# --> Test (Index: 0): make test COREV=YES TEST=cv32e40p_readonly_csr_access_test : CSR Read-only Access Mode Test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=cv32e40p_readonly_csr_access_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=cv32e40p_readonly_csr_access_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/cv32e40p_readonly_csr_access_test//0/vsim-cv32e40p_readonly_csr_access_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" cv32e40p_readonly_csr_access_test
incr_test_counts

# --> Test: dhrystone : Build: uvmt_cv32e40p : Dhrystone test
  
# --> Test (Index: 0): make test COREV=YES TEST=dhrystone : Dhrystone test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=dhrystone CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=dhrystone CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/dhrystone//0/vsim-dhrystone.log


# failed=0
check_log ${log} "SIMULATION PASSED" dhrystone
incr_test_counts

# --> Test: fibonacci : Build: uvmt_cv32e40p : Fibonacci test
  
# --> Test (Index: 0): make test COREV=YES TEST=fibonacci : Fibonacci test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=fibonacci CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=fibonacci CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/fibonacci//0/vsim-fibonacci.log


# failed=0
check_log ${log} "SIMULATION PASSED" fibonacci
incr_test_counts

# --> Test: generic_exception_test : Build: uvmt_cv32e40p : Generic exception test
  
# --> Test (Index: 0): make test COREV=YES TEST=generic_exception_test : Generic exception test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=generic_exception_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=generic_exception_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/generic_exception_test//0/vsim-generic_exception_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" generic_exception_test
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p : uvm_hello_world_test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : uvm_hello_world_test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hpmcounter_basic_test : Build: uvmt_cv32e40p : Hardware performance counter basic test
  
# --> Test (Index: 0): make test COREV=YES TEST=hpmcounter_basic_test : Hardware performance counter basic test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hpmcounter_basic_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hpmcounter_basic_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/hpmcounter_basic_test//0/vsim-hpmcounter_basic_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" hpmcounter_basic_test
incr_test_counts

# --> Test: hpmcounter_hazard_test : Build: uvmt_cv32e40p : Hardware performance counter hazard test
  
# --> Test (Index: 0): make test COREV=YES TEST=hpmcounter_hazard_test : Hardware performance counter hazard test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hpmcounter_hazard_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hpmcounter_hazard_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/hpmcounter_hazard_test//0/vsim-hpmcounter_hazard_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" hpmcounter_hazard_test
incr_test_counts

# --> Test: illegal : Build: uvmt_cv32e40p : Illegal-riscv-tests
  
# --> Test (Index: 0): make test COREV=YES TEST=illegal : Illegal-riscv-tests
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=illegal CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=illegal CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/illegal//0/vsim-illegal.log


# failed=0
check_log ${log} "SIMULATION PASSED" illegal
incr_test_counts

# --> Test: illegal_instr_test : Build: uvmt_cv32e40p : Illegal instruction test
  
# --> Test (Index: 0): make test COREV=YES TEST=illegal_instr_test : Illegal instruction test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=illegal_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=illegal_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/illegal_instr_test//0/vsim-illegal_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" illegal_instr_test
incr_test_counts

# --> Test: isa_fcov_holes : Build: uvmt_cv32e40p : ISA function coverage test
  
# --> Test (Index: 0): make test COREV=YES TEST=isa_fcov_holes : ISA function coverage test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=isa_fcov_holes CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=isa_fcov_holes CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/isa_fcov_holes//0/vsim-isa_fcov_holes.log


# failed=0
check_log ${log} "SIMULATION PASSED" isa_fcov_holes
incr_test_counts

# --> Test: mhpmcounter29_csr_access_test_1 : Build: uvmt_cv32e40p : Hardware performance counter full access coverage test 1
  
# --> Test (Index: 0): make test COREV=YES TEST=mhpmcounter29_csr_access_test_1 : Hardware performance counter full access coverage test 1
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=mhpmcounter29_csr_access_test_1 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=mhpmcounter29_csr_access_test_1 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/mhpmcounter29_csr_access_test_1//0/vsim-mhpmcounter29_csr_access_test_1.log


# failed=0
check_log ${log} "SIMULATION PASSED" mhpmcounter29_csr_access_test_1
incr_test_counts

# --> Test: misalign : Build: uvmt_cv32e40p : Misalign test
  
# --> Test (Index: 0): make test COREV=YES TEST=misalign : Misalign test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=misalign CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=misalign CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/misalign//0/vsim-misalign.log


# failed=0
check_log ${log} "SIMULATION PASSED" misalign
incr_test_counts

# --> Test: modeled_csr_por : Build: uvmt_cv32e40p : Modeled CSR PoR test
  
# --> Test (Index: 0): make test COREV=YES TEST=modeled_csr_por : Modeled CSR PoR test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=modeled_csr_por CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=modeled_csr_por CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/modeled_csr_por//0/vsim-modeled_csr_por.log


# failed=0
check_log ${log} "SIMULATION PASSED" modeled_csr_por
incr_test_counts

# --> Test: perf_counters_instructions : Build: uvmt_cv32e40p : Performance counter test (esercita mcountinhibit)
  
# --> Test (Index: 0): make test COREV=YES TEST=perf_counters_instructions : Performance counter test (esercita mcountinhibit)
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=perf_counters_instructions CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=perf_counters_instructions CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/perf_counters_instructions//0/vsim-perf_counters_instructions.log


# failed=0
check_log ${log} "SIMULATION PASSED" perf_counters_instructions
incr_test_counts

# --> Test: requested_csr_por : Build: uvmt_cv32e40p : CSR PoR test
  
# --> Test (Index: 0): make test COREV=YES TEST=requested_csr_por : CSR PoR test
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=requested_csr_por CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=requested_csr_por CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/requested_csr_por//0/vsim-requested_csr_por.log


# failed=0
check_log ${log} "SIMULATION PASSED" requested_csr_por
incr_test_counts

# --> Test: riscv_arithmetic_basic_test_0 : Build: uvmt_cv32e40p : Static riscv-dv arithmetic test 0
  
# --> Test (Index: 0): make test COREV=YES TEST=riscv_arithmetic_basic_test_0 : Static riscv-dv arithmetic test 0
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/riscv_arithmetic_basic_test_0//0/vsim-riscv_arithmetic_basic_test_0.log


# failed=0
check_log ${log} "SIMULATION PASSED" riscv_arithmetic_basic_test_0
incr_test_counts

# --> Test: riscv_arithmetic_basic_test_1 : Build: uvmt_cv32e40p : Static riscv-dv arithmetic test 1
  
# --> Test (Index: 0): make test COREV=YES TEST=riscv_arithmetic_basic_test_1 : Static riscv-dv arithmetic test 1
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=riscv_arithmetic_basic_test_1 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=riscv_arithmetic_basic_test_1 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/riscv_arithmetic_basic_test_1//0/vsim-riscv_arithmetic_basic_test_1.log


# failed=0
check_log ${log} "SIMULATION PASSED" riscv_arithmetic_basic_test_1
incr_test_counts


echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Passing tests: ${pass_count}"
echo "regress_cv32e40p_targeted_validation_20260522_20260525_102412: Failing tests: ${fail_count}"

if [ ${fail_count} -ne 0 ]; then
    exit 1
fi
exit 0