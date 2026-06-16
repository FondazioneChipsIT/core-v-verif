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
      echo "interrupt_debug_long: Test PASSED: ${test_name} Log: ${log}"
      return 0
    else
      echo "interrupt_debug_long: Test FAILED: ${test_name} Log: ${log}"
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
echo "interrupt_debug_long: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make clean-bsp clean_test_programs CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=no COV=  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make clean-bsp clean_test_programs CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=no COV=  
popd > /dev/null

# Build:clean_corev-dv 
echo "interrupt_debug_long: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make clean_riscv-dv clone_riscv-dv CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=no COV=  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make clean_riscv-dv clone_riscv-dv CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=no COV=  
popd > /dev/null

# Build:uvmt_cv32e40p 
echo "interrupt_debug_long: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=no COV=  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu SIMULATOR=vsim USE_ISS=no COV=  
popd > /dev/null

# --------------------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------------------

# --> Test: corev_directed_pulp_hwloop_debug_single_step : Build: uvmt_cv32e40p : hwloop single-step debug random test
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_directed_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_directed_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_directed_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_directed_pulp_hwloop_debug_trigger_with_single_step : Build: uvmt_cv32e40p : hwloop debug random test with debug trigger and single step
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_directed_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_directed_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_directed_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_directed_pulp_hwloop_debug_with_int_debug_trigger_and_ebreak : Build: uvmt_cv32e40p : hwloop debug with interrupt, debug trigger and ebreak random test
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_directed_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/0/vsim-corev_directed_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_directed_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_directed_pulp_hwloop_debug_with_int_debug_trigger_single_step : Build: uvmt_cv32e40p : hwloop debug with interrupt, debug trigger and single step random test
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_directed_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_directed_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/0/vsim-corev_directed_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_directed_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_rand_debug : Build: uvmt_cv32e40p : corev_rand_debug
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug
incr_test_counts

# --> Test: corev_rand_debug_ebreak : Build: uvmt_cv32e40p : corev_rand_debug_ebreak
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_debug_ebreak.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_debug_ebreak.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_debug_ebreak.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_debug_ebreak.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_debug_ebreak.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_debug_ebreak.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak
incr_test_counts

# --> Test: corev_rand_debug_ebreak_xpulp : Build: uvmt_cv32e40p : corev_rand_debug_ebreak_xpulp
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak_xpulp/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_debug_ebreak_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak_xpulp
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak_xpulp/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_debug_ebreak_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak_xpulp
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak_xpulp/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_debug_ebreak_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak_xpulp
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak_xpulp/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_debug_ebreak_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak_xpulp
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak_xpulp/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_debug_ebreak_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak_xpulp
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_ebreak_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_ebreak_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_ebreak_xpulp/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_debug_ebreak_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_ebreak_xpulp
incr_test_counts

# --> Test: corev_rand_debug_single_step : Build: uvmt_cv32e40p : corev_rand_debug_single_step
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_debug_single_step.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_debug_single_step.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_debug_single_step.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_debug_single_step.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_debug_single_step.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_debug_single_step.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step
incr_test_counts

# --> Test: corev_rand_debug_single_step_xpulp : Build: uvmt_cv32e40p : corev_rand_debug_single_step_xpulp
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step_xpulp/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_debug_single_step_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step_xpulp
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step_xpulp/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_debug_single_step_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step_xpulp
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step_xpulp/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_debug_single_step_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step_xpulp
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step_xpulp/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_debug_single_step_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step_xpulp
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step_xpulp/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_debug_single_step_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step_xpulp
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_debug_single_step_xpulp
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_debug_single_step_xpulp CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_debug_single_step_xpulp/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_debug_single_step_xpulp.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_debug_single_step_xpulp
incr_test_counts

# --> Test: corev_rand_interrupt : Build: uvmt_cv32e40p : corev_rand_interrupt
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_interrupt.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt
incr_test_counts

# --> Test: corev_rand_interrupt_debug : Build: uvmt_cv32e40p : corev_rand_interrupt_debug
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_debug/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_interrupt_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_debug
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_debug/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_interrupt_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_debug
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_debug/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_interrupt_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_debug
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_debug/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_interrupt_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_debug
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_debug/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_interrupt_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_debug
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_debug/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_interrupt_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_debug
incr_test_counts

# --> Test: corev_rand_interrupt_exception : Build: uvmt_cv32e40p : corev_rand_interrupt_exception
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_exception
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_exception/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_interrupt_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_exception
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_exception
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_exception/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_interrupt_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_exception
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_exception
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_exception/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_interrupt_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_exception
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_exception
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_exception/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_interrupt_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_exception
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_exception
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_exception/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_interrupt_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_exception
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_exception
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_exception/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_interrupt_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_exception
incr_test_counts

