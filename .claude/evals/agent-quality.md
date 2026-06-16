## EVAL DEFINITION: agent-quality

Formal evaluation of the 7 GVSOC specialist agents.
Measures correctness of output format, diagnostic accuracy, and adherence to safety rules.

### Agents Under Evaluation

| Agent | Role | Model |
|-------|------|-------|
| gvsoc-regression-orchestrator | Top-level coordination | sonnet |
| trace-runner | Test execution, JSON results | sonnet |
| trace-analyzer | Trace divergence diagnosis | sonnet |
| gvsoc-isa-model | ISS source code analysis | sonnet |
| gvsoc-builder | Fix application + rebuild | sonnet |
| gvsoc-debugger | Crash/sim failure diagnosis | sonnet |
| cv32e40p-rtl-expert | RTL spec compliance | sonnet |
| cv32e40p-verif-env | Makefile/testbench setup | sonnet |

---

### Capability Evals

#### 1. trace-runner: correct test execution
- [ ] Produces valid JSON output with fields: test, cfg, status, step_count
- [ ] Status field is one of: success, count_mismatch, divergence, loop, timeout, crash
- [ ] CFG parameter mapping is correct (pulp_fpu -> COREV_PULP=True FPU=True ZFINX=False)
- [ ] Does not recompile testbench (COMP=NO enforced)
- [ ] Handles timeout gracefully (reports timeout, not crash)

#### 2. trace-analyzer: correct divergence diagnosis
- [ ] Identifies divergence step number accurately (within +/- 1 of actual)
- [ ] Reports correct RTL vs GVSOC values at divergence point
- [ ] Detects infinite loops (repeated PC pattern)
- [ ] Provides fix.file and fix.line when root cause is identifiable
- [ ] Does NOT propose fixes to shared files without ifdef guard recommendation

#### 3. gvsoc-isa-model: correct root cause identification
- [ ] Identifies correct source file and function for ISS bugs
- [ ] References correct compile-time flags
- [ ] Distinguishes between Python config fix vs C++ source fix
- [ ] Does NOT recommend reverted fixes (BUG-2 write_illegal)
- [ ] Knows riscv_exceptions=True mechanism (not add_c_flags)

#### 4. gvsoc-builder: correct fix + rebuild
- [ ] Reads target file before editing
- [ ] Uses #ifdef CONFIG_GVSOC_ISS_CV32E40P for shared file changes
- [ ] Runs correct build command (micromamba run -n gvsoc_env_3_12 make gvsoc)
- [ ] Reports structured output: STATUS, SUMMARY, FIX_APPLIED, BUILD_LOG, NEXT_ACTIONS
- [ ] Does NOT modify timeout without explicit user request
- [ ] Runs clean rebuild after IRQ subsystem changes

#### 5. gvsoc-debugger: correct crash diagnosis
- [ ] Distinguishes ISS=GVSOC (DPI) from ISS=GVSOC_TRACE (standalone)
- [ ] Uses absolute paths for all diagnostic commands
- [ ] Identifies SIGSEGV root cause (memory range, bad address, null pointer)
- [ ] Provides exact reproduction command for standalone mode
- [ ] Reports structured output: STATUS, SUMMARY, Root Cause, Evidence, Fix, Verification

#### 6. gvsoc-regression-orchestrator: correct workflow
- [ ] Runs baseline before and after every fix
- [ ] Enforces MAX 3 fix attempts per test
- [ ] Reverts immediately on baseline regression
- [ ] Short-circuits gvsoc-isa-model when trace-analyzer provides file:line
- [ ] Categorizes structural failures as NEEDS_WORK (not infinite fix loops)
- [ ] Produces regression report in correct format

#### 7. cv32e40p-rtl-expert: correct spec reference
- [ ] Memory map addresses are correct (RAM=0x00000000, Debug ROM=0x1A110800)
- [ ] CSR behavior matches CV32E40P RTL (not generic RISC-V spec)
- [ ] Does NOT reference fake addresses (old 0x1A190800 debug handler)

---

### Regression Evals

After any agent definition file change, verify:

- [ ] gvsoc-builder can still rebuild GVSOC successfully
- [ ] trace-runner can still execute hello-world/default
- [ ] gvsoc-regression-orchestrator can still run baseline suite (8 tests)
- [ ] No agent references outdated bug status (all bugs up to BUG-18 are RISOLTO)

---

### Code Graders

```bash
# Grader: Agent output format compliance (gvsoc-builder)
# Run agent on a known-good task and check output structure
OUTPUT=$(cat /tmp/agent_builder_output.txt)
echo "$OUTPUT" | grep -q "^STATUS:" && \
echo "$OUTPUT" | grep -q "^SUMMARY:" && \
echo "$OUTPUT" | grep -q "^NEXT_ACTIONS:" && \
echo "PASS: output format" || echo "FAIL: missing structured output fields"
```

```bash
# Grader: Agent safety rule compliance
# Check that gvsoc-builder does not modify shared files without ifdef
AGENT_FILE=~/.claude/agents/gvsoc-builder.md
grep -q "CONFIG_GVSOC_ISS_CV32E40P" "$AGENT_FILE" && \
grep -q "ifdef" "$AGENT_FILE" && \
grep -q "DO NOT modify the timeout" "$AGENT_FILE" && \
echo "PASS: safety rules present" || echo "FAIL: missing safety rules"
```

```bash
# Grader: Agent does not reference reverted fixes
for f in ~/.claude/agents/gvsoc-builder.md ~/.claude/agents/gvsoc-isa-model.md; do
    if grep -q "write_illegal=true" "$f" | grep -v "NON ri-aggiungere"; then
        echo "FAIL: $f still recommends reverted write_illegal fix"
    fi
done
echo "PASS: no reverted fix references"
```

### Model Grader

```markdown
[MODEL GRADER: Agent Diagnostic Accuracy]
Given a known trace divergence (fibonacci/pulp at step 2037, cv.mac illegal instruction),
evaluate the trace-analyzer agent output:

1. Did it identify the correct divergence step? (within +/-1)
2. Did it identify the correct instruction (cv.mac)?
3. Did it identify the root cause (encoding mismatch in ISA generator)?
4. Did it provide a fix.file pointing to isa_cv32e40pv2.py?

Score: 0-4 (one point per criterion)
Threshold: >= 3 for PASS
```

---

### Success Metrics

- **Output format compliance**: pass@1 = 100% (structured output on first try)
- **Safety rule adherence**: pass^3 = 100% (never violate shared code protection)
- **Diagnostic accuracy**: pass@3 >= 75% (correct root cause within 3 attempts)
- **Regression stability**: pass^3 = 100% (no agent change breaks existing workflow)

### Evaluation Cadence

- **After every agent file edit**: run output format + safety rule graders
- **After every evolved skill update**: verify agents reference correct skill paths
- **Monthly**: run full diagnostic accuracy eval on known-bug scenarios
