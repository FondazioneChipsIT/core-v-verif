## EVAL DEFINITION: multi-agent-system-quality

Valutazione formale del sistema multi-agentico Claude Code per il workflow
quotidiano di verifica HW CV32E40P/GVSOC.

---

### Dimensioni di valutazione

| Dimensione | Peso | Cosa misura |
|-----------|------|-------------|
| Completezza agenti | 20% | Ogni task quotidiano ha un agente dedicato? |
| Coerenza inter-agente | 20% | Agenti si contraddicono? Output format compatibili? |
| Manutenzione automatica | 15% | Il sistema si auto-mantiene senza intervento umano? |
| Costo contesto | 15% | Quanto contesto viene caricato inutilmente? |
| Riusabilita cross-progetto | 15% | Quanto e' portabile su un altro core RISC-V? |
| Feedback loop | 15% | Le correzioni dell'utente vengono catturate e persistite? |

---

### Capability Evals

#### 1. Completezza copertura task quotidiani

| Task quotidiano | Agente responsabile | Status |
|----------------|--------------------| -------|
| Fix bug ISS (CSR, exception, ISA) | gvsoc-isa-model + gvsoc-builder | OK |
| Diagnosi divergenza trace | trace-analyzer | OK |
| Esecuzione test singolo | trace-runner | OK |
| Regressione completa | gvsoc-regression-orchestrator | OK |
| Crash/SIGSEGV GVSOC | gvsoc-debugger | OK |
| Verifica spec RTL | cv32e40p-rtl-expert | OK |
| Problema Makefile/CFG | cv32e40p-verif-env | OK |
| Review codice SV/UVM | sv-uvm-reviewer | OK |
| Creazione nuovo test | test-generator | OK |
| **Performance profiling ISS** | **MANCANTE** | GAP |
| **Coverage analysis** | **MANCANTE** | GAP |
| Manutenzione periodica | /maintenance skill | OK |

- [x] 10/12 task coperti (83%)
- [x] Target: >= 10/12 (83%)

#### 2. Coerenza output format

- [ ] Tutti gli agenti diagnostici hanno Output Format section
  - gvsoc-builder: YES
  - gvsoc-debugger: YES
  - gvsoc-isa-model: YES
  - trace-analyzer: YES
  - trace-runner: YES
  - cv32e40p-rtl-expert: YES
  - cv32e40p-verif-env: YES
- [x] 9/9 agenti con output strutturato (100%)
- [x] Target: >= 8/9 (89%)

#### 3. Required Skills linkage

- [ ] Agenti che modificano codice GVSOC referenziano isolation-patterns
  - gvsoc-builder: YES
  - gvsoc-isa-model: YES
  - gvsoc-debugger: solo irq-build-safety (accettabile — non modifica codice)
- [ ] Orchestrator referenzia tutte e 3 le evolved skills: YES
- [ ] Target: 100% agenti modificatori linkati a isolation-patterns

#### 4. Manutenzione automatica

- [ ] SessionStart hook presente e funzionante
- [ ] check-due.sh esce con codice corretto (0=due, 1=clean)
- [ ] last-runs.json traccia 5 task con timestamp UTC
- [ ] Cadenze ragionevoli (3g eval, 7g instinct/harness/memory, 14g stocktake)
- [ ] update-timestamp.sh funziona dopo ogni task
- [ ] Target: 5/5 check passano

#### 5. Costo contesto

| Componente | Linee | Caricato quando |
|-----------|-------|-----------------|
| CLAUDE.md (3 file) | ~230 | SEMPRE (ogni sessione) |
| Rules (22 file) | ~1100 | SEMPRE |
| MEMORY.md | 124 | SEMPRE |
| Agenti (9 file) | ~1847 | Solo quando invocati |
| Evolved skills (3 file) | 194 | Solo quando referenziati da agenti |
| Learned skills (5 file) | 422 | Solo quando trigger match |
| Eval definitions (4 file) | ~640 | Solo su /eval invocation |

**Context budget fisso**: ~1454 linee (CLAUDE.md + rules + MEMORY.md)
- [ ] Budget fisso < 2000 linee: PASS
- [ ] Rules TypeScript/Python caricate inutilmente (progetto HW): **WASTE** ← GAP
- [ ] Target: < 1000 linee di contesto fisso rilevante

#### 6. Riusabilita cross-progetto

| Componente | Portabile? | Note |
|-----------|-----------|------|
| Architettura agenti (orchestrator + specialist) | SI | Pattern riusabile |
| Evolved skills content | NO | CV32E40P-specifico |
| Maintenance skill | SI | Generico |
| Eval harness framework | SI | Generico |
| Memory structure | SI | Pattern riusabile |
| Rules common/ | SI | Generiche |
| Rules systemverilog/ | PARZIALE | Riusabile per altri core SV |

- [ ] 5/7 componenti portabili (71%)
- [ ] Target: architettura riusabile, contenuto domain-specific accettabile

#### 7. Feedback loop

- [ ] PreToolUse/PostToolUse hooks catturano osservazioni: YES
- [ ] Instinct CLI disponibile (`/evolve`): YES
- [ ] 11 instinct nel progetto corrente: YES
- [x] 7095+ osservazioni in observations.jsonl (project ID: 027301ae4686)
- [ ] `/learn-eval` disponibile per extraction manuale: YES
- [ ] `/maintenance` include instinct_evolve nel ciclo: YES
- [ ] Target: observations.jsonl deve accumulare dati attivamente

---

### Regression Evals

Dopo qualsiasi modifica al sistema multi-agentico:

- [ ] Tutti i 4 grader evolved-skill-compliance passano
- [ ] Nessun agente referenzia file inesistenti
- [ ] Nessuna contraddizione add_c_flags / write_illegal
- [ ] /maintenance status riporta correttamente le scadenze
- [ ] check-due.sh non ha errori di sintassi

---

### Code Graders

```bash
# Grader 1: Agent completeness (Output Format + Required Skills)
PASS=true
for agent in gvsoc-builder gvsoc-debugger gvsoc-isa-model trace-analyzer trace-runner; do
    if ! grep -q "Output Format" ~/.claude/agents/$agent.md; then
        echo "FAIL: $agent missing Output Format"
        PASS=false
    fi
done
for agent in gvsoc-builder gvsoc-isa-model; do
    if ! grep -q "Required Skills" ~/.claude/agents/$agent.md; then
        echo "FAIL: $agent missing Required Skills"
        PASS=false
    fi
done
$PASS && echo "PASS: agent structure complete"
```

```bash
# Grader 2: Maintenance system health
PASS=true
MAINT=~/.claude/skills/maintenance

# Files exist
for f in SKILL.md scripts/check-due.sh scripts/update-timestamp.sh scripts/last-runs.json; do
    [ -f "$MAINT/$f" ] || { echo "FAIL: $f missing"; PASS=false; }
done

# check-due.sh runs without syntax error
bash "$MAINT/scripts/check-due.sh" >/dev/null 2>&1
RC=$?
[ "$RC" -le 1 ] || { echo "FAIL: check-due.sh syntax error (exit $RC)"; PASS=false; }

# last-runs.json has 5 tasks
TASK_COUNT=$(python3 -c "import json; print(len(json.load(open('$MAINT/scripts/last-runs.json'))))")
[ "$TASK_COUNT" -eq 5 ] || { echo "FAIL: last-runs.json has $TASK_COUNT tasks (expected 5)"; PASS=false; }

# SessionStart hook present in settings.json
grep -q "check-due.sh" ~/.claude/settings.json || { echo "FAIL: SessionStart hook missing"; PASS=false; }

$PASS && echo "PASS: maintenance system healthy"
```

```bash
# Grader 3: Context waste detection
PASS=true
# Count rules lines for irrelevant languages
TS_LINES=$(cat ~/.claude/rules/typescript/*.md 2>/dev/null | wc -l)
PY_LINES=$(cat ~/.claude/rules/python/*.md 2>/dev/null | wc -l)
TOTAL_WASTE=$((TS_LINES + PY_LINES))
if [ "$TOTAL_WASTE" -gt 200 ]; then
    echo "WARNING: $TOTAL_WASTE lines of TS+Python rules loaded for HW verification project"
fi
# Memory under 200 lines
MEM_LINES=$(wc -l < ~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/MEMORY.md)
[ "$MEM_LINES" -lt 200 ] || { echo "FAIL: MEMORY.md is $MEM_LINES lines (max 200)"; PASS=false; }

$PASS && echo "PASS: context budget acceptable"
```

```bash
# Grader 4: Feedback loop active
PASS=true
# Hooks configured
grep -q "observe.sh" ~/.claude/settings.json || { echo "FAIL: observation hooks missing"; PASS=false; }
# Instincts exist
INSTINCT_COUNT=$(ls ~/.claude/homunculus/projects/027301ae4686/instincts/personal/*.yaml 2>/dev/null | wc -l)
[ "$INSTINCT_COUNT" -ge 5 ] || { echo "WARNING: only $INSTINCT_COUNT instincts (expected 5+)"; }
# Observations exist
OBS_COUNT=$(wc -l < ~/.claude/homunculus/projects/027301ae4686/observations.jsonl 2>/dev/null || echo 0)
[ "$OBS_COUNT" -ge 10 ] || { echo "WARNING: only $OBS_COUNT observations"; }
# Evolved skills exist
EVOLVED_COUNT=$(ls ~/.claude/homunculus/projects/027301ae4686/evolved/skills/*.md 2>/dev/null | wc -l)
[ "$EVOLVED_COUNT" -ge 3 ] || { echo "FAIL: only $EVOLVED_COUNT evolved skills (expected 3+)"; PASS=false; }

$PASS && echo "PASS: feedback loop active"
```

