# Plane CVV Project — Source of Truth (L3)

> **L3 project rule**. Codifica come navigare, interrogare e mantenere coerente il progetto Plane CVV (cv32e40p verification). Estende la rule L1 `plane-sync.md` con specifiche cv32e40p.

## Regola

### 1. Plane CVV è il PM mirror autoritativo (read for status, write via tooling)

- **Workspace**: `agent-hq` slug `agent-hq` UUID `1a646780-ef0d-4563-bc63-576dc36ffe1c`
- **Project**: "proj cvv" UUID `5f1c2e3e-2d72-4c76-b3ee-a533a7a575fe`
- **Edition**: `PLANE_COMMUNITY` (CE — verifica `/api/instances/`). EE features (Initiatives/Milestones/CustomWITypes/WorkLogs) NON disponibili.
- **URL UI**: `http://localhost:8080/agent-hq/projects/{PROJ_UUID}/`
- ⚠️ **Reachability caveat**: Plane CE @`localhost:8080` può essere DOWN (al 2026-06-24 HTTP 000). Verifica reachability (`curl /api/instances/`) PRIMA di fidarti di conteggi/UUID/status letti da Plane. Plane è MIRROR, NON source-of-truth — in caso di Plane down/conflitto, memory PRIMARY vince.

Memory PRIMARY (`~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/`) resta autoritativa per stato corrente. Plane = **MIRROR** (visibility layer + audit trail Marco-facing).

### 2. Ownership prefix discipline (TUTTI i WI nuovi devono seguire)

- Tutti i WI cv32e40p hanno prefix `[CVV-N] subject` o vivono in modulo `CV32E40P-MEGA-*`
- Un WI vive in UN solo modulo (no cross-module)
- Modulo prefix mapping consolidato:

| Modulo | UUID | Scope |
|--------|------|-------|
| CV32E40P-MEGA-DPI-BRIDGE | `eafdf7c5-5699-4425-9a4b-0232657350c8` | DPI bridge SV↔ISS, RVVI, batch DPI |
| CV32E40P-MEGA-CSR-MODEL | `2c62861f-45a6-4529-8612-0ecb69c37c0a` | CSR fidelity, write masks, volatile, traps |
| CV32E40P-MEGA-ISA-CORE | `5457d640-2112-4eb0-b2f3-2720b0baf51c` | ISA encoding/semantics CoreV2, hwloop |
| CV32E40P-MEGA-TB-INFRA | `9e317fd1-222d-4f83-8a83-af512d0e98fe` | UVM testbench, agents, sequences |
| CV32E40P-MEGA-PERF | `da028610-46a4-43b5-b40f-a48f88f96762` | DPI co-sim performance optimization |
| CV32E40P-MEGA-DEBT-ROADMAP | `65b88d69-64a4-4639-ae4d-758a77cb7a72` | Tech debt + future roadmap + DOC-HUB |

### 3. Auth model dual-tier (TUTTI i tool MUST rispettare)

| Endpoint prefix | Auth | Token file |
|-----------------|------|------------|
| `/api/v1/...` | `X-API-Key: <token>` | `~/.claude/secrets/plane-api-token` chmod 600 |
| `/api/...` (pages, views, project detail) | session cookie | `~/.claude/secrets/plane-bot-credentials` chmod 600 (EMAIL+PASSWORD) |

Bot user: `cvv-bot@cvv.local` UUID `bc6d09d6-49ec-46ee-bbef-4055c05ee507` workspace+project admin (role 20).

**Session-auth flow** (Phase 10 BREAKTHROUGH):
1. `GET /auth/get-csrf-token/` → csrftoken cookie + JSON `{"csrf_token": ...}`
2. `POST /auth/sign-in/` con header `X-CSRFToken` + form-encoded `{email, password}` → cookie `session-id`
3. Use cookies for `/api/.../pages/`, `/api/.../views/`, `/api/.../analytics/`, etc.

Production-grade implementation: `/tmp/cvv_bulk/plane_session.py` (chmod 600 cookie cache, ZERO credential leaks).

### 4. Field name conventions (Friction 4 — CRITICAL)

POST a `/issues/` ignora silenziosamente alcuni campi. Convenzione:

| Read | Write | Note |
|------|-------|------|
| `labels` | `label_ids` | POST `labels` IGNORATO → SEMPRE PATCH `label_ids` post-create |
| `assignees` | `assignees` | OK same |
| `module` | `module_ids` | Different — link via `/module-issues/` POST |
| `parent` | `parent` | OK |
| `cycle` | `cycle_id` | Different |

Endpoint pitfalls:
- Work item links: `/issues/<id>/links/` ⚠️ NOT `/issue-links/`
- Comments: `/issues/<id>/comments/` (use `comment_html`)
- Module-issue link: `/modules/<mid>/module-issues/` POST `{"issues": [iid1, iid2]}`

### 5. EE-only features — workaround patterns (CE limit)

**NON disponibili in CE** (404 confermato via REST + MCP):
- Initiatives → workaround: text inline in DOC-HUB CVV-127
- Milestones → workaround: Modules estesi (es. `CV32E40P-MEGA-CV-MEGA-3-METRICS-PARITY`) + cycle
- Custom WI types (BUG/FEATURE/EPIC) → workaround: labels (bug-fix, feature, refactor, debt)
- Work logs (time tracking) → workaround: estimate_point field (1/2/3/5/8 effort points)
- Workspace-level Pages → workaround: project-level Pages (works)

### 6. Discovery checklist — come trovare cosa serve

Pattern operativo per "voglio sapere X su cv32e40p":

