---
name: branch-naming
description: Tutti i branch di sviluppo DEVONO avere prefisso mpaci/
level: L3-cvv
source_memory: [~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_branch_naming.md]
created: 2026-04-14
---

# Branch Naming Convention — core-v-verif

## Regola

Tutti i branch di sviluppo DEVONO avere il prefisso `mpaci/`.

Esempi validi:
- `mpaci/cv32e40p-clean`
- `mpaci/cv32e40p-gvsoc`
- `mpaci/bug-32-mstatus-write-mask`

Esempi NON validi:
- `cv32e40p-clean` (manca prefisso)
- `fix/mstatus` (prefisso diverso)
- `claude/feature-x` (prefisso sbagliato)

MAI creare branch senza `mpaci/`. Se trovi branch senza prefisso (creati da te o da un agente), rinominali con `git branch -m <nome> mpaci/<nome>`.

## Why

Convenzione richiesta esplicitamente da Marco per identificare i propri branch su fork e repo condivise (specialmente `core-v-verif` e `gvsoc*` forks). Senza prefisso i branch di sviluppo si confondono con upstream e con branch di altri collaboratori.

## How to apply

Scatta OGNI volta che:
- Si esegue `git checkout -b <nome>` o `git switch -c <nome>`.
- Un agente o skill (`commit-commands:commit-push-pr`, `push`, `review`) crea un branch.
- Si prepara una PR verso `core-v-verif` o `gvsoc*` fork.

Chi: processo principale, TUTTI gli agenti core-v-verif, skill git (`commit`, `push`, `commit-push-pr`).

Check rapido prima del push: `git branch --show-current | grep -q '^mpaci/' || echo "WARNING: branch senza prefisso mpaci/"`.

## Source memory

- File: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_branch_naming.md`
- Context originale: convenzione consolidata su fork `marpac3/core-v-verif`, `marpac3/gvsoc-core`, `marpac3/gvsoc-pulp`.

## Change log

- 2026-04-14 — migrato da memory feedback (FASE C.4)
