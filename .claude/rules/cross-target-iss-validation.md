# Cross-Target ISS Validation — core-v-verif (L3)

## Regola

Dopo OGNI modifica a un sorgente ISS **condiviso/generico** di GVSOC (un file sotto `vendor_lib/gvsoc_rvvi/gvsoc/core/models/cpu/iss/` che viene compilato ANCHE dai target non-CV32E40P), DEVI validare che la modifica NON rompa la compilazione degli altri core (ri5cy, snitch, spatz, cva6, pulp, …) — cioè quando `CONFIG_GVSOC_ISS_CV32E40P` NON è definito.

### Cosa è "condiviso" (soggetto al check) vs "cv32e40p-only" (esente)

| Esente (cv32e40p-only — NON serve check) | Condiviso (serve check) |
|------------------------------------------|--------------------------|
| `isa/corev.hpp` (incluso SOLO da `cores/cv32e40p/class.hpp`) | `src/csr.cpp`, `include/csr.hpp` |
| `isa_gen/isa_cv32e40pv2.py` | `src/core.cpp`, `include/core.hpp` |
| `include/cores/cv32e40p/*`, `src/cv32e40p/*` (`#ifdef`-wrapped) | `priv.hpp`, `exec/exec_inorder.cpp`, `exception.cpp` |
| | `irq/irq_riscv.hpp`, `isa/rv32i.hpp`, `isa/pulp_v2.hpp`, gli altri `isa/*.hpp` shared |

`corev.hpp` è esente perché è incluso da un solo file (`cores/cv32e40p/class.hpp`); gli altri core PULP usano `pulp_v2.hpp`. Verifica con `grep -rn 'isa/<file>' models/cpu/iss/include/cores/*/class.hpp` se hai dubbi su chi include un header.

### Due livelli di check

**1. Check veloce, always-on (deterministico) — OBBLIGATORIO ad ogni edit di un file condiviso.**
Il sorgente preprocessato SENZA il define DEVE restare byte-identico alla baseline upstream. In pratica: ogni modifica CV32E40P in un file condiviso DEVE stare dentro `#ifdef CONFIG_GVSOC_ISS_CV32E40P` (o un virtual hook con default conservativo, rule `gvsoc-development-workflow.md` §5). Procedura: strip dei blocchi `#ifdef CONFIG_GVSOC_ISS_CV32E40P` (tenendo il ramo `#else`) e `diff` contro la baseline → deve essere IDENTICO.

```bash
# strip dei blocchi #ifdef CONFIG_GVSOC_ISS_CV32E40P (tiene #else), poi diff vs baseline
git show <baseline-sha>:<file> | <strip-cv32> > /tmp/old.txt
git show HEAD:<file>           | <strip-cv32> > /tmp/new.txt
diff -q /tmp/old.txt /tmp/new.txt   # IDENTICAL = non-cv32e40p targets unaffected
```
Baseline = il commit upstream/frozen su cui sei buildato (es. `22216971`, head PR #146). Se IDENTICAL → i target non-CV32E40P non sono toccati, fine.

**2. Check periodico (build reale) — ogni tanto, e prima di proporre una PR.**
Cross-target build dei target non-CV32E40P senza il define. **NOTA CRITICA**: l'albero vendored `gvsoc_rvvi` è tarato per CV32E40P (driver `gvrun` + target `cv32e40p-standalone`); i target upstream (rv64/snitch/spatz/cva6/…) qui falliscono il config-gen per drift di API gvrun (`Target.__init__() got an unexpected keyword argument 'name'`). Quindi il cross-target build COMPLETO (`make all`) si esegue nei repo **UPSTREAM** `gvsoc-core` / `gvsoc-pulp` (dove è già stato validato pulito, PR #146 comment 2026-05-26). Nell'albero vendored, il check veloce §1 è il proxy affidabile e sufficiente per il singolo edit.

## Why

Germain (maintainer, review PR #146 del 2026-04-10 + 2026-05-31): *"this ISS is still used for some old targets for which I don't have access to the tests... I just prefer to have zero modification in the generic. Could you guard them?"* → il generico ISS DEVE preprocessare back a upstream byte-per-byte senza `CONFIG_GVSOC_ISS_CV32E40P`. Una modifica NON guardata a un file condiviso rompe silenziosamente ri5cy/snitch/spatz/cva6 — che non possiamo testare facilmente nell'albero vendored. Il check veloce §1 lo previene deterministicamente, senza dipendere da un build cross-target che qui non gira.

Esempio reale (2026-06-16, commit `aab3b795`): unica modifica a file condiviso = mask hwloop LPSTART/LPEND in `csr.cpp`, dentro `#ifdef CONFIG_GVSOC_ISS_CV32E40P`. Check §1: `csr.cpp` preprocessato senza il define IDENTICO a `22216971` → target non-CV32E40P non toccati. PASS.

## How to apply

Scatta dopo OGNI edit a un file condiviso (tabella sopra). Chi: processo principale + agenti `gvsoc-developer`/`gvsoc-cv32e40p` quando propongono patch a file condivisi. corev.hpp/isa_cv32e40pv2.py/cores/cv32e40p/* esenti (cv32e40p-only).

- Se il check §1 fallisce (il preprocessato senza define NON è identico) → la modifica NON è guardata correttamente → o avvolgila in `#ifdef CONFIG_GVSOC_ISS_CV32E40P`, o convertila in virtual hook con default conservativo (§5), PRIMA di committare.
- Prima di proporre/aggiornare una PR upstream → esegui il check §2 (cross-target build nei repo upstream) come gate finale.

## Cross-ref

- Rule sister L3: `gvsoc-development-workflow.md` §5 (good-citizen: virtual hook vs `#ifdef`), §6 (approval gate file base), §11 (smoke discipline). Questa rule è la VERIFICA che la proprietà "behavior-preserving per non-CV32E40P" di §5 regga davvero.
- Rule L1 `forgejo-flow.md` / `pr-philosophy.md`: il check §2 è gate pre-PR.
- Origine: Marco directive 2026-06-16 ("verifica ogni tanto che la compilazione di altri moduli gvsoc senza define cv32e40p funzioni; impostalo come regola di lavoro"). Driver PR #146 Germain review.

## Change log

- 2026-06-16 — nuova rule L3. Trigger: Marco directive post force-push branch `mpaci/cv32e40p-dpi-fidelity`. Check veloce §1 deterministico (preprocess-strip + diff) sempre-attivo; check §2 build cross-target periodico nei repo upstream (vendored tree cv32e40p-tuned, gvrun API drift sui target upstream). corev.hpp esente (cv32e40p-only by inclusion).
