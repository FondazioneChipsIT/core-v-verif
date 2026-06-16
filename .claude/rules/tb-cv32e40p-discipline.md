---
paths:
  - "cv32e40p/tb/uvmt/*gvsoc*"
  - "cv32e40p/tb/uvmt/*iss_wrap*"
  - "lib/uvm_agents/uvma_rvvi/**"
  - "vendor_lib/gvsoc_rvvi/*.cpp"
  - "vendor_lib/gvsoc_rvvi/*.hpp"
  - "cv32e40p/sim/uvmt/*gvsoc*"
  - "cv32e40p/regress/*covg_no_pulp*"
---

# Disciplina TB — CV32E40P su GVSOC co-simulazione (L3)

> **Rule sorella di `gvsoc-development-workflow.md`** (lato ISS C++). Quella copre la disciplina dentro `gvsoc/core/` vs `gvsoc/pulp/`; **questa** copre il lato testbench SystemVerilog, il bridge DPI e gli script di regressione. Assorbe la ex `gvsoc-dpi-details.md` (rimossa — il suo contenuto storico vive in git e `project_gvsoc_bugs.md`).

## 1. Regola cardine — la stessa simmetria di §5 (lato ISS)

`gvsoc-development-workflow.md` §5 dice: una modifica a `gvsoc/core/` NON deve mai cambiare il comportamento *funzionale* del codice condiviso per i target non-CV32E40P. Il lato testbench ha **la stessa identica struttura**, solo con attori diversi:

| Lato ISS C++ (§5 di `gvsoc-development-workflow.md`) | Lato TB SystemVerilog (questa rule) |
|------------------------------------------------------|-------------------------------------|
| `gvsoc/core/` — base ISS condivisa | `uvmt_cv32e40p_iss_wrap_common.svh` + `lib/uvm_agents/uvma_rvvi/**` — wiring TB condiviso |
| `gvsoc/pulp/` — estensioni vendor | `uvmt_cv32e40p_gvsoc_wrap.sv` — wrap GVSOC-specifico |
| target vecchi non testabili da Germain | il percorso ISS **Imperas** |
| virtual hook con default conservativo | macro con default `` `ifndef ``-protetto |
| `#ifdef CONFIG_GVSOC_ISS_CV32E40P` | `` `ifdef USE_GVSOC `` |

**Regola cardine**: una modifica a un file TB *condiviso* (`uvmt_cv32e40p_iss_wrap_common.svh`, `lib/uvm_agents/uvma_rvvi/**`, `rvviTrace.sv`) NON deve mai cambiare il comportamento del percorso di co-simulazione **Imperas**. L'inerzia per il percorso Imperas è obbligatoria; il *meccanismo* con cui la si ottiene è una scelta tecnica, non un dogma — esattamente come per i virtual hook lato ISS.

## 2. Carve-out dei file TB condivisi — il pattern macro-override

Quando un comportamento GVSOC-specifico richiede di toccare un file TB condiviso:

- **Meccanismo preferito — macro con default conservativo `` `ifndef ``-protetto.** Il file condiviso definisce un default che riproduce *esattamente* la semantica pre-esistente; il wrap GVSOC lo sovrascrive con `` `define `` PRIMA dell'`` `include ``. Il pattern canonico è già nel codice — `uvmt_cv32e40p_iss_wrap_common.svh:17-19`:
  ```systemverilog
  `ifndef RVVI_SET_TRAP_CSR
  `define RVVI_SET_TRAP_CSR(CSR_ADDR, CSR_NAME) `RVVI_SET_CSR(CSR_ADDR, CSR_NAME)
  `endif
  ```
  Il file condiviso dà come default la formula CSR standard = ciò che esisteva prima di GVSOC. Il wrap GVSOC (`uvmt_cv32e40p_gvsoc_wrap.sv:42-62`) ridefinisce `RVVI_SET_TRAP_CSR` con la formula trap-aware (wdata diretto, vedi D17) **prima** di includere `uvmt_cv32e40p_iss_wrap_common.svh:158`. Il wrap Imperas NON ridefinisce la macro → ricade sul default `RVVI_SET_CSR` → comportamento identico a prima → **percorso Imperas inerte**. È la forma SV-macro del virtual hook di §5: la macro è il "metodo virtuale", il default `` `ifndef `` è il "default conservativo", il `` `define `` nel wrap è l'"override della sottoclasse".

- **Meccanismo di fallback — `` `ifdef USE_GVSOC ``.** Legittimo, NON vietato. Da usare dove un seam macro-override non esiste (codice non macro-izzabile) o dove un drift funzionale del percorso condiviso è comunque inevitabile. È già usato nel codice: `rvviRefRetireAndCompare` (il batch DPI GVSOC-only) è dichiarato inline e guardato da `` `ifdef USE_GVSOC `` in `rvvi_trace2api.sv:42`.

- **Criterio di scelta** (identico a §5): se una macro-override con default conservativo ottiene il risultato → macro, niente `` `ifdef ``. `` `ifdef USE_GVSOC `` solo dove altrimenti non si può evitare un drift funzionale sul percorso Imperas. Ciò che è VIETATO non è l'`` `ifdef `` — è la modifica al wiring condiviso che altera il comportamento Imperas *senza* essere protetta da nessuno dei due meccanismi.