# --> Test: corev_rand_interrupt_nested : Build: uvmt_cv32e40p : corev_rand_interrupt_nested
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_nested
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_nested/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_interrupt_nested.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_nested
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_nested
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_nested/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_interrupt_nested.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_nested
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_nested
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_nested/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_interrupt_nested.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_nested
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_nested
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_nested/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_interrupt_nested.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_nested
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_nested
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_nested/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_interrupt_nested.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_nested
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_nested
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_nested CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_nested/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_interrupt_nested.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_nested
incr_test_counts

# --> Test: corev_rand_interrupt_wfi : Build: uvmt_cv32e40p : corev_rand_interrupt_wfi
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_wfi
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_interrupt_wfi.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_wfi
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_interrupt_wfi.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_wfi
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_interrupt_wfi.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_wfi
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_interrupt_wfi.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_wfi
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_interrupt_wfi.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_interrupt_wfi
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_interrupt_wfi.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi
incr_test_counts

# --> Test: corev_rand_interrupt_wfi_mem_stress : Build: uvmt_cv32e40p : corev_rand_interrupt_wfi_mem_stress
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" : corev_rand_interrupt_wfi_mem_stress
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi_mem_stress/disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_interrupt_wfi_mem_stress.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi_mem_stress
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" : corev_rand_interrupt_wfi_mem_stress
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi_mem_stress/disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_interrupt_wfi_mem_stress.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi_mem_stress
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" : corev_rand_interrupt_wfi_mem_stress
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi_mem_stress/disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_interrupt_wfi_mem_stress.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi_mem_stress
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" : corev_rand_interrupt_wfi_mem_stress
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi_mem_stress/disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_interrupt_wfi_mem_stress.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi_mem_stress
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" : corev_rand_interrupt_wfi_mem_stress
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi_mem_stress/disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_interrupt_wfi_mem_stress.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi_mem_stress
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" : corev_rand_interrupt_wfi_mem_stress
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_interrupt_wfi_mem_stress CFG_PLUSARGS="+UVM_TIMEOUT=50000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_interrupt_wfi_mem_stress/disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_interrupt_wfi_mem_stress.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_interrupt_wfi_mem_stress
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_debug_single_step : Build: uvmt_cv32e40p : hwloop single-step debug random test
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop single-step debug random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_debug_trigger_with_single_step : Build: uvmt_cv32e40p : hwloop debug random test with debug trigger and single step
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug random test with debug trigger and single step
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_debug_with_int_debug_trigger_and_ebreak : Build: uvmt_cv32e40p : hwloop debug with interrupt, debug trigger and ebreak random test
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/0/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/1/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/2/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/3/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/4/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and ebreak random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_ebreak,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_ebreak__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/5/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_debug_with_int_debug_trigger_single_step : Build: uvmt_cv32e40p : hwloop debug with interrupt, debug trigger and single step random test
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/0/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/1/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/2/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/3/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/4/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop debug with interrupt, debug trigger and single step random test
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_debug CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_debug/debug_single_step_en__debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/5/vsim-corev_rand_pulp_hwloop_debug.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_debug
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_exception_single_step_debug : Build: uvmt_cv32e40p : hwloop exception test with single step debug
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with single step debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/0/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with single step debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/1/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with single step debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/2/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with single step debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/3/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with single step debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/4/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with single step debug
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="debug_single_step_en,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_single_step_en__disable_all_trn_logs__floating_pt_instr_en/5/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts

# --> Test: corev_rand_pulp_hwloop_exception_with_int_debug_trigger : Build: uvmt_cv32e40p : hwloop exception test with interrupt and debug trigger
  
# --> Test (Index: 0): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with interrupt and debug trigger
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/0/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 1): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with interrupt and debug trigger
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=1 RUN_INDEX=1 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/1/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 2): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with interrupt and debug trigger
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=2 RUN_INDEX=2 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/2/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 3): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with interrupt and debug trigger
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=3 RUN_INDEX=3 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/3/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 4): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with interrupt and debug trigger
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=4 RUN_INDEX=4 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/4/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts
  
# --> Test (Index: 5): make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hwloop exception test with interrupt and debug trigger
echo "interrupt_debug_long: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test TEST=corev_rand_pulp_hwloop_exception CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=5 RUN_INDEX=5 TEST_CFG_FILE="gen_rand_int,debug_trigger_basic,disable_all_trn_logs,floating_pt_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu/corev_rand_pulp_hwloop_exception/debug_trigger_basic__disable_all_trn_logs__floating_pt_instr_en__gen_rand_int/5/vsim-corev_rand_pulp_hwloop_exception.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_pulp_hwloop_exception
incr_test_counts


echo "interrupt_debug_long: Passing tests: ${pass_count}"
echo "interrupt_debug_long: Failing tests: ${fail_count}"

if [ ${fail_count} -ne 0 ]; then
    exit 1
fi
exit 0