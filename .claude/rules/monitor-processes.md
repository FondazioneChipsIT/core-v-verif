---
name: monitor-processes
description: Monitorare processi DPI ogni 5-10 min, killare stuck a 0% CPU oltre 60 min
level: L3-cvv
source_memory: [~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_monitor_processes.md]
created: 2026-04-14
---

# Monitor DPI Processes — core-v-verif

## Regola

Durante regressioni DPI (`sim-operator` batch, `gvsoc-regression-orchestrator`, WP-8 e simili):

- SEMPRE fare un check periodico dei processi `vsimk` ogni 5-10 minuti.
- Se un processo è a 0% CPU per più di 2x il tempo atteso (tipicamente >60 min per test normali) → killare SUBITO e rieseguire.
- MAI lasciare processi stuck "per sicurezza" — bloccano i batch agents e sprecano ore.

Comando check rapido:
```
ps aux | grep vsimk | awk '{print $2, $3, $10, $11}'
# Colonne: PID, %CPU, elapsed, command
```

Kill pattern:
```
kill -9 <PID>  # solo dopo conferma che è stuck, non running
```

## Why

Nella sessione 2026-03-26, 5 processi `vsimk` sono rimasti stuck per 1h31m a 0% CPU (deadlock DPI futex) senza essere rilevati. Risultato: batch agents bloccati, ore sprecate, regressione WP-8 compromessa.

Il failure mode è silenzioso: il processo NON crasha, consuma RAM ma 0% CPU, e il test non completa mai.

## How to apply

Scatta OGNI volta che:
- Si lancia una regressione DPI (multi-test o full-regress).
- Un `sim-operator` batch gira in background.
- Un test singolo DPI supera il 1.5x del tempo medio atteso.

Chi: `gvsoc-regression-orchestrator` (obbligatorio come step Phase 1), processo principale quando supervisiona batch, skill `loop` per polling periodico (`/loop 5m /check-dpi-processes`).

Soglia concreta: 0% CPU + elapsed > 60 min → kill immediato, NON aspettare.

## Source memory

- File: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/feedback_monitor_processes.md`
- Session originale: 2026-03-26, WP-8 DPI regression, deadlock futex identificato solo post-mortem.

## Change log

- 2026-04-14 — migrato da memory feedback (FASE C.4)