- **Codice nuovo GVSOC-specifico va nel wrap GVSOC.** `uvmt_cv32e40p_gvsoc_wrap.sv` è l'analogo di `gvsoc/pulp/`: il watchdog WFI, l'import DPI `rvviRefIsFinished()`, il `ref_init` GVSOC, i parametri FPU/ZFINX (dichiarati per simmetria di API col wrap Imperas — `uvmt_cv32e40p_gvsoc_wrap.sv:104-106`) vivono lì, non nel file condiviso.

## 3. Contratto DPI del bridge — due contratti distinti, NON confonderli

### 3a. Contratto DPI "sul filo" (signature + `rvviTrace`)

RVVI v1.37 è una API di terze parti *vendorizzata* (`rvviApiPkg.sv` + `rvviApi.h`, ~60 funzioni `extern "C"` in `rvvi_api2gvsoc.cpp`). Lo stato attraversa il confine DPI **non** come struct packed passata per valore, ma come: (a) firme scalari (`uint32_t`/`uint64_t`); (b) l'interfaccia SystemVerilog `rvviTrace`, letta campo-per-campo. Quindi il "contratto DPI" è l'insieme {firme delle funzioni} ∪ {campi di `rvviTrace`}. Cambiare una firma DPI o un campo di `rvviTrace` richiede edit in lockstep.

### 3b. Contratto di layout della classe base C++ (`iss.hpp`) — concern SEPARATO

Distinto dal contratto DPI: il layout della classe base C++ (campi struct + vtable generata dai metodi `virtual`) deve combaciare tra la `libgvsoc_rvvi.so` compilata e gli oggetti GVSOC. Aggiungere un campo o un `virtual` a una classe base sposta il layout; una `.so` stale → SIGSEGV. È la famiglia BUILD-1..5 — vedi `gvsoc-development-workflow.md` §7. NON è un problema DPI: è un problema ABI/rebuild. Dopo ogni edit a una classe base ISS → rebuild completo `make gvsoc` della `.so`.

### 3c. Punti di accoppiamento — da editare in lockstep

| Se cambi… | Devi aggiornare in lockstep… |
|-----------|------------------------------|
| firma DPI / forma del batch call | `rvvi_api2gvsoc.cpp` (definizione) + `rvvi_trace2api.sv:48` (import inline `rvviRefRetireAndCompare`) e/o `rvviApiPkg.sv` (import canonici) |
| campo di `rvviTrace` | `rvviTrace.sv` + il wiring RVFI→RVVI in `uvmt_cv32e40p_iss_wrap_common.svh` |
| layout classe base C++ (`iss.hpp`) | rebuild completo `libgvsoc_rvvi.so` via `make gvsoc` — vedi `gvsoc-development-workflow.md` §7 |

**Mina nota**: `rvviRefRetireAndCompare` è l'**unica** funzione DPI GVSOC-specifica e NON è in `rvviApiPkg` — è dichiarata *inline* in `rvvi_trace2api.sv:48`. Chi modifica il batch step-n-compare cerca il blocco import canonico e la manca. Quando tocchi il batch DPI, tocca anche quella dichiarazione inline.

## 4. `ref_init` e step-n-compare — lezioni di disciplina (assorbite da `gvsoc-dpi-details.md`)

- **Volatile / compare-enable in `ref_init` sono accoppiati alla fedeltà dell'ISS.** GVSOC non modella alcuni CSR ciclo-per-ciclo (contatori HPM, cycle/instret, CSR di debug). Il task `ref_init` in `uvmt_cv32e40p_gvsoc_wrap.sv:163` li marca volatile (`rvviRefCsrSetVolatile` / `rvviRefCsrSetVolatileMask`) e abilita il confronto solo per i CSR che l'ISS modella. Quando aggiungi copertura CSR all'ISS GVSOC, aggiorni ANCHE `ref_init` (compare-enable + togli il volatile). I due lati sono accoppiati.
- **Una trap = 2 step ISS.** GVSOC consuma 2 step ISS per eccezione. Sul retire di una trap il bridge step-n-compare emette UN `rvviRefEventStep` extra silenzioso e SALTA il confronto. Non "correggere" lo step extra apparente — è intenzionale (D14b).
- **Watchdog WFI.** Dopo che l'exit device scatta, l'ISS segnala finished; ma se il DUT entra in WFI prima che `$finish` venga processato, Questa va in hang. Il wrap GVSOC fa polling di `rvviRefIsFinished()` da un blocco `initial` e forza `$finish` (`uvmt_cv32e40p_gvsoc_wrap.sv:144-153`). Qualunque modifica al percorso di terminazione deve preservare questo watchdog.
- **Artefatti PC=0 da pipeline-flush.** Il confronto è saltato sui retire di flush con PC=0 — non è una divergenza.

## 5. Disciplina script di regressione

La rule codifica i *pattern*; la pulizia effettiva degli script esistenti è lavoro a livello di work item (vedi `script_inventory_cleanup_20260512.md`).

- **Mai log di regressione su VCS.** `.gitignore` per `cv32e40p/sim/uvmt/regress_results/*.log`. Log e artefatti pesanti → `/data2/marco.paci/` o `/tmp/`, mai su /home NFS né committati (rule L0 `storage-locations.md`).
- **Rilevamento timeout in pipeline.** In `timeout … | tail | grep`, `$?` cattura l'exit code di `grep`, NON di `timeout`. Per rilevare un timeout serve `${PIPESTATUS[0]}` con `set -o pipefail`. Mai `$?` nudo dopo una pipeline.
- **Una sola fonte di verità per la test-list.** La lista test della regressione GVSOC vive nello yaml `cv32e40p/regress/`, non duplicata embedded nello script bash.
- **Script Python**: stdlib-only preferito, type hints sulle signature, docstring su ogni funzione pubblica (`main()` inclusa), blocco `if __name__ == "__main__"`. Dati derivabili da KB (mappe CSR) caricati, non hardcoded.
- Gli script di regressione GVSOC vivono in `cv32e40p/sim/uvmt/`.

## 6. Approval gate

Toccare un file TB *condiviso* — `uvmt_cv32e40p_iss_wrap_common.svh`, `lib/uvm_agents/uvma_rvvi/**`, `rvviTrace.sv`, o i percorsi core di `rvvi_api2gvsoc.cpp` — è soggetto allo **stesso approval gate di §6 di `gvsoc-development-workflow.md`**: conferma con Marco prima di un touch che potrebbe alterare il percorso Imperas. Editare il wrap GVSOC-specifico (`uvmt_cv32e40p_gvsoc_wrap.sv`) o regioni `` `ifdef USE_GVSOC `` GVSOC-only è libero (nessuna esposizione Imperas).

**Nota upstream**: se la co-simulazione GVSOC del TB è destinata all'upstream openhwgroup/core-v-verif, il gate è *stretto* — un maintainer la rivedrà, come Germain sul lato ISS — e va assunto stretto di default. Se resta fork-only, il gate è igiene interna. Default operativo corrente: **stretto**.

## Why

Il lato ISS C++ e il lato TB SystemVerilog hanno la stessa struttura "base condivisa + estensione vendor + target che non posso rompere". Senza una rule esplicita, la lezione di §5 (non rompere chi non controlli; estendi con default conservativo; il meccanismo è una scelta) non si trasferisce automaticamente al TB, e chi tocca `uvmt_cv32e40p_iss_wrap_common.svh` rischia di rompere silenziosamente la co-simulazione Imperas — un percorso funzionante e testato di core-v-verif. La distinzione tra contratto DPI (firme + `rvviTrace`) e contratto di layout C++ (`iss.hpp` ABI) è codificata perché confonderli porta a diagnosi sbagliate: un SIGSEGV da `.so` stale non è un bug DPI.

## How to apply

Scatta quando si edita: il wrap GVSOC (`uvmt_cv32e40p_gvsoc_wrap.sv`), il wiring condiviso (`uvmt_cv32e40p_iss_wrap_common.svh`), l'agent RVVI (`lib/uvm_agents/uvma_rvvi/**`), il bridge DPI (`rvvi_api2gvsoc.cpp`, `gvsoc_engine.cpp`), o gli script di regressione GVSOC.

Check decisionale prima di toccare un file condiviso:
1. La modifica può stare in `uvmt_cv32e40p_gvsoc_wrap.sv` (wrap GVSOC-specifico)? → falla lì, gate libero.
2. Serve toccare il file condiviso? → macro `` `ifndef ``-default (preferito) o `` `ifdef USE_GVSOC `` (fallback) → approval gate §6.
3. Cambi una firma DPI o un campo `rvviTrace`? → consulta la tabella lockstep §3c, edita tutti i punti insieme.
4. Edit a una classe base ISS C++? → rebuild completo `make gvsoc` (§3b).

## Cross-ref

- Rule sorella lato ISS: `gvsoc-development-workflow.md` (§5 carve-out / §6 approval gate / §7 BUILD-1..5)
- Rule L0 storage: `~/.claude/rules/common/storage-locations.md` (log su /data2 o /tmp)
- Rule L0 SV style: `~/.claude/rules/systemverilog/coding-style.md`
- Inventory script: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/research_notes/script_inventory_cleanup_20260512.md` (B1-B4, C1)
- Storico DPI fix D1-D62: `project_gvsoc_bugs.md` (NON duplicato qui — la rule è timeless)

## Change log

- 2026-05-18 — nuova rule L3 (`/grill-me` iter 5). Gemello lato TB di `gvsoc-development-workflow.md`. Assorbe `gvsoc-dpi-details.md` (rimossa): contenuto reference D1-D15 NON migrato verbatim (stale, lo storico vive in `project_gvsoc_bugs.md`); migrate solo le lezioni di disciplina (§4). Codifica la simmetria §5↔TB (macro-override = virtual hook), i due contratti distinti DPI vs ABI C++ (§3), la disciplina script (§5).
