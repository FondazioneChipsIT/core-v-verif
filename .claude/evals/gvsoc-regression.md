## EVAL DEFINITION: gvsoc-regression

Formal evaluation of the GVSOC ISS=GVSOC_TRACE regression suite for CV32E40P.
Measures trace comparison accuracy across all 26 test/CFG pairs.

### Capability Evals

Each test/CFG pair is evaluated by running `compare_traces.py --json` and checking the JSON status field.

#### default CFG
- [ ] hello-world/default: status=success OR count_mismatch (delta<=1)
- [ ] fibonacci/default: status=success OR count_mismatch (delta<=1)
- [ ] dhrystone/default: status=success OR count_mismatch (delta<=1)
- [ ] riscv_arithmetic_basic_test_0/default: status=success OR count_mismatch (delta<=1)
- [ ] riscv_arithmetic_basic_test_1/default: status=success OR count_mismatch (delta<=1)
- [ ] csr_instructions/default: status=success OR count_mismatch (delta<=1)
- [ ] illegal_instr_test/default: status=success OR count_mismatch (delta<=1)
- [ ] illegal/default: status=success OR count_mismatch (delta<=1)
- [ ] misalign/default: status=success OR count_mismatch (delta<=1)

#### no_pulp CFG
- [ ] csr_instructions/no_pulp: status=success OR count_mismatch (delta<=1)

#### pulp CFG
- [ ] csr_instructions/pulp: status=success OR count_mismatch (delta<=1)
- [ ] hello-world/pulp: status=success OR count_mismatch (delta<=1)
- [ ] fibonacci/pulp: status=success OR count_mismatch (delta<=1)

#### pulp_fpu CFG
- [ ] csr_instructions/pulp_fpu: status=success OR count_mismatch (delta<=1)
- [ ] hello-world/pulp_fpu: status=success OR count_mismatch (delta<=1)
- [ ] mhpmcounter29_csr_access_test_1/pulp_fpu: status=success OR count_mismatch (delta<=1)
- [ ] mhpmcounter29_csr_access_test_2/pulp_fpu: status=success OR count_mismatch (delta<=1)

#### pulp_fpu_zfinx CFG
- [ ] csr_instructions/pulp_fpu_zfinx: status=success OR count_mismatch (delta<=1)
- [ ] mhpmcounter29_csr_access_test_1/pulp_fpu_zfinx: status=success OR count_mismatch (delta<=1)

#### pulp_fpu_zfinx_2cyclat CFG
- [ ] csr_instructions/pulp_fpu_zfinx_2cyclat: status=success OR count_mismatch (delta<=1)
- [ ] mhpmcounter29_csr_access_test_1/pulp_fpu_zfinx_2cyclat: status=success OR count_mismatch (delta<=1)

### Known Classifications (excluded from pass rate)

| Test/CFG | Classification | Reason |
|----------|---------------|--------|
| generic_exception_test/default | WONTFIX | Requires interrupt stimuli not available in standalone mode |
| all_csr_por/pulp_fpu | TOO_LARGE | 5M+ instructions, exceeds 10s timeout |
| cv32e40p_csr_access_test/pulp_fpu | NEEDS_WORK | CSR write-mask audit needed |
| cv32e40p_readonly_csr_access_test/pulp_fpu_zfinx | NEEDS_WORK | CSR write-mask audit needed |
| cv32e40p_csr_access_test/pulp_fpu_zfinx_2cyclat | NEEDS_WORK | CSR write-mask audit needed |

### Regression Evals (Baseline Suite)

These 8 tests MUST pass after ANY GVSOC source modification:

- [ ] hello-world/default: PASS
- [ ] fibonacci/default: PASS
- [ ] dhrystone/default: PASS
- [ ] csr_instructions/pulp_fpu: PASS
- [ ] fibonacci/pulp: PASS
- [ ] riscv_arithmetic_basic_test_0/default: PASS
- [ ] riscv_arithmetic_basic_test_1/default: PASS
- [ ] illegal_instr_test/default: PASS

### Code Graders

```bash
# Grader 1: Single test pass/fail
cd /data/marco.paci/projects/core-v-verif/cv32e40p/sim/uvmt
micromamba run -n gvsoc_env_3_12 bash << 'BASH'
source /etc/profile.d/modules.sh && module load questa/2025.3
make test TEST=$TEST CFG=$CFG ISS=GVSOC_TRACE COMP=NO 2>&1 | tail -5
BASH
# Parse compare_traces.py JSON output for status field
python3 -c "
import json, sys
with open(f'trace_{TEST}_{CFG}.log') as f:
    for line in f:
        if 'status' in line:
            r = json.loads(line)
            status = r.get('status','unknown')
            if status in ('success','count_mismatch') and r.get('delta',99) <= 1:
                print('PASS')
            else:
                print(f'FAIL: {status}')
            sys.exit(0)
print('FAIL: no status found')
"
```

```bash
# Grader 2: Full regression (all 21 expected-PASS tests)
cd /data/marco.paci/projects/core-v-verif
python3 bin/compare_traces.py --batch --json 2>&1 | python3 -c "
import json, sys
results = json.load(sys.stdin)
passed = sum(1 for r in results if r['status'] in ('success','count_mismatch') and r.get('delta',99)<=1)
total = len(results)
print(f'Regression: {passed}/{total} passed')
print('PASS' if passed >= 21 else 'FAIL')
"
```

### Success Metrics

- **Baseline regression**: pass^3 = 100% (all 8 must pass on 3 consecutive runs)
- **Full suite**: pass@1 >= 21/21 expected-PASS tests
- **No new regressions**: any previously-PASS test that becomes FAIL is a blocker

### Evaluation Cadence

- **After every GVSOC rebuild**: run baseline (8 tests)
- **After every bug fix**: run baseline + target test
- **Weekly or on-demand**: run full suite (21 tests)
