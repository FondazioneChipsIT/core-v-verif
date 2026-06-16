---
name: mandatory-dispatch
description: REGOLA OBBLIGATORIA — mappa caso d'uso → agente/MCP/skill, MAI fare manualmente
level: L3-cvv
source_memory: [~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_mandatory_dispatch.md, ~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_delegate_to_agents.md, ~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_workflow_philosophy.md]
created: 2026-04-14
---

# Mandatory Dispatch — core-v-verif

> ⚠️ **MCP DISBANDATO (2026-06-25)** — i tool MCP citati sotto (`get_csr`, `search_bugs`, `match_divergence`, `graph_search`, `multimodal_search`, `repo_map`, `search_kb`, `semantic_search`, `get_document`) NON esistono più. Sostituzioni: **CSR / bug / KB / divergenze / spec-prosa** → `cvv-kb search "..."` (es. `cvv-kb search "mcause"`, `cvv-kb get project_gvsoc_bugs`); **codice/simboli** → grep/ctags; **spec PDF** → `Read`. Le righe "MAI cercare X con grep — usare MCP" qui sotto sono **SUPERSEDED**. Flusso PR: diretto GitHub + gate `/code-review` (Forgejo disbandato). Vedi `~/.claude/rules/common/mcp-retrieval.md` + `memory/research_notes/session_doctor_audit_20260625.md`.

## Regola

Per OGNI caso d'uso elencato, DEVE essere usato lo strumento indicato. MAI fare il lavoro manualmente nel contesto principale.

Prima di QUALSIASI `grep`/`read`/`bash` per investigare: chiediti "c'è un agente, un tool MCP, o una skill per questo?"

### Soglie di delega (dal workflow philosophy)

- Ricerca codebase > 3 tool calls → delegare a sub-agente.
- Attesa > 2 min → `run_in_background` + passare ad altro task.
- 2+ task indipendenti → lanciarli TUTTI in parallelo.
- Test > 10 min → preferire `Agent(run_in_background=true)` SENZA team (sopravvive a compact).

### Quando NON usare agenti (eccezioni esplicite)

- Lettura singolo file con path noto → `Read` diretto.
- Edit puntuali 1-2 righe su file già letti → `Edit` diretto.
- Risposte senza ricerca (conoscenza già nel contesto).

### Anti-pattern (MAI fare)

1. MAI fare 5+ `Read`/`Grep` nel contesto principale per investigare — delegare all'agente.
2. MAI rieseguire un test senza `sim-operator` — il processo principale non esegue simulazioni.
3. MAI applicare fix GVSOC senza `gvsoc-developer` — il processo principale non edita sorgenti ISS.
4. MAI analizzare un trace nel contesto principale — delegare a `trace-analyzer`.
5. MAI dimenticare review dopo modifica — lanciare reviewer appropriato.
6. MAI implementare senza consultare MCP prima — L1/L2 `repo_map` → `search_kb` → `search_bugs`, poi L3 `graph_search`, poi L4 `multimodal_search` se spec.
7. MAI fare tutto sequenzialmente quando agenti indipendenti possono girare in parallelo.
8. MAI cercare CSR con grep — usare MCP `get_csr()` (L1) + `graph_search("CSR <nome>")` (L3) + `multimodal_search("RISC-V <csr>")` (L4).
9. MAI cercare bug noti con grep — usare MCP `search_bugs()` o `match_divergence()`.
10. MAI spiegare un fix leggendo solo codice — cercare SEMPRE il bug entry corrispondente.
11. MAI rispondere a domande su AXI protocol/spec senza consultare L4 `multimodal_search`.
12. MAI rispondere a domande su RISC-V privileged spec senza consultare L4 `multimodal_search`.
13. MAI investigare relazioni architetturali con grep — usare L3 `graph_search` (9935 nodi indicizzati).
14. MAI catene di `Read`/`Grep` nel contesto principale — delegare al primo segno di investigazione multi-file.

---

## Mappa caso d'uso → strumento

### Simulazione e Test

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Compilare testbench (`make comp`) | Agente `sim-operator` | Conosce env Questa, CFG, define |
| Lanciare un singolo test | Agente `sim-operator` | Passa TEST, CFG, ISS mode nel prompt |
| Lanciare test GVSOC_TRACE (offline) | Agente `sim-operator` | `ISS=GVSOC_TRACE COMP=NO` — NON usare `USE_ISS` |
| Lanciare test DPI co-sim | Agente `sim-operator` | `USE_ISS=YES ISS=GVSOC COMP=NO` |
| Lanciare test senza ISS | Agente `sim-operator` | `USE_ISS=NO` |
| Lanciare batch di test indipendenti | Agente `sim-operator` x N in parallelo | Batch=4 max, un agente per test |
| Generare trace RTL/ISS | Agente `sim-operator` | `make trace` con parametri corretti |
| Verificare che un fix funziona (smoke test) | Skill `verify-gvsoc` | Compila + test singolo DPI post-modifica C++/SV |
| Generare test C bare-metal per bug | Agente `test-generator` | Fornire sintomo, ISA coinvolta, expected behavior |

