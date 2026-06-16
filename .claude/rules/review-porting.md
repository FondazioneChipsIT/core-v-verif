---
name: review-porting
description: MAI copiare file interi tra branch — porting hunk-per-hunk con review agente obbligatoria
level: L3-cvv
source_memory: [~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_review_porting.md]
created: 2026-04-14
---

# Review-Driven Branch Porting — core-v-verif

## Regola

Quando si portano modifiche da un branch all'altro (es. `mpaci/cv32e40p-working` → `mpaci/cv32e40p-clean`):

1. MAI fare `cp` di file interi tra branch con differenze strutturali.
2. SEMPRE analizzare il diff hunk-per-hunk (`git diff <branch1>..<branch2> -- <file>`).
3. Per ogni hunk, verificare coerenza con il codice circostante sul branch target.
4. SEMPRE lanciare agenti `gvsoc-cv32e40p` (o reviewer appropriato) per review PRIMA di build/test.
5. Verificare che le modifiche non rompano altri core (guard `#ifdef`/`#ifndef` presenti e corretti).
6. Diffidare di test che "passano" — possono non coprire il codice modificato.
7. Se il branch target ha una subclass (es. `Cv32e40pCsr`), verificare che le modifiche non duplichino funzionalità già presenti nella subclass.

## Why

Durante FASE 3 (sessione 2026-04-01), copiare `corev.hpp` da `working` a `clean` ha portato `stride 3` (incompatibile con `pulp_v2.hpp stride 4` e CSR address mapping). I test passavano perché nessuno esercitava hwloop loop 1 — bug latente.

Marco ha chiesto: "come facevano a funzionare su entrambi i branch?" — domanda che ha scovato il bug. Senza review agente, sarebbe arrivato in produzione.

### Pattern errori catturati (FASE 3)

- **Duplicazione con subclass**: mstatus config in `core.cpp` + `Cv32e40pCsr` (entrambi attivi, ordine random).
- **Guard mancante rompe altri core**: mcause zero removal senza `#ifndef` → rompe PulpV2.
- **Guard invertito rompe catena**: mhpmevent `#ifndef` saltava dichiarazione base → compile fail su target non-cv32e40p.
- **Write_mask hardcoded rompe generic RISC-V**: `mip 0xAAA`, `mtvec & ~1` — valori CV32E40P-specifici senza guard.

## How to apply

Scatta OGNI volta che:
- Si fa merge/rebase/cherry-pick tra branch con modifiche C++ GVSOC strutturali.
- Si porta un fix da branch `working` a branch `clean` (o viceversa).
- Si sincronizza con upstream (`openhwgroup/core-v-verif`, `gvsoc-*`).

Chi: processo principale quando pianifica porting, `gvsoc-developer` quando applica patch, `gvsoc-cv32e40p` come reviewer obbligatorio.

Sequenza obbligatoria:
```
git diff <src>..<dst> -- <file>
  → gvsoc-cv32e40p (review hunk-per-hunk)
  → gvsoc-developer (applica solo gli hunk approvati)
  → verify-gvsoc (smoke test post-porting)
```

## Source memory

- File: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_review_porting.md`
- Session originale: 2026-04-01 FASE 3, hwloop stride 3 vs 4 bug catturato da domanda Marco.

## Change log

- 2026-04-14 — migrato da memory feedback (FASE C.4)
