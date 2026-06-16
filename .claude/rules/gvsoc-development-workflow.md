---
paths:
  - "vendor_lib/gvsoc_rvvi/**"
  - "**/gvsoc/**"
---

# GVSOC Development Workflow — core-v-verif (L3)

> **Consolida e sostituisce** `gvsoc-rules.md` + `gvsoc-isolation-inline.md` (Marco grill-me iter 4 Q2 2026-05-18: "una rule sola").
> Metodo di lavoro operativo per modificare il modello ISS GVSOC quando il comportamento CV32E40P diverge dal RISC-V base. Path-gated: si attiva su qualsiasi file sotto `vendor_lib/gvsoc_rvvi/` o `**/gvsoc/`.
> Derivata da ~70 bug documentati — razionale completo in `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/research_notes/gvsoc_decision_tree_analysis_20260518.md`.

## 0. Flow: DPI-centered — GVSOC_TRACE è uno strumento di debug

Il flusso di verifica di produzione è la **co-simulazione DPI** (`ISS=GVSOC`, step-n-compare via `libgvsoc_rvvi.so`). È DPI-centered: ogni decisione di qualità si misura sul DPI.

**GVSOC_TRACE** (`ISS=GVSOC_TRACE`: simulazione RTL-only → GVSOC standalone → `bin/compare_traces.py`) **non è un flusso di verifica parallelo**. È uno **strumento di debug**: una struttura pulita e autoconsistente, usata per investigazione offline, ispezione di trace senza l'overhead DPI, e come baseline di regressione. La sua salute si misura con la suite **31/31 PASS** — quel numero DEVE restare verde, perché GVSOC_TRACE è affidabile come diagnostico solo se è pulito.

Inserimento chirurgico nel flow: GVSOC_TRACE entra nel decision tree in **un punto preciso** — il pre-filtro diagnostico Q1 (§3). Riprodurre una divergenza DPI anche in GVSOC_TRACE risponde a una sola domanda: "il bug è nell'ISS o nel bridge?".

## 1. Filosofia "good-enough"

- ISS e RTL NON devono combaciare al 100%. Obiettivo: modello solido per il grosso dei casi.
- MAI più di 2-3 cicli di fix sullo stesso bug. Bug che richiede >2 tentativi senza progresso, o replica micro-architetturale → **WONTFIX / KNOWN_DIVERGENCE**, raccolto nel regression report con motivazione.
- Focus su volume di test che passano, non su perfezione cycle-accurate.

## 2. Boundary `gvsoc/core/` vs `gvsoc/pulp/`

- `gvsoc/core/` = modello ISS RISC-V **generico condiviso** — impatta TUTTI i target GVSOC (PULP, Snitch, CV32E40P, …).
- `gvsoc/pulp/` = estensioni vendor (config Python, target, device).
- **Policy**: il lavoro CV32E40P-specifico vive nelle sottoclassi e nella config Python. `core/` si tocca col minimo indispensabile e solo col pattern good-citizen (§5). Approval gate §6.
- Esempi: una nuova property di config CV32E40P → `pulp/`. Un virtual hook con default conservativo → dichiarazione in `core/` (classe base), override in sottoclasse. Un fix di bug palese valido per tutti i core → `core/` direttamente.

## 3. Decision tree — selezione del fix-layer

Da seguire OGNI volta che il comportamento CV32E40P diverge da GVSOC.