### Diagnosi e Debug

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Divergenza trace (PC mismatch, CSR mismatch) | Agente `trace-analyzer` | Iniettare trace snippet + MCP `match_divergence()` |
| Crash GVSOC / SIGSEGV / DPI abort | Agente `gvsoc-debugger` | Iniettare backtrace + KB GVSOC pitfall |
| DPI timeout / hang | Agente `gvsoc-debugger` | Controllare sync protocol, step count |
| Errore di build C++ (`libgvsoc_rvvi.so`) | Agente `gvsoc-debugger` | Conosce ODR, linking, micromamba env |
| Errore di build SV / Questa elaboration | Agente `sim-operator` | Conosce Makefile, define, file list |
| Errore Makefile / variabile non risolta | Agente `sim-operator` | Conosce gerarchia `mk/`, `vsim.mk` |
| CSR mismatch specifico | Agente `gvsoc-cv32e40p` + MCP `get_csr()` | CSR lookup strutturato da KB |
| Comportamento ISA inatteso | Agente `cv32e40p-rtl-expert` | Spec compliance, encoding, pipeline |
| HWLoop behavior | Agente `cv32e40p-rtl-expert` | Conosce constraint HWLoop CV32E40P |
| IRQ/debug timing desync (DPI) | Riferimento: WONTFIX | Vedere `project_irq_timing_analysis.md` |
| Capire perché un fix precedente è stato fatto | MCP `search_bugs(query="<area>")` + `get_bug("<ID>")` | PRIMA del codice: cercare bug entry |
| Pattern matching su divergenza nota | MCP `match_divergence(symptom)` | Sintomo testuale, ritorna bug match |

### Sviluppo e Fix ISS (GVSOC)

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Modificare sorgente C++ GVSOC | Agente `gvsoc-developer` | Conosce `#ifdef`, ODR, build system |
| Aggiungere/modificare handler ISA | Agente `gvsoc-developer` | ISA encoding v2, CoreV2 naming |
| Fix CSR in GVSOC | Agente `gvsoc-cv32e40p` (diagnosi) → `gvsoc-developer` (fix) | Sequenza obbligatoria |
| Ricompilare GVSOC dopo modifica | Agente `gvsoc-developer` | `micromamba run -n gvsoc_env_3_12 make` |
| Capire differenze PulpV2 vs CV32E40P | Agente `gvsoc-cv32e40p` | 28 `#ifdef` documentati |
| Analizzare sorgente GVSOC (read-only) | Agente `gvsoc-worker` | Sonnet, non modifica file |
| Modificare `gvsoc_wrap.sv` | Agente `gvsoc-developer` (C++ side) + `sim-operator` (SV side) | Coordinare entrambi |
| Modificare `rvvi_api2gvsoc.cpp` / `gvsoc_engine.cpp` | Agente `gvsoc-developer` | File critici, review obbligatoria dopo |

### Review Codice

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Review C++ (bridge, engine, ISS) | Agente `code-reviewer` | Lanciare DOPO ogni modifica C++ |
| Review SystemVerilog / UVM | Agente `sv-uvm-reviewer` | Lanciare DOPO ogni modifica SV |
| Review Python (compare_traces, GVSOC models) | Agente `python-reviewer` | Lanciare DOPO ogni modifica Python |
| Review post-implementazione (qualsiasi linguaggio) | Reviewer appropriato in parallelo | C++ ‖ SV ‖ Python — tutti in parallelo se multi-file |
| Semplificare codice dopo review | Skill `simplify` | Analizza reuse, quality, efficiency |
| Verifica post-modifica C++/SV (build + smoke) | Skill `verify-gvsoc` | OBBLIGATORIA dopo ogni modifica a file DPI |

### Knowledge Base e Documentazione (3 livelli MCP)

#### L1/L2: project-kb (keyword + semantic — SEMPRE usare per primo)

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Cercare documentazione interna | MCP `search_kb(query, project="core-v-verif")` | Keyword search su tutta la KB |
| Ricerca semantica (concetto, non keyword) | MCP `semantic_search(query)` | Embedding L2 distance |
| Leggere documento KB specifico | MCP `get_document(name, section?)` | Può filtrare per sezione |
| Lookup CSR (nome o indirizzo hex) | MCP `get_csr(name)` | Ritorna: campo, write mask, expected value |
| Cercare bug noti | MCP `search_bugs(query?, status?, category?)` | Filtrabile per status (OPEN/FIXED/WONTFIX) e categoria |
| Dettaglio bug specifico (es. D11, BUG-5) | MCP `get_bug(id)` | Root cause, fix, file coinvolti |
| Matching divergenza con bug noti | MCP `match_divergence(symptom, trigger_csr?)` | Pattern matching testuale |
| Dipendenze segnali AXI | MCP `get_signal_deps(module, signal)` | Solo per progetto AXI |
| Mappa simboli repository (ctags) | MCP `repo_map(project, file?, kind?)` | Orientarsi prima di grep |
| Tracciare path di un segnale | MCP `trace_signal_path(...)` | Catena di dipendenze |
| Elenco documenti disponibili | MCP `list_documents()` | Tutti i doc indicizzati |

#### L3: lightrag-kb (knowledge graph relazionale — 9935 nodi, 9529 edges)

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Relazioni tra entità (moduli, CSR, concetti) | MCP `graph_search(query, mode="hybrid")` | **OBBLIGATORIO** per query multi-hop: "come si relazionano X e Y?" |
| Esplorare connessioni di un'entità | MCP `get_entity_relations(entity)` | Grafo relazioni dirette |
| Cercare entità nel KG | MCP `search_entities(query)` | Entità per nome/descrizione |
| Stato del knowledge graph | MCP `kg_status()` | Statistiche indice |
| Contesto architetturale codice sorgente | MCP `graph_search("<modulo> architecture")` | KG contiene 149 file sorgente (AXI SV, UVM TB, GVSOC ISS) |

#### L4: raganything-kb (PDF specs — 5346 nodi, 4914 edges, 7 PDF)

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Domande su protocollo AXI4 (handshake, ordering, burst) | MCP `multimodal_search(query)` | **OBBLIGATORIO** per dettagli da spec AXI4 IHI0022H |
| Domande su RISC-V privileged spec (CSR fields, traps, PMP) | MCP `multimodal_search(query)` | **OBBLIGATORIO** per spec compliance check |
| Pattern UVM (agent, sequence, factory, coverage) | MCP `multimodal_search(query)` | UVM 1.2 User Guide indicizzato |
| Metodologia SVA (assert, cover, FLAG) | MCP `multimodal_search(query)` | SVA Quick Ref + FLAG paper indicizzati |
| Lista specs indicizzati | MCP `list_specs()` | 7 PDF: AXI4, UVM, PULP AXI, FLAG SVA, SVA QuickRef, RISC-V Priv, RISC-V ISA |

### Git e CI

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Creare un commit | Skill `commit-commands:commit` | Segue convenzioni tipo: feat/fix/refactor |
| Commit + push + PR | Skill `commit-commands:commit-push-pr` | Pipeline completa in un comando |
| Pulire branch locali cancellati su remote | Skill `commit-commands:clean_gone` | Rimuove branch [gone] + worktree |
| Cercare issue GitHub | MCP GitHub `search_issues` / `list_issues` | Via plugin GitHub |
| Leggere PR GitHub | MCP GitHub `pull_request_read` | Via plugin GitHub |
| Creare PR GitHub | MCP GitHub `create_pull_request` oppure `gh pr create` | Preferire `gh` CLI |
| Review PR GitHub | MCP GitHub `pull_request_review_write` | Via plugin GitHub |
| Cercare codice su GitHub | MCP GitHub `search_code` | Cross-repo search |

### Regressione

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Regressione completa (tutti i test) | Agente `gvsoc-regression-orchestrator` | Phase 0: compile, Phase 1: parallel test (batch=4), Phase 2: fix loop |
| Test singolo in regressione | Agente `gvsoc-parallel-runner` | Worker haiku, un test alla volta |
| Fix loop su test falliti | Agente `gvsoc-regression-orchestrator` | Phase 2: sequential fix solo sui FAIL |
| Smoke test post-modifica | Skill `verify-gvsoc` | Build + singolo test DPI |

### Comunicazione e Notifiche

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Rispondere a messaggio Telegram | MCP Telegram `reply` | OGNI messaggio DEVE ricevere risposta |
| Reagire a messaggio Telegram | MCP Telegram `react` | Emoji reaction |
| Update intermedio (non notifica) | MCP Telegram `edit_message` | Non trigger push notification |
| Scaricare allegato Telegram | MCP Telegram `download_attachment` | Poi `Read` sul path restituito |

### Manutenzione e Infrastruttura

| Caso d'uso | Strumento obbligatorio | Note |
|---|---|---|
| Audit periodico harness/memory/agenti | Skill `maintenance` | Controlla coerenza configurazione |
| Task ricorrente su intervallo | Skill `loop` | Es. `/loop 5m /verify-gvsoc` |
| Task schedulato (cron) | Skill `schedule` | Agenti remoti su cron |
| Configurare settings.json / hooks | Skill `update-config` | Per behavior automatici ("ogni volta che X") |
| Cercare documentazione libreria esterna | MCP Context7 `resolve-library-id` → `query-docs` | Per librerie/framework, NON per codice interno |

---

## Disambiguazione ISS Mode

La richiesta utente puo' riferirsi a due modalita' ISS diverse. Identificare quale PRIMA di selezionare l'agente:

| Keyword nel prompt | ISS Mode | Agenti coinvolti |
|-------------------|----------|-----------------|
| "trace", "compare", "GVSOC_TRACE", "offline" | ISS=GVSOC_TRACE | `sim-operator`, `trace-analyzer` |
| "DPI", "co-sim", "step-n-compare", "GVSOC" (senza TRACE) | ISS=GVSOC | `gvsoc-debugger` (se crash), `sim-operator` (se test) |
| "bridge", "rvvi_bridge", "libgvsoc_rvvi" | ISS=GVSOC (DPI) | `gvsoc-debugger`, `gvsoc-developer` |
| ambiguo | Chiedere: "Intendi la co-simulazione DPI (ISS=GVSOC) o il confronto trace offline (ISS=GVSOC_TRACE)?" | — |

## Sequenze multi-agente obbligatorie

### Bug GVSOC (divergenza trace o DPI FAIL)

```
gvsoc-regression-orchestrator
  internamente: trace-analyzer → cv32e40p-rtl-expert → gvsoc-developer → sim-operator
```

### Bug GVSOC (crash)

```
gvsoc-debugger → gvsoc-developer → sim-operator (verify)
```

### Feature nuova (tocca SV + C++)

```
planner →
  implementazione C++ → code-reviewer (background)
  implementazione SV → sv-uvm-reviewer (background)
→ sim-operator (integration test)
→ verify-gvsoc (smoke test)
```

### Post-implementazione (SEMPRE)

```
[modifica C++] → code-reviewer ‖ verify-gvsoc
[modifica SV]  → sv-uvm-reviewer ‖ verify-gvsoc
[modifica Py]  → python-reviewer
[multi-lang]   → tutti i reviewer in parallelo ‖ verify-gvsoc
```

### Studio repository (prima di implementare o spiegare)

```
L1/L2: MCP repo_map() → search_kb() → search_bugs() → semantic_search()
L3:    MCP graph_search("<componente> relazioni") → get_entity_relations("<entità>")
L4:    MCP multimodal_search("<spec question>")  [se coinvolge AXI/RISC-V/UVM spec]
→ [poi codice sorgente mirato]
```

## Why

I 3 server MCP (project-kb L1/L2, lightrag-kb L3, raganything-kb L4) coprono il 95% delle query di contesto. Investigare manualmente con `grep`/`read`/`bash`:
- Spreca contesto nel processo principale (50+ tool calls per una query che un agente risolve in 5).
- Non usa le risorse disponibili (agenti dedicati, KB indicizzata, knowledge graph).
- Produce risposte inferiori (grep testuale vs embedding semantico + graph relations).

Le soglie di delega (>3 tool calls, >2 min, 2+ parallel) sono il punto oltre cui un agente specializzato è sempre più efficiente del processo principale.

## How to apply

Scatta OGNI volta che:
- Serve investigare un bug, una divergenza, un crash.
- Serve modificare codice C++/SV/Python con impatto multi-file.
- Serve rispondere a una domanda su CSR/ISA/spec/architettura.
- Servono 3+ tool calls di ricerca nel contesto principale.

Chi: processo principale SEMPRE (è la regola del routing), applicabile a TUTTI gli agenti core-v-verif come constraint secondario (quando un agente a sua volta deve ricorrere a sotto-agenti o MCP).

Check decisionale rapido:
1. "Ho già il file in contesto?" → Read/Edit diretto.
2. "Ho bisogno di >3 tool calls?" → delegare.
3. "È una domanda su CSR/ISA/spec/bug noti?" → MCP PRIMA di qualsiasi grep.
4. "Sono 2+ task indipendenti?" → tutti in parallelo.

## Source memory

- **Canonical**: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_mandatory_dispatch.md` (214 righe, fonte principale)
- **Subsumed (DEDUP)**: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_delegate_to_agents.md` — regola generale di delega, completamente coperta dalla tabella dispatch.
- **Partial subsume**: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_workflow_philosophy.md` — sezioni "Delega Agentica" (soglie) e "Anti-pattern catene Read/Grep" incluse qui. Le sezioni "Autonomia", "Agent Teams mechanics" e "Workflow Automatico" NON sono dispatch — restano in memory per trattamento separato (C.5 o altro sprint).

## Change log

- 2026-04-14 — migrato da memory feedback (FASE C.4); subsume `feedback_delegate_to_agents.md` e parzialmente `feedback_workflow_philosophy.md`; sorgenti memory NON rimossi (attesa C.9 verification).
