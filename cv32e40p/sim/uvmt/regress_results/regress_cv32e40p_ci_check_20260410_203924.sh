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
      echo "regress_cv32e40p_ci_check_20260410_203924: Test PASSED: ${test_name} Log: ${log}"
      return 0
    else
      echo "regress_cv32e40p_ci_check_20260410_203924: Test FAILED: ${test_name} Log: ${log}"
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

# Build:uvmt_cv32e40p 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=default SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp_fpu 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp_fpu_1cyclat 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_1cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_1cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp_fpu_2cyclat 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_2cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_2cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp_fpu_zfinx 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp_fpu_zfinx_1cyclat 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# Build:uvmt_cv32e40p_pulp_fpu_zfinx_2cyclat 
echo "regress_cv32e40p_ci_check_20260410_203924: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat SIMULATOR=vsim USE_ISS=YES ISS=GVSOC COV=YES  ENABLE_TRACE_LOG=NO
popd > /dev/null

# --------------------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------------------

# --> Test: corev_rand_arithmetic_base_test : Build: uvmt_cv32e40p : Generated corev-dv random arithmetic test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv random arithmetic test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//0/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test : Generated corev-dv random arithmetic test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_arithmetic_base_test//1/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts

# --> Test: corev_rand_fp_instr_sanity_test : Build: uvmt_cv32e40p_pulp_fpu_zfinx : 
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/corev_rand_fp_instr_sanity_test/floating_pt_zfinx_instr_en/0/vsim-corev_rand_fp_instr_sanity_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_fp_instr_sanity_test
incr_test_counts

# --> Test: corev_rand_fp_instr_sanity_test : Build: uvmt_cv32e40p_pulp_fpu_zfinx_1cyclat : 
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx_1cyclat/corev_rand_fp_instr_sanity_test/floating_pt_zfinx_instr_en/0/vsim-corev_rand_fp_instr_sanity_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_fp_instr_sanity_test
incr_test_counts

# --> Test: corev_rand_fp_instr_sanity_test : Build: uvmt_cv32e40p_pulp_fpu_zfinx_2cyclat : 
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_fp_instr_sanity_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx_2cyclat/corev_rand_fp_instr_sanity_test/floating_pt_zfinx_instr_en/0/vsim-corev_rand_fp_instr_sanity_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_fp_instr_sanity_test
incr_test_counts

# --> Test: corev_rand_instr_test : Build: uvmt_cv32e40p : Generated corev-dv random instruction test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//0/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test : Generated corev-dv random instruction test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_instr_test//1/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts

# --> Test: corev_rand_interrupt : Build: uvmt_cv32e40p : Interrupt random test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt : Interrupt random test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_interrupt//0/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt : Interrupt random test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_interrupt//1/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts

# --> Test: corev_rand_jump_stress_test : Build: uvmt_cv32e40p : Generated corev-dv jump stress test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//0/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test : Generated corev-dv jump stress test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/corev_rand_jump_stress_test//1/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_test : Build: uvmt_cv32e40p_pulp : 
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_pulp_hwloop_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_pulp_hwloop_test CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_pulp_hwloop_test CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp/corev_rand_pulp_hwloop_test//0/vsim-corev_rand_pulp_hwloop_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_test
incr_test_counts

# --> Test: corev_rand_pulp_instr_test : Build: uvmt_cv32e40p_pulp : 
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_pulp_instr_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_pulp_instr_test CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_pulp_instr_test CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp/corev_rand_pulp_instr_test//0/vsim-corev_rand_pulp_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_instr_test
incr_test_counts

# --> Test: csr_instructions : Build: uvmt_cv32e40p : CSR Instruction Test
  
# --> Test (Index: 0): make test COREV=YES TEST=csr_instructions : CSR Instruction Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=csr_instructions CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=csr_instructions CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/csr_instructions//0/vsim-csr_instructions.log


# failed=0
check_log ${log} "SIMULATION PASSED" csr_instructions
incr_test_counts

# --> Test: debug_test : Build: uvmt_cv32e40p : 
  
# --> Test (Index: 0): make test COREV=YES TEST=debug_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=debug_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=debug_test CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/debug_test//0/vsim-debug_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" debug_test
incr_test_counts

# --> Test: debug_test : Build: uvmt_cv32e40p_pulp : 
  
# --> Test (Index: 0): make test COREV=YES TEST=debug_test : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=debug_test CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=debug_test CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp/debug_test//0/vsim-debug_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" debug_test
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp_fpu : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp_fpu_1cyclat : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_1cyclat/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp_fpu_2cyclat : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_2cyclat/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp_fpu_zfinx : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp_fpu_zfinx_1cyclat : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx_1cyclat/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p_pulp_fpu_zfinx_2cyclat : UVM Hello World Test
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world : UVM Hello World Test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx_2cyclat/hello-world//0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: illegal : Build: uvmt_cv32e40p : 
  
# --> Test (Index: 0): make test COREV=YES TEST=illegal : 
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=illegal CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=illegal CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/illegal//0/vsim-illegal.log


# failed=0
check_log ${log} "SIMULATION PASSED" illegal
incr_test_counts

# --> Test: interrupt_test : Build: uvmt_cv32e40p_pulp_fpu_zfinx : Interrupt directed test
  
# --> Test (Index: 0): make test COREV=YES TEST=interrupt_test : Interrupt directed test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=interrupt_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=interrupt_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/interrupt_test/floating_pt_zfinx_instr_en/0/vsim-interrupt_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" interrupt_test
incr_test_counts

# --> Test: interrupt_test : Build: uvmt_cv32e40p_pulp_fpu_zfinx_1cyclat : Interrupt directed test
  
# --> Test (Index: 0): make test COREV=YES TEST=interrupt_test : Interrupt directed test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=interrupt_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=interrupt_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_1cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx_1cyclat/interrupt_test/floating_pt_zfinx_instr_en/0/vsim-interrupt_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" interrupt_test
incr_test_counts

# --> Test: interrupt_test : Build: uvmt_cv32e40p_pulp_fpu_zfinx_2cyclat : Interrupt directed test
  
# --> Test (Index: 0): make test COREV=YES TEST=interrupt_test : Interrupt directed test
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=interrupt_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=interrupt_test CV_CORE=cv32e40p CFG=pulp_fpu_zfinx_2cyclat COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="floating_pt_zfinx_instr_en"  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx_2cyclat/interrupt_test/floating_pt_zfinx_instr_en/0/vsim-interrupt_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" interrupt_test
incr_test_counts

# --> Test: riscv_arithmetic_basic_test_0 : Build: uvmt_cv32e40p : Static riscv-dv arithmetic test 0
  
# --> Test (Index: 0): make test COREV=YES TEST=riscv_arithmetic_basic_test_0 : Static riscv-dv arithmetic test 0
echo "regress_cv32e40p_ci_check_20260410_203924: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CV_CORE=cv32e40p CFG=default COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=YES ISS=GVSOC COV=YES SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE=""  ENABLE_TRACE_LOG=NO >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/default/riscv_arithmetic_basic_test_0//0/vsim-riscv_arithmetic_basic_test_0.log


# failed=0
check_log ${log} "SIMULATION PASSED" riscv_arithmetic_basic_test_0
incr_test_counts


echo "regress_cv32e40p_ci_check_20260410_203924: Passing tests: ${pass_count}"
echo "regress_cv32e40p_ci_check_20260410_203924: Failing tests: ${fail_count}"

if [ ${fail_count} -ne 0 ]; then
    exit 1
fi
exit 0