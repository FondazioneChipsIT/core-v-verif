## EVAL DEFINITION: evolved-skill-compliance

Formal evaluation that the 3 evolved skills are correctly referenced, loaded, and enforced by the agent network.

### Evolved Skills Under Evaluation

| Skill | Path | Consuming Agents |
|-------|------|-----------------|
| gvsoc-cv32e40p-isolation-patterns | `~/.claude/homunculus/projects/b04ec9fd40cf/evolved/skills/gvsoc-cv32e40p-isolation-patterns.md` | gvsoc-builder, gvsoc-isa-model, gvsoc-regression-orchestrator |
| gvsoc-irq-build-safety | `~/.claude/homunculus/projects/b04ec9fd40cf/evolved/skills/gvsoc-irq-build-safety.md` | gvsoc-builder, gvsoc-isa-model, gvsoc-regression-orchestrator, gvsoc-debugger |
| gvsoc-regression-workflow-rules | `~/.claude/homunculus/projects/b04ec9fd40cf/evolved/skills/gvsoc-regression-workflow-rules.md` | gvsoc-regression-orchestrator |

---

### Capability Evals

#### 1. Skill files exist and are well-formed
- [ ] gvsoc-cv32e40p-isolation-patterns.md exists and has valid frontmatter (name, description, type, evolved_from)
- [ ] gvsoc-irq-build-safety.md exists and has valid frontmatter
- [ ] gvsoc-regression-workflow-rules.md exists and has valid frontmatter
- [ ] Each skill has at least 2 evolved_from entries (consolidated from multiple instincts)

#### 2. Agent references are correct
- [ ] gvsoc-builder.md contains "Required Skills" section
- [ ] gvsoc-builder.md references gvsoc-cv32e40p-isolation-patterns path
- [ ] gvsoc-builder.md references gvsoc-irq-build-safety path
- [ ] gvsoc-isa-model.md contains "Required Skills" section
- [ ] gvsoc-isa-model.md references gvsoc-cv32e40p-isolation-patterns path
- [ ] gvsoc-isa-model.md references gvsoc-irq-build-safety path
- [ ] gvsoc-regression-orchestrator.md references all 3 evolved skills
- [ ] gvsoc-debugger.md references gvsoc-irq-build-safety path

#### 3. Isolation patterns skill is enforced
- [ ] Skill defines 4-tier hierarchy: Python config > file override > class inheritance > #ifdef
- [ ] Skill specifies CONFIG_GVSOC_ISS_CV32E40P as canonical macro (not HWLOOP, not PULP)
- [ ] Skill includes CSR standard vs core-specific separation rule
- [ ] Agent (gvsoc-builder) safety checks reference the same hierarchy

#### 4. IRQ build safety skill is enforced
- [ ] Skill defines riscv_exceptions=True as ONLY correct method (not add_c_flags)
- [ ] Skill mandates clean rebuild (rm -rf build/ install/models/) after IRQ switch
- [ ] Skill includes diagnostic command (strings ... | grep CONFIG_GVSOC_ISS_RISCV)
- [ ] Agent (gvsoc-builder) IRQ section is consistent with skill content

#### 5. Regression workflow rules are enforced
- [ ] Skill defines MAX 3 fix attempts per test
- [ ] Skill defines failure categorization table (bug puntuale, audit sistematico, feature mancante, timeout)
- [ ] Skill defines agent parallelism serialization rules
- [ ] Skill defines fix operation ordering (trace-analyzer -> gvsoc-isa-model -> gvsoc-builder -> trace-runner)
- [ ] Orchestrator algorithm matches the ordering defined in the skill

---

### Regression Evals

After any evolved skill file change:

- [ ] All agent "Required Skills" sections still point to valid file paths
- [ ] No agent contradicts the evolved skill content (e.g., recommending add_c_flags for IRQ)
- [ ] Orchestrator stop conditions match workflow rules (MAX 3 attempts, baseline regression -> REVERT)

---

### Code Graders

```bash
# Grader 1: Evolved skill files exist
SKILL_DIR=~/.claude/homunculus/projects/b04ec9fd40cf/evolved/skills
PASS=true
for skill in gvsoc-cv32e40p-isolation-patterns gvsoc-irq-build-safety gvsoc-regression-workflow-rules; do
    if [ ! -f "$SKILL_DIR/$skill.md" ]; then
        echo "FAIL: $skill.md not found"
        PASS=false
    fi
done
$PASS && echo "PASS: all 3 evolved skill files exist"
```