| Domanda | Strumento | Path |
|---------|-----------|------|
| "Quanti WI aperti high prio?" | Plane View | "Critical Open" view |
| "Status modulo Y?" | Plane View | "Y focus" cluster view |
| "Architettura del core?" | Plane Page | "CV32E40P Architecture" |
| "Bug noti per categoria?" | Plane Page | "Bug Catalog" |
| "Build+test workflow?" | Plane Page | "Build Flow" |
| "Roadmap + history?" | Plane Page | "Roadmap & History" |
| "Plane API map / endpoints?" | Plane Page | "Plane API Map" |
| "Live distribution analytics?" | Plane Page | "Live Dashboard" |
| "Cluster deep-dive?" | Plane Page | "Cluster: <X>" (6 pages) |
| "Specific bug detail?" | MCP `search_bugs` (L1) → memory file | `~/.claude/projects/.../memory/project_gvsoc_bugs.md` |
| "CSR detail?" | MCP `get_csr` (L1) | KB strutturata |
| "Trace divergence pattern?" | MCP `match_divergence` (L1) | KB |

### 7. Bulk operation discipline (when modifying Plane in bulk)

#### Pre-bulk gate
- [ ] Token files chmod 600 verified
- [ ] Project + workspace UUIDs confirmed
- [ ] State + label + module UUIDs collected
- [ ] Schema verified for write fields (`_ids` vs `_`)
- [ ] Audit JSONL pre-created in `/tmp/cvv_bulk/<phase>_<task>.jsonl`

#### During bulk
- [ ] Retry exponential backoff on 429 (max 5 attempts, base 5s, cap 60s)
- [ ] Sleep 0.4s between calls
- [ ] Cooldown 60s between cluster batches
- [ ] Audit log per operation

#### Post-bulk
- [ ] Verify count via `mcp__plane__list_*` matches expected
- [ ] Cross-ref bidirezionale memory ↔ Plane
- [ ] DOC-HUB CVV-127 comment con summary
- [ ] viola inbox heads-up se nuove friction

### 8. Drift detection + reconciliation

Memory PRIMARY vince in caso di conflitto. Cadenza:
- **Pre-Done transition WI**: aggiornare session_state.md PRIMA di Plane state Done
- **Post-bulk operation**: verify count + sample WI sanity check
- **Settimanale** (when active): bianco audit (`/plane-health-audit` skill se attivo)

### 9. Anti-pattern (NON fare)

- ❌ Aggiornare Plane e dimenticare memory (drift inverso)
- ❌ Creare WI per ogni micro-fix (use comments invece)
- ❌ Modificare WI in moduli altrui senza cross-ref
- ❌ Bypass field convention (`labels` invece di `label_ids` su POST)
- ❌ Hard-code token plaintext negli script (sempre file references)
- ❌ Echo'are/print'are token in stdout (slip per `credential-handling-discipline.md`)
- ❌ Tentare features EE in CE senza prima verificare `/api/instances/`

## Why

cv32e40p ha 127+ WI in Plane post-Phase-1-11 retro-restructure. Senza disciplina condivisa:
- Drift memory ↔ Plane (Marco vede status stale → false confidence)
- Bulk script duplicate bug (label_ids field name reinventato)
- Auth schema confusion (X-API-Key vs session-cookie)
- EE feature time waste (provare Initiatives/Milestones in CE)

Codifica esperienza Phase 1-11 (BREAKTHROUGH session-auth, friction 4 label_ids, EE-only confirmed) per future cross-project (axi/cva6 quando attivano Plane).

## How to apply

### Scope MANDATORY

- TUTTI i tooling cvv che scrive su Plane (bulk_*.py, MCP plane_*, manual REST)
- TUTTE le Pages/Views nuove
- TUTTI i WI nuovi (prefix MEGA + ownership)

### Scope informativo

- Lettura Plane (Pages, Views, WI list) — niente strict requirement, ma raccomandato use Views salvati invece di filter ad-hoc

### Cross-ref

- Rule sister L1: `~/.claude/rules/agent-hq/plane-sync.md` (cross-team Plane discipline)
- Rule sister L1: `~/.claude/rules/agent-hq/messaging-standard.md` (4-blocchi WI description)
- Memory: `~/.claude/projects/-data-marco-paci-projects-core-v-verif/memory/lessons_learned_plane_industrial_20260505.md`
- Plane Page: "Plane API Map" (uuid `5af25f7d-59c6-4bdf-83a0-e7a9aa2f34cd`)
- Plane Page: "Live Dashboard" (uuid `6aed9314-89c7-4e0b-9ce4-d22698018ac0`)
- Tooling canonical: `/tmp/cvv_bulk/plane_session.py` + `bulk_create_pages.py` + `bulk_create_views.py` + `bulk_create_cluster_pages.py`
- DOC-HUB Master: CVV-127 (uuid `31b8626f-4a97-4be6-9a4e-397e13508d21`)

## Source

- Phase 1-9 retro-restructure 2026-05-05 (Marco directives ~16:25 / ~17:53 / ~18:38 / ~19:00 / ~20:30 CEST)
- Phase 10 industrial chiusura (Marco TG ~22:30 + ~22:50)
- Phase 11 maximum quality push (Marco TG ~23:10 "tutti i poteri / livello massimo / organizza in regole")
- 9 friction points consolidati (vedi lessons_learned_plane_industrial_20260505.md)
- Edition verified: `PLANE_COMMUNITY` via `/api/instances/`

## Change log

- 2026-05-05 — nuova rule L3 cv32e40p (Phase 11.E). Codifica auth dual-tier + ownership prefix + field conventions + EE-only workarounds + bulk discipline + discovery checklist + anti-pattern. Promotion candidate L1 al primo cross-project adoption (axi/cva6 attivano Plane).
