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
      echo "legacy_v1: Test PASSED: ${test_name} Log: ${log}"
      return 0
    else
      echo "legacy_v1: Test FAILED: ${test_name} Log: ${log}"
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
echo "legacy_v1: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make clean-bsp clean_test_programs CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=no COV=  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make clean-bsp clean_test_programs CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=no COV=  
popd > /dev/null

# Build:clean_corev-dv 
echo "legacy_v1: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make clean_riscv-dv clone_riscv-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=no COV=  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make clean_riscv-dv clone_riscv-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=no COV=  
popd > /dev/null

# Build:uvmt_cv32e40p 
echo "legacy_v1: Running build: [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=no COV=  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make comp comp_corev-dv CV_CORE=cv32e40p CFG=pulp_fpu_zfinx SIMULATOR=vsim USE_ISS=no COV=  
popd > /dev/null

# --------------------------------------------------------------------------------------
# Tests
# --------------------------------------------------------------------------------------

# --> Test: all_csr_por : Build: uvmt_cv32e40p : all_csr_por
  
# --> Test (Index: 0): make test COREV=YES TEST=all_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=300000000" : all_csr_por
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=all_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=300000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=all_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=300000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/all_csr_por/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-all_csr_por.log


# failed=0
check_log ${log} "SIMULATION PASSED" all_csr_por
incr_test_counts

# --> Test: branch_zero : Build: uvmt_cv32e40p : branch_zero
  
# --> Test (Index: 0): make test COREV=YES TEST=branch_zero CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : branch_zero
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=branch_zero CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=branch_zero CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/branch_zero/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-branch_zero.log


# failed=0
check_log ${log} "SIMULATION PASSED" branch_zero
incr_test_counts

# --> Test: coremark : Build: uvmt_cv32e40p : coremark
  
# --> Test (Index: 0): make test COREV=YES TEST=coremark CFG_PLUSARGS="+UVM_TIMEOUT=3000000000" : coremark
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=coremark CFG_PLUSARGS="+UVM_TIMEOUT=3000000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=coremark CFG_PLUSARGS="+UVM_TIMEOUT=3000000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/coremark/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-coremark.log


# failed=0
check_log ${log} "SIMULATION PASSED" coremark
incr_test_counts

# --> Test: corev_rand_arithmetic_base_test : Build: uvmt_cv32e40p : corev_rand_arithmetic_base_test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_arithmetic_base_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_arithmetic_base_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/corev_rand_arithmetic_base_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-corev_rand_arithmetic_base_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_arithmetic_base_test
incr_test_counts

# --> Test: corev_rand_illegal_instr_test : Build: uvmt_cv32e40p : corev_rand_illegal_instr_test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_illegal_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_illegal_instr_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_illegal_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_illegal_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/corev_rand_illegal_instr_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-corev_rand_illegal_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_illegal_instr_test
incr_test_counts

# --> Test: corev_rand_instr_long_stall : Build: uvmt_cv32e40p : corev_rand_instr_long_stall
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_instr_long_stall
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_long_stall CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/corev_rand_instr_long_stall/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-corev_rand_instr_long_stall.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_long_stall
incr_test_counts

# --> Test: corev_rand_instr_test : Build: uvmt_cv32e40p : corev_rand_instr_test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_instr_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/corev_rand_instr_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-corev_rand_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_instr_test
incr_test_counts

# --> Test: corev_rand_jump_stress_test : Build: uvmt_cv32e40p : corev_rand_jump_stress_test
  
# --> Test (Index: 0): make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : corev_rand_jump_stress_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make gen_corev-dv test COREV=YES TEST=corev_rand_jump_stress_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/corev_rand_jump_stress_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-corev_rand_jump_stress_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" corev_rand_jump_stress_test
incr_test_counts

# --> Test: csr_instr_asm : Build: uvmt_cv32e40p : csr_instr_asm
  
# --> Test (Index: 0): make test COREV=YES TEST=csr_instr_asm CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : csr_instr_asm
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=csr_instr_asm CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=csr_instr_asm CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/csr_instr_asm/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-csr_instr_asm.log


# failed=0
check_log ${log} "SIMULATION PASSED" csr_instr_asm
incr_test_counts

# --> Test: cv32e40p_readonly_csr_access_test : Build: uvmt_cv32e40p : cv32e40p_readonly_csr_access_test
  
# --> Test (Index: 0): make test COREV=YES TEST=cv32e40p_readonly_csr_access_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : cv32e40p_readonly_csr_access_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=cv32e40p_readonly_csr_access_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=cv32e40p_readonly_csr_access_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/cv32e40p_readonly_csr_access_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-cv32e40p_readonly_csr_access_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" cv32e40p_readonly_csr_access_test
incr_test_counts