---

### Model Grader

```markdown
[MODEL GRADER: Daily Workflow Simulation]

Scenario: L'utente chiede "il test csr_instructions/pulp_fpu fallisce con GVSOC,
il trace mostra mcause=0 invece di mcause=2 su una csrw mhpmcounter3".

Valuta se il sistema multi-agentico puo gestire questo end-to-end:

1. Orchestrator identifica il task e delega? (Y/N)
2. trace-analyzer diagnostica correttamente la causa (HPM counter)? (Y/N)
3. gvsoc-isa-model trova il punto esatto nel codice (csr.cpp declare_csr)? (Y/N)
4. gvsoc-builder applica il fix rispettando isolation-patterns? (Y/N)
5. trace-runner ri-esegue il test per verificare? (Y/N)
6. Il risultato viene tracciato in last-runs.json/eval? (Y/N)

Score: 0-6
Threshold: >= 5 per PASS
```

---

### Findings e Raccomandazioni

#### GAP-1: Rules irrelevanti sempre caricate (CRITICAL — context waste)

**Problema**: 22 rules file (~1100 linee) vengono caricati in OGNI sessione.
TypeScript (319 linee) e Python (168 linee) non servono per questo progetto HW.

**Raccomandazione**: Spostare rules TypeScript e Python in `.claude/rules-archive/` o
usare project-level rules override che carica solo C, C++, SystemVerilog, e common.

**Impatto**: -487 linee di contesto fisso (-33%)

#### GAP-2: Nessun agente per creazione test (MEDIUM)

**Problema**: Task quotidiano "creare un nuovo test per un caso specifico" non ha agente dedicato.
Serve quando si scopre un bug e si vuole riprodurlo con un test mirato.

**Raccomandazione**: Creare `test-generator` agent che:
- Prende una descrizione del comportamento da testare
- Genera il programma C bare-metal
- Configura linker script e Makefile entry
- Esegue con trace-runner per verificare

#### GAP-3: observations.jsonl vuoto (LOW — hooks attivi ma no data)

**Problema**: I hook di osservazione sono configurati ma il file `observations.jsonl`
ha 0 righe. Potrebbe indicare che lo script `observe.sh` non sta scrivendo.

**Raccomandazione**: Verificare che `observe.sh` scriva nel path corretto per questo progetto.

#### GAP-4: Modello uniforme sonnet per tutti gli agenti (OPTIMIZATION)

**Problema**: Tutti i 9 agenti usano `model: sonnet`. Ma non tutti richiedono lo
stesso livello di ragionamento:
- `trace-runner`: esegue comandi meccanici → haiku sarebbe sufficiente
- `cv32e40p-rtl-expert`: consulta spec, serve ragionamento profondo → opus potrebbe migliorare
- `gvsoc-isa-model`: diagnosi complessa su codice C++ → sonnet ok

**Raccomandazione**: Model routing per task complexity:
| Agent | Modello consigliato | Risparmio/Beneficio |
|-------|--------------------|--------------------|
| trace-runner | haiku | ~3x costo ridotto per esecuzioni meccaniche |
| cv32e40p-verif-env | haiku | Task meccanici Makefile |
| cv32e40p-rtl-expert | opus | Migliore accuratezza spec |
| Tutti gli altri | sonnet | Bilanciamento costo/qualita |

#### GAP-5: cv32e40p-rtl-expert e cv32e40p-verif-env senza Output Format (LOW)

**Problema**: 2 agenti advisory non hanno output strutturato.
L'orchestrator puo avere difficolta a parsare le loro risposte.

**Raccomandazione**: Aggiungere Output Format section minimale.

---

### Success Metrics

| Metrica | Attuale | Target | Status |
|---------|---------|--------|--------|
| Task coperti | 10/12 (83%) | >= 10/12 | PASS |
| Output Format | 9/9 (100%) | >= 8/9 | PASS |
| Required Skills | 4/9 (44%) | 100% modificatori | PASS |
| Maintenance checks | 5/5 | 5/5 | PASS |
| Context budget fisso | ~1135 linee | < 1000 rilevanti | NEEDS_WORK |
| Feedback loop | 7095+ obs, 17 instincts | Obs accumulating | PASS |
| Cross-project portability | 71% | Architettura OK | PASS |

### Evaluation Cadence

- **Dopo ogni modifica agente**: run Grader 1 + Grader 4
- **Settimanale** (via /maintenance): run tutti i grader
- **Dopo aggiunta nuovo agente**: aggiornare eval definition + run tutti