```
NUOVA DIVERGENZA: CV32E40P RTL  vs  GVSOC ISS
│
├─ STEP 0 — Riproduci in ENTRAMBI i mode:
│     • ISS=GVSOC_TRACE   (RTL-only → GVSOC standalone → compare_traces.py)
│     • ISS=GVSOC         (DPI step-n-compare)
│
├─ Q1 — Fallisce in GVSOC DPI ma PASSA in GVSOC_TRACE?
│   └─ SÌ → LAYER 4 — BRIDGE PATCH
│           L'ISS è già corretto. È un problema di step-n-compare /
│           snapshot / volatile-mark / lifecycle. Fix SOLO in
│           rvvi_api2gvsoc.cpp / gvsoc_engine.cpp / *_wrap.sv.
│           ⚠ MAI editare l'ISS qui → regredisce la suite 31/31 GVSOC_TRACE.
│           Precedenti: D11,D12,D14b,D15,D16,D46 (trap-desync);
│                       D5,D8,D14,D20 (deadlock); D19,D33,D41 (volatile).
│   └─ NO → continua (divergenza reale, nell'ISS)
│
├─ Q2 — La root cause è una feature architetturale che GVSOC non ha?
│        (VP timer per stimoli IRQ reali, DbgUnit completo, PMA hardware)
│   └─ SÌ → WONTFIX / KNOWN_DIVERGENCE. Categorizza nel report. Stop.
│   └─ NO → continua
│
└─ Q3 — CHE TIPO di cosa diverge?   ← ramo principale
   │
   ├─ (A) VALORE STATICO  (reset value, write-mask, MISA bit, hartid)
   │      → LAYER 1 — JSON CONFIG: property in pulp_cores.py classe cv32e40p,
   │        letta in build()/build_cv32e40p() via get_child_int().
   │        ⚠ Vedi §8 disciplina config + §7 hazard reset-overwrite.
   │
   ├─ (B) PATH COMPORTAMENTALE  (cosa fa mret? una CSR indefinita trappa?
   │      ebreak entra in debug? c'è un check IRQ pre-fetch?)
   │      → LAYER 2 — VIRTUAL HOOK + SUBCLASS OVERRIDE: virtual nella classe
   │        base con default conservativo + override in Cv32e40p{Csr,Core,Irq}.
   │        ⚠ MAI piegare una decisione comportamentale in un flag JSON
   │          (anti-pattern Phase 2 audit §3: perdita di chiarezza + branch
   │          runtime nell'hot path).
   │
   ├─ (C) SIDE-EFFECT su accesso CSR  (scrivere X muta Y; leggere X ritorna
   │      un valore calcolato/congelato)
   │      → LAYER 3 — register_callback su CsrReg. Raro. Precedente: BUG-26.
   │
   └─ (D) ENCODING / SEMANTICA ISA CoreV2
          → workflow ISA separato: encoding errato → isa_cv32e40pv2.py;
            semantica nuova → handler C++ (riusa PulpV2 via label L=).
│
STEP FINAL — verifica:
  • Un fix alla volta → rebuild → test del caso SPECIFICO → PASS prima del prossimo.
  • Fix su mstatus o mtvec → verifica TUTTE le location (§7).
  • Fix su un header base → distclean + make gvsoc completo (§7).
  • >2 cicli senza progresso → WONTFIX, categorizza, stop.
```

**L'euristica "Python first"** dell'ex-`gvsoc-rules.md` è **superseded**: era corretta solo per i valori statici (ramo A). Per le decisioni comportamentali il layer giusto è il 2 (virtual hook), non un flag di config. Il discriminante è il *tipo* di cosa che diverge, non una preferenza a-priori.

## 4. I 4 layer — meccanismi

| Layer | Meccanismo | Dove |
|-------|-----------|------|
| **L1 JSON config** | property in `pulp_cores.py` `add_properties()` → `gvsoc_config_*.json` → letta via `get_js_config()->get_child_int()` | `gvsoc/pulp/.../pulp_cores.py` classe `cv32e40p` |
| **L2 virtual hook** | `virtual` nella classe base in `core/` + override in sottoclasse | `core/.../iss/src/{csr,core,irq}_cv32e40p.cpp` |
| **L3 register_callback** | `CsrReg::register_callback()` — lambda su accesso R/W della CSR | `csr.hpp:48` dichiara; usato in `csr_cv32e40p.cpp`, `irq_cv32e40p.cpp` |
| **L4 bridge patch** | patch post-exec / step-n-compare nel bridge DPI | `vendor_lib/gvsoc_rvvi/rvvi_api2gvsoc.cpp`, `gvsoc_engine.cpp`, `*_wrap.sv` |

Un quinto "layer" è solo-tooling per GVSOC_TRACE: artefatti di confronto (istruzioni cancellate `(C)`, re-sync off-by-one) → `bin/compare_traces.py`, non ISS né bridge.

## 5. Pattern good-citizen — virtual hook e `#ifdef`

**Regola cardine**: una modifica a `gvsoc/core/` NON deve mai cambiare il comportamento *funzionale* del codice condiviso per i target non-CV32E40P. L'inerzia per gli altri target è obbligatoria; il *meccanismo* con cui la si ottiene è una scelta tecnica, non un dogma. "Good-citizen" = modifica protetta da uno dei due meccanismi sotto.

Quando una divergenza comportamentale richiede di toccare `core/` (Layer 2):

- **Meccanismo preferito — virtual hook con default conservativo.** Aggiungi un metodo `virtual` alla classe base con un default che riproduce *esattamente* la semantica pre-esistente per i core non-CV32E40P; override nella sottoclasse `Cv32e40p{Csr,Core,Irq}`. Il default conservativo garantisce già l'inerzia funzionale → **non serve `#ifdef`**. È il pattern Plan A (11 hook shippati, behavior-preserving — Phase 2 audit).
- **Meccanismo di fallback — `#ifdef CONFIG_GVSOC_ISS_CV32E40P`.** Legittimo, NON vietato. Da usare dove un virtual hook è tecnicamente impossibile da inserire (nessun seam virtuale: funzione libera, codice fuori da una classe) o dove non si può comunque evitare un drift funzionale. La valutazione caso-per-caso "qui il hook sarebbe più invasivo dell'`#ifdef`" NON è motivo sufficiente — il default è il virtual hook. `#ifdef` e virtual hook sono **componibili**: anche un seam (dichiarazione + call-site) può essere wrappato in `#ifdef` se serve.
- **Criterio di scelta**: se modifiche minime con virtual hook ottengono il risultato → virtual hook, niente `#ifdef`. `#ifdef` solo dove altrimenti non si può evitare un drift funzionale. Ciò che è VIETATO non è l'`#ifdef` — è la modifica funzionale *non protetta* da nessuno dei due meccanismi.
- I file sottoclasse `*_cv32e40p.cpp`, finché vivono in `core/`, sono wrappati interamente in `#ifdef CONFIG_GVSOC_ISS_CV32E40P` — normale isolation (§6 posizione transitoria → target `pulp/` via #48).
- Per header `static inline`: crea un file di rimpiazzo sotto `cores/cv32e40p/`.
- Ogni touch a un file base resta soggetto all'approval gate §6, qualunque sia il meccanismo.

## 6. Approval gate — modifiche a `gvsoc/core/`

Marco grill-me iter 4 Q3 (2026-05-18): ogni modifica a `core/` richiede conferma + audit. Scope operativo:

| Categoria file | Gate |
|----------------|------|
| **File base / condivisi** di `core/` (`csr.cpp`, `csr.hpp` base, `core.cpp`, `priv.hpp`, `exception.cpp`, `exec_inorder.cpp`, `irq_riscv.hpp`, …) | **Conferma testuale Marco + audit PRIMA** della modifica |
| **File sottoclasse vendor** in `core/` (`csr_cv32e40p.cpp`, `core_cv32e40p.cpp`, `irq_cv32e40p.cpp` — interamente `#ifdef CONFIG_GVSOC_ISS_CV32E40P`-wrapped, CV32E40P-only per contenuto) | **Audit** (no conferma — `#ifdef`-wrap: compilano a nulla per gli altri core, zero impatto) |
| File in `gvsoc/pulp/` | Workflow normale (no gate) |

`priv.hpp`, `exec_inorder.cpp`, `exception.cpp` restano file ad alto rischio: conferma esplicita sempre.

**Posizione transitoria dei file sottoclasse.** I `*_cv32e40p.cpp` stanno fisicamente in `core/models/cpu/iss/src/` solo perché estendono classi base il cui codice è lì, e l'ISS è buildato come un unico componente con i sorgenti rooted in `core/`. NON è un vincolo architetturale: il `#ifdef`-wrap li isola già del tutto. Spostarli sotto `gvsoc/pulp/` è il refactor pianificato (#48 — gli header sono già destinati a `gvsoc/pulp/cpu/iss/include/cv32e40p/`, §10). Una volta spostati cadono nella riga "File in `gvsoc/pulp/`" → workflow normale, nessun gate. La riga 2 della tabella è quindi **transitoria**: vale finché i file restano in `core/`.

**Gate generale per dimensione/complessità.** Indipendentemente dal file — anche in `gvsoc/pulp/` o nel bridge — un fix >10 righe o strutturalmente complesso → conferma Marco PRIMA (ereditato da ex-`gvsoc-rules.md`).

**Conferma testuale** = ack esplicito di Marco (`OK`, `vai`, `procedi`, `confermo`, `amen`). Il silenzio NON è conferma.

## 7. Critical magnets — hazard handling

Categorie dove i fix sono stati applicati più volte, sono regrediti, o hanno desincronizzato. Trattamento obbligatorio:

- **mstatus** (#1 magnet, ~10 bug: D13/24/38/44/46/51/52/53, BUG-19/29a). Vive in 3 posti: `pulp_cores.py` (mask/reset), `Cv32e40pCsr::build_cv32e40p()`+`reset()` (default C++ + mask-fixup), `gvsoc_engine.cpp` (SD-bit nel getter DPI). **Hazard**: un fix in un posto silenziosamente contraddetto da un altro — D52 prova che un fix mstatus può essere cancellato da un commit non correlato. **Regola**: ogni modifica mstatus → verifica TUTTE E TRE le location + esegui sia `GVSOC_TRACE` sia `GVSOC` DPI.
- **mtvec** (#2 magnet, 8 bug). 4 code-path: reset value (0x1 vectored), write-mask (bit[7:1] hardwired 0), MODE-bit nel compare DPI, MODE-bit in `exception.cpp`, e la policy bootaddr (CV32E40P NON deriva mtvec da bootaddr). **Regola**: modifica mtvec → controlla tutti e 4.
- **DPI trap-desync** (cluster D11/D12/D14b/D15/D16/D46). Tutti bug del bridge, ISS corretto. **Hazard — l'inversione pericolosa**: vedere un mismatch trap-related in DPI e "fixare l'ISS" → regredisce GVSOC_TRACE e non fixa il DPI. **Regola**: divergenza in DPI + test PASS in GVSOC_TRACE → è il bridge (Q1 → Layer 4).
- **Build / struct-layout** (BUILD-1..5). Aggiungere campi o `virtual` a un header base cambia il layout della struct → SIGSEGV con `.so` ISS stale. `cmake` dice "Up-to-date" e tiene oggetti vecchi. **Regola**: modifica a un header base (incl. aggiunta di un `virtual`) → `distclean` o `touch` dei sorgenti + `make gvsoc` completo.

## 8. Disciplina config JSON

- I `gvsoc_config_*.json` sono **artefatti generati** — NON committarli (`.gitignore`). Source of truth unica = `pulp_cores.py`.
- Fix di un valore statico (Layer 1): edita `pulp_cores.py`, poi `cp` forzato in `install/generators/.../pulp_cores.py` (`cmake install` non aggiorna a timestamp invariato).
- **Post-refactor che cambia un component path** nel grafo GVSOC → `make comp CFG=<cfg>` MANDATORY per OGNI CFG attiva (default + pulp + pulp_fpu + pulp_fpu_zfinx + ogni altra attiva), non solo `default`. Lezione 2026-05-12: il move di `cv32e40p_exit_device` aggiornò solo il config `default`, lasciando 3 config stale con path obsoleto.
- Comportamento gestito via config JSON → fallback documentato (vedi tabella backup plan in `research_notes/plan_a_audit_phase2_investigation_20260512.md`).

## 9. Build chain truth

- `pulp_cores.py` `add_sources()` è la **single source of truth** per la lista sorgenti ISS.
- La funzione `generate_isa` in `CMakeLists.txt` è **dead code** — non è la catena di build reale.
- `riscv_exceptions=True` si passa SOLO via constructor — MAI `add_c_flags`.
- Timeout `gvrun` sempre a 10s (safety net).
- Dopo qualsiasi modifica al sottosistema IRQ o a un header base → clean rebuild (`distclean` + `make gvsoc`).

## 10. Naming convention

Le sottoclassi CV32E40P seguono `Cv32e40p<Component>`: `Cv32e40pCsr`, `Cv32e40pCore`, `Cv32e40pIrq`, `Cv32e40pException`. Header sotto `gvsoc/pulp/cpu/iss/include/cv32e40p/`.

## 11. Disciplina test / smoke

Dopo una modifica all'ISS o al bridge, prima di dichiarare un fix valido:

- **Smoke base** su tutte le CFG (`hello-world` DPI co-sim per default/pulp/pulp_fpu/pulp_fpu_zfinx).
- **1 test critico per ogni CFG**, scelto come critico *per quella CFG*: es. `cv32e40p_csr_access_test` (default), `pulp_hardware_loop` (pulp), `fpu_bugs_test` (pulp_fpu), `zfinx_func_cov_improve_test` (pulp_fpu_zfinx).
- Modifica su mstatus/mtvec → anche `GVSOC_TRACE` oltre al DPI.

## 12. Esempi accept / reject

- ✅ **ACCEPT**: virtual hook con default conservativo nella classe base + override in sottoclasse (pattern Plan A).
- ✅ **ACCEPT**: property `*_write_mask` in `pulp_cores.py` per un valore statico CV32E40P.
- ❌ **REJECT**: write-mask di una CSR hardcoded in C++ (lezione BUG-19 / D52 — un valore hardcoded sfugge alla source of truth ed è cancellabile in silenzio).
- ❌ **REJECT**: decisione comportamentale piegata in un flag JSON (anti-pattern Phase 2 audit §3 — perdita di chiarezza + branch runtime).

## Why

Il modello ISS GVSOC serve come reference per la co-simulazione DPI. Senza un metodo di lavoro condiviso: (a) i fix CSR si applicano nel posto sbagliato (la config JSON sovrascrive silenziosamente i default C++); (b) un bug del bridge viene scambiato per un bug dell'ISS e "fixarlo" regredisce la suite 31/31 GVSOC_TRACE; (c) modifiche a `core/` rompono altri target; (d) si bruciano cicli su bug architetturalmente irrisolvibili. Il decision tree è derivato dai dati: ~70 bug documentati mostrano che il fix-layer corretto si sceglie per *cosa* diverge.

## How to apply

Scatta su QUALSIASI lavoro sotto `vendor_lib/gvsoc_rvvi/` o `**/gvsoc/`:
- Diagnosi di una divergenza CV32E40P vs RTL → segui il decision tree §3 da Step 0.
- Modifica a `gvsoc/core/` → applica l'approval gate §6 PRIMA.
- Refactor che cambia component path → disciplina config §8.
- Chi: agenti `gvsoc-developer`, `gvsoc-cv32e40p`, `gvsoc-debugger`, processo principale quando propone patch.

## Source

- Decision tree data-derived: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/research_notes/gvsoc_decision_tree_analysis_20260518.md`
- Plan A audit: `research_notes/plan_a_audit_phase2_investigation_20260512.md`, `plan_a_residual_ifdef_audit_20260512.md`
- Validation: `research_notes/plan_a_validation_matrix_20260512.md` (8/8 PASS)
- Metodo: Marco grill-me iter 1-4 (2026-05-12 / 2026-05-18), 19 decisioni consolidate in `project_session_state.md`.

## Change log

- 2026-05-18 — nuova rule L3. **Consolida e sostituisce** `gvsoc-rules.md` (filosofia good-enough + priorità config + file condivisi) e `gvsoc-isolation-inline.md` (isolation fallback rules), archiviate in `memory/archive/rules_pre_consolidation_20260518/` alla conferma di Marco. Novità vs le vecchie: decision tree 4-layer data-derived (§3), carve-out virtual hook senza `#ifdef` (§5), approval gate con scope base/subclass (§6), critical magnets (§7), disciplina config regen post-refactor (§8). Euristica "Python first" superseded → narrowed a valori statici. NB: `gvsoc-dpi-details.md` (bridge/DPI reference) NON è consolidata qui — appartiene allo scope di `tb-cv32e40p-discipline.md` (grill-me iter 5).
- 2026-05-18 review-pass (Marco) — §6: aggiunta nota "posizione transitoria" dei file sottoclasse (vivono in `core/` per build wiring, non per vincolo; target `pulp/` via refactor #48) + reintrodotto il gate generale "fix >10 righe → conferma Marco" da ex-`gvsoc-rules.md`.
- 2026-05-18 drift-resolution (Marco) — §5 riscritta. L'hygiene audit aveva trovato che il vecchio bullet "MAI nuovi `#ifdef` inline → vanno sostituiti con virtual hook" era una falsa dicotomia in contrasto con la review di Germain su PR#146. Criterio Marco: la regola cardine è l'inerzia *funzionale* del codice condiviso per i target non-CV32E40P, non il meccanismo. Virtual hook con default conservativo = meccanismo preferito (Plan A: 11 hook behavior-preserving, zero drift funzionale — Phase 2 audit). `#ifdef CONFIG_GVSOC_ISS_CV32E40P` = fallback legittimo (non vietato) dove il hook non ottiene l'inerzia in modo pulito; i due sono componibili. Vietato = la modifica funzionale non protetta. Plan A resta valido as-is.