# --> Test: debug_test_trigger : Build: uvmt_cv32e40p : debug_test_trigger
  
# --> Test (Index: 0): make test COREV=YES TEST=debug_test_trigger CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : debug_test_trigger
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=debug_test_trigger CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=debug_test_trigger CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/debug_test_trigger/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-debug_test_trigger.log


# failed=0
check_log ${log} "SIMULATION PASSED" debug_test_trigger
incr_test_counts

# --> Test: dhrystone : Build: uvmt_cv32e40p : dhrystone
  
# --> Test (Index: 0): make test COREV=YES TEST=dhrystone CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : dhrystone
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=dhrystone CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=dhrystone CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/dhrystone/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-dhrystone.log


# failed=0
check_log ${log} "SIMULATION PASSED" dhrystone
incr_test_counts

# --> Test: fibonacci : Build: uvmt_cv32e40p : fibonacci
  
# --> Test (Index: 0): make test COREV=YES TEST=fibonacci CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : fibonacci
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=fibonacci CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=fibonacci CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/fibonacci/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-fibonacci.log


# failed=0
check_log ${log} "SIMULATION PASSED" fibonacci
incr_test_counts

# --> Test: generic_exception_test : Build: uvmt_cv32e40p : generic_exception_test
  
# --> Test (Index: 0): make test COREV=YES TEST=generic_exception_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : generic_exception_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=generic_exception_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=generic_exception_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/generic_exception_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-generic_exception_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" generic_exception_test
incr_test_counts

# --> Test: hello-world : Build: uvmt_cv32e40p : world
  
# --> Test (Index: 0): make test COREV=YES TEST=hello-world CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : world
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hello-world CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hello-world CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/hello-world/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-hello-world.log


# failed=0
check_log ${log} "SIMULATION PASSED" hello-world
incr_test_counts

# --> Test: hpmcounter_basic_test : Build: uvmt_cv32e40p : hpmcounter_basic_test
  
# --> Test (Index: 0): make test COREV=YES TEST=hpmcounter_basic_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hpmcounter_basic_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hpmcounter_basic_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hpmcounter_basic_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/hpmcounter_basic_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-hpmcounter_basic_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" hpmcounter_basic_test
incr_test_counts

# --> Test: hpmcounter_hazard_test : Build: uvmt_cv32e40p : hpmcounter_hazard_test
  
# --> Test (Index: 0): make test COREV=YES TEST=hpmcounter_hazard_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : hpmcounter_hazard_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=hpmcounter_hazard_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=hpmcounter_hazard_test CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/hpmcounter_hazard_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-hpmcounter_hazard_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" hpmcounter_hazard_test
incr_test_counts

# --> Test: illegal : Build: uvmt_cv32e40p : illegal
  
# --> Test (Index: 0): make test COREV=YES TEST=illegal CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : illegal
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=illegal CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=illegal CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/illegal/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-illegal.log


# failed=0
check_log ${log} "SIMULATION PASSED" illegal
incr_test_counts

# --> Test: illegal_instr_test : Build: uvmt_cv32e40p : illegal_instr_test
  
# --> Test (Index: 0): make test COREV=YES TEST=illegal_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=3000000000" : illegal_instr_test
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=illegal_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=3000000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=illegal_instr_test CFG_PLUSARGS="+UVM_TIMEOUT=3000000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/illegal_instr_test/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-illegal_instr_test.log


# failed=0
check_log ${log} "SIMULATION PASSED" illegal_instr_test
incr_test_counts

# --> Test: isa_fcov_holes : Build: uvmt_cv32e40p : isa_fcov_holes
  
# --> Test (Index: 0): make test COREV=YES TEST=isa_fcov_holes CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : isa_fcov_holes
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=isa_fcov_holes CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=isa_fcov_holes CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/isa_fcov_holes/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-isa_fcov_holes.log


# failed=0
check_log ${log} "SIMULATION PASSED" isa_fcov_holes
incr_test_counts

# --> Test: load_store_rs1_zero : Build: uvmt_cv32e40p : load_store_rs1_zero
  
# --> Test (Index: 0): make test COREV=YES TEST=load_store_rs1_zero CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : load_store_rs1_zero
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=load_store_rs1_zero CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=load_store_rs1_zero CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/load_store_rs1_zero/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-load_store_rs1_zero.log


# failed=0
check_log ${log} "SIMULATION PASSED" load_store_rs1_zero
incr_test_counts

