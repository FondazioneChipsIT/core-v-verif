---
name: questa-license
description: Questa 2025.3 richiede SALT_LICENSE_SERVER via module load — SEMPRE caricare prima di vsim
level: L3-cvv
source_memory: [~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_questa_license.md]
created: 2026-04-14
---

# Questa License Setup — core-v-verif

## Regola

SEMPRE caricare `module load questa/2025.3` nella shell corrente PRIMA di qualsiasi comando `vsim`, `make comp`, `make test`.

In alternativa, esportare esplicitamente:
```
SALT_LICENSE_SERVER=29000@10.20.12.111
```

Per `micromamba run` o contesti isolati, passare la variabile con `export` prima del comando.

MAI lanciare `vsim` senza verificare che `SALT_LICENSE_SERVER` sia settato nell'environment corrente.

## Why

Questa 2025.3 richiede `SALT_LICENSE_SERVER=29000@10.20.12.111`. Senza il modulo caricato, `vsim` fallisce con:
```
Invalid license environment. Application closing.
```

Il `SALT_LICENSE_SERVER` NON è in `.bashrc` ma nel modulefile `questa/2025.3`. Quindi shell fresh senza `module load` falliscono immediatamente.

## How to apply

Scatta OGNI volta che:
- Si esegue `make comp`, `make test`, `make trace` in `cv32e40p/sim/uvmt/` (o equivalente).
- Si lancia `vsim` o `vlib`/`vlog`/`vopt` direttamente.
- Un agente `sim-operator` viene dispatcato (includere `module load questa/2025.3` nello script).

Chi: tutti gli agenti che operano in `core-v-verif/`, con priorità `sim-operator`, `gvsoc-regression-orchestrator`, `verify-gvsoc` skill.

Check rapido: `echo $SALT_LICENSE_SERVER` deve tornare `29000@10.20.12.111`.

## Source memory

- File: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_questa_license.md`
- Session originale: `6eb4f19a-4c03-452d-af51-eeb5c728ea2a` — primo incontro del failure mode in bring-up Questa 2025.3.

## Change log

- 2026-04-14 — migrato da memory feedback (FASE C.4)