```bash
# Grader 2: Agent references are present
PASS=true
SKILL_PATH="~/.claude/homunculus/projects/b04ec9fd40cf/evolved/skills"

# gvsoc-builder must reference isolation-patterns and irq-build-safety
for pattern in "isolation-patterns" "irq-build-safety"; do
    if ! grep -q "$pattern" ~/.claude/agents/gvsoc-builder.md; then
        echo "FAIL: gvsoc-builder.md missing reference to $pattern"
        PASS=false
    fi
done

# gvsoc-isa-model must reference isolation-patterns and irq-build-safety
for pattern in "isolation-patterns" "irq-build-safety"; do
    if ! grep -q "$pattern" ~/.claude/agents/gvsoc-isa-model.md; then
        echo "FAIL: gvsoc-isa-model.md missing reference to $pattern"
        PASS=false
    fi
done

# orchestrator must reference all 3
for pattern in "isolation-patterns" "irq-build-safety" "regression-workflow-rules"; do
    if ! grep -q "$pattern" ~/.claude/agents/gvsoc-regression-orchestrator.md; then
        echo "FAIL: orchestrator.md missing reference to $pattern"
        PASS=false
    fi
done

# debugger must reference irq-build-safety
if ! grep -q "irq-build-safety" ~/.claude/agents/gvsoc-debugger.md; then
    echo "FAIL: gvsoc-debugger.md missing reference to irq-build-safety"
    PASS=false
fi

$PASS && echo "PASS: all agent references correct"
```

```bash
# Grader 3: Skill content consistency
SKILL_DIR=~/.claude/homunculus/projects/b04ec9fd40cf/evolved/skills

# Isolation patterns must mention CONFIG_GVSOC_ISS_CV32E40P
grep -q "CONFIG_GVSOC_ISS_CV32E40P" "$SKILL_DIR/gvsoc-cv32e40p-isolation-patterns.md" && \
    echo "PASS: isolation-patterns has correct macro" || \
    echo "FAIL: isolation-patterns missing CONFIG_GVSOC_ISS_CV32E40P"

# IRQ build safety must mention riscv_exceptions=True
grep -q "riscv_exceptions=True" "$SKILL_DIR/gvsoc-irq-build-safety.md" && \
    echo "PASS: irq-build-safety has riscv_exceptions rule" || \
    echo "FAIL: irq-build-safety missing riscv_exceptions=True"

# Workflow rules must mention MAX 3
grep -q "MAX 3" "$SKILL_DIR/gvsoc-regression-workflow-rules.md" && \
    echo "PASS: workflow-rules has MAX 3 attempts" || \
    echo "FAIL: workflow-rules missing MAX 3 attempts rule"
```

```bash
# Grader 4: No agent contradicts evolved skills
PASS=true

# No agent should recommend add_c_flags for RISCV_EXCEPTIONS
for f in ~/.claude/agents/gvsoc-builder.md ~/.claude/agents/gvsoc-isa-model.md; do
    if grep -q "add_c_flags.*RISCV_EXCEPTIONS" "$f" | grep -v "NON\|SBAGLIATO\|WRONG\|senza usare il parametro"; then
        echo "FAIL: $f recommends add_c_flags for RISCV_EXCEPTIONS"
        PASS=false
    fi
done

# No agent should recommend write_illegal for HPM counters
for f in ~/.claude/agents/gvsoc-builder.md ~/.claude/agents/gvsoc-isa-model.md; do
    # Lines containing write_illegal must also contain "NON" or "REVERTITO"
    while IFS= read -r line; do
        if echo "$line" | grep -q "write_illegal" && ! echo "$line" | grep -qE "NON|REVERTITO|SBAGLIATO|errato"; then
            echo "FAIL: $f has unguarded write_illegal reference: $line"
            PASS=false
        fi
    done < <(grep "write_illegal" "$f" 2>/dev/null)
done

$PASS && echo "PASS: no agent contradicts evolved skills"
```

---

### Model Grader

```markdown
[MODEL GRADER: Skill Application in Fix Scenario]

Scenario: gvsoc-builder is asked to fix a CSR read returning wrong value.
The CSR is mhartid (standard RISC-V, address 0xF14).

Evaluate the agent's proposed fix against evolved skills:

1. Did it check gvsoc-cv32e40p-isolation-patterns before modifying code? (Y/N)
2. Did it use the correct isolation tier? (Python config preferred over #ifdef)
3. Did it keep mhartid declaration OUTSIDE #ifdef? (standard CSR rule)
4. Did it put only CV32E40P-specific properties INSIDE #ifdef?
5. Did it use CONFIG_GVSOC_ISS_CV32E40P (not HWLOOP or PULP)?

Score: 0-5 (one point per criterion)
Threshold: >= 4 for PASS
```

---

### Success Metrics

- **Skill existence**: pass@1 = 100% (files must exist)
- **Agent reference correctness**: pass@1 = 100% (all references valid)
- **Content consistency**: pass^3 = 100% (no contradictions between skill and agent)
- **Skill application accuracy**: pass@3 >= 80% (agents follow skill rules in practice)

### Evaluation Cadence

- **After every agent file edit**: run Grader 2 (references) + Grader 4 (contradictions)
- **After every evolved skill edit**: run all 4 graders
- **After /evolve generates new skills**: run Grader 1 (existence) + update this eval definition