# --> Test: matmul_32b_float : Build: uvmt_cv32e40p : matmul_32b_float
  
# --> Test (Index: 0): make test COREV=YES TEST=matmul_32b_float CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : matmul_32b_float
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=matmul_32b_float CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=matmul_32b_float CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/matmul_32b_float/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-matmul_32b_float.log


# failed=0
check_log ${log} "SIMULATION PASSED" matmul_32b_float
incr_test_counts

# --> Test: matmul_32b_int : Build: uvmt_cv32e40p : matmul_32b_int
  
# --> Test (Index: 0): make test COREV=YES TEST=matmul_32b_int CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : matmul_32b_int
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=matmul_32b_int CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=matmul_32b_int CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/matmul_32b_int/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-matmul_32b_int.log


# failed=0
check_log ${log} "SIMULATION PASSED" matmul_32b_int
incr_test_counts

# --> Test: misalign : Build: uvmt_cv32e40p : misalign
  
# --> Test (Index: 0): make test COREV=YES TEST=misalign CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : misalign
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=misalign CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=misalign CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/misalign/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-misalign.log


# failed=0
check_log ${log} "SIMULATION PASSED" misalign
incr_test_counts

# --> Test: modeled_csr_por : Build: uvmt_cv32e40p : modeled_csr_por
  
# --> Test (Index: 0): make test COREV=YES TEST=modeled_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : modeled_csr_por
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=modeled_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=modeled_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/modeled_csr_por/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-modeled_csr_por.log


# failed=0
check_log ${log} "SIMULATION PASSED" modeled_csr_por
incr_test_counts

# --> Test: perf_counters_instructions : Build: uvmt_cv32e40p : perf_counters_instructions
  
# --> Test (Index: 0): make test COREV=YES TEST=perf_counters_instructions CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : perf_counters_instructions
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=perf_counters_instructions CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=perf_counters_instructions CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/perf_counters_instructions/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-perf_counters_instructions.log


# failed=0
check_log ${log} "SIMULATION PASSED" perf_counters_instructions
incr_test_counts

# --> Test: requested_csr_por : Build: uvmt_cv32e40p : requested_csr_por
  
# --> Test (Index: 0): make test COREV=YES TEST=requested_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : requested_csr_por
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=requested_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=requested_csr_por CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/requested_csr_por/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-requested_csr_por.log


# failed=0
check_log ${log} "SIMULATION PASSED" requested_csr_por
incr_test_counts

# --> Test: riscv_arithmetic_basic_test_0 : Build: uvmt_cv32e40p : riscv_arithmetic_basic_test_0
  
# --> Test (Index: 0): make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : riscv_arithmetic_basic_test_0
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=riscv_arithmetic_basic_test_0 CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/riscv_arithmetic_basic_test_0/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-riscv_arithmetic_basic_test_0.log


# failed=0
check_log ${log} "SIMULATION PASSED" riscv_arithmetic_basic_test_0
incr_test_counts

# --> Test: riscv_arithmetic_basic_test_1 : Build: uvmt_cv32e40p : riscv_arithmetic_basic_test_1
  
# --> Test (Index: 0): make test COREV=YES TEST=riscv_arithmetic_basic_test_1 CFG_PLUSARGS="+UVM_TIMEOUT=30000000" : riscv_arithmetic_basic_test_1
echo "legacy_v1: Running test [cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt && make test COREV=YES TEST=riscv_arithmetic_basic_test_1 CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"  ]"
pushd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt > /dev/null
make test COREV=YES TEST=riscv_arithmetic_basic_test_1 CFG_PLUSARGS="+UVM_TIMEOUT=30000000" CV_CORE=cv32e40p CFG=pulp_fpu_zfinx COREV=1 SIMULATOR=vsim COMP=0 USE_ISS=no COV= SEED=random GEN_START_INDEX=0 RUN_INDEX=0 TEST_CFG_FILE="disable_all_trn_logs,floating_pt_zfinx_instr_en"   >& /dev/null;
popd > /dev/null


  log=/data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt/vsim_results/pulp_fpu_zfinx/riscv_arithmetic_basic_test_1/disable_all_trn_logs__floating_pt_zfinx_instr_en/0/vsim-riscv_arithmetic_basic_test_1.log


# failed=0
check_log ${log} "SIMULATION PASSED" riscv_arithmetic_basic_test_1
incr_test_counts


echo "legacy_v1: Passing tests: ${pass_count}"
echo "legacy_v1: Failing tests: ${fail_count}"

if [ ${fail_count} -ne 0 ]; then
    exit 1
fi
exit 0