# Systems Index: Drifting Seasons

> **Status**: Draft
> **Created**: 2026-03-27
> **Last Updated**: 2026-03-27
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Drifting Seasons is a cozy mobile farming sim with a tight, focused mechanical
scope. The core loop — plant crops, tend daily, fulfill a spirit harvest quest,
drift to a new island — requires approximately 15 systems total, organized
around 4 pillars: farming grid management, quest delivery, island travel, and
mobile save reliability. The game is intentionally non-combat, non-multiplayer,
and non-procedural to keep scope achievable for a solo developer in 3–4 months.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | Crop & Seed Database | Core | MVP | Not Started | — | — |
| 2 | Spirit & Island Data | Core | MVP | Not Started | — | — |
| 3 | In-Game Day Cycle | Core | MVP | Not Started | — | — |
| 4 | Farm Grid Manager | Core | MVP | Not Started | — | Crop & Seed Database, In-Game Day Cycle |
| 5 | Inventory / Crop Storage | Gameplay | MVP | Not Started | — | Crop & Seed Database |
| 6 | Tile Farming System | Gameplay | MVP | Not Started | — | Farm Grid Manager, Inventory |
| 7 | Spirit Quest System | Gameplay | MVP | Not Started | — | Spirit & Island Data, Tile Farming, Inventory |
| 8 | Save / Load System | Persistence | MVP | Not Started | — | Farm Grid Manager, Inventory, Spirit Quest |
| 9 | Farm HUD | UI | MVP | Not Started | — | Tile Farming, In-Game Day Cycle |
| 10 | Quest Tracker UI | UI | MVP | Not Started | — | Spirit Quest System |
| 11 | Drift / Travel System | Gameplay | Vertical Slice | Not Started | — | Spirit Quest System, Spirit & Island Data |
| 12 | Island Transition Cinematic | UI | Vertical Slice | Not Started | — | Drift / Travel System |
| 13 | Seed Discovery System | Gameplay | Vertical Slice | Not Started | — | Crop & Seed Database, Spirit & Island Data |
| 14 | Soft Consequence System | Gameplay | Alpha | Not Started | — | Spirit Quest System, Drift / Travel System |
| 15 | Main Menu / Settings | UI | Alpha | Not Started | — | Save / Load System |

---

## Categories

| Category | Description | Systems in This Game |
|----------|-------------|----------------------|
| **Core** | Foundation systems everything else depends on | Crop DB, Island Data, Day Cycle, Farm Grid |
| **Gameplay** | Systems that make the game fun | Tile Farming, Quest System, Drift, Seed Discovery, Soft Consequence |
| **Persistence** | Save state and continuity | Save / Load |
| **UI** | Player-facing displays | Farm HUD, Quest Tracker UI, Transition Cinematic, Main Menu |

---

## Priority Tiers

| Tier | Definition | Target Milestone |
|------|------------|------------------|
| **MVP** | Core loop functional: plant → tend → harvest → deliver | Week 4 prototype |
| **Vertical Slice** | One complete journey (2 islands, drift between them) | Week 8 |
| **Alpha** | All 4 islands, all systems rough | Week 14 |
| **Full Vision** | Polished, NG+, full story | Week 18–20 |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. **Crop & Seed Database** — all crop types, grow times, yields, seed sources; no system depends on anything before this
2. **Spirit & Island Data** — island definitions, spirit quests, available seeds per island; pure data, no runtime deps
3. **In-Game Day Cycle** — a simple in-game clock/counter; nothing else needs to exist first

### Core Layer (depends on Foundation)

4. **Farm Grid Manager** — manages tile state (empty, seeded, growing, harvestable); depends on Crop DB for grow-time data and Day Cycle to advance growth
5. **Inventory / Crop Storage** — tracks what the player has harvested; depends on Crop DB for item definitions

### Feature Layer (depends on Core)

6. **Tile Farming System** — the player-facing tap-to-interact loop; depends on Farm Grid Manager (tile state) and Inventory (to store harvested crops)
7. **Spirit Quest System** — reads island quest from Spirit & Island Data, checks Inventory for required crops, triggers delivery ceremony
8. **Save / Load System** — serializes Farm Grid state, Inventory, Day, and Quest progress; depends on all three above

### Presentation Layer (depends on Features)

9. **Farm HUD** — shows crop growth stages, day counter, energy (none here — just info); depends on Tile Farming + Day Cycle
10. **Quest Tracker UI** — shows spirit quest requirements and current stock; depends on Spirit Quest System
11. **Drift / Travel System** (VS) — triggers island transition when quest complete or player chooses; depends on Spirit Quest + Island Data
12. **Island Transition Cinematic** (VS) — animated drift sequence; depends on Drift/Travel System
13. **Seed Discovery System** (VS) — unlocks new seeds found on each island; depends on Crop DB + Island Data
14. **Soft Consequence System** (Alpha) — applies weather modifier on incomplete quests before drift; depends on Quest + Drift
15. **Main Menu / Settings** (Alpha) — new game, load, audio settings; depends on Save/Load

### Polish Layer

— No polish-only systems scoped for this project —

---

## Circular Dependencies

**None found.** The dependency graph is clean and acyclic. Key reason: the UI
systems are designed as pure read-only display layers on top of gameplay
systems, with no bidirectional coupling.

---

## Recommended Design Order

Design these systems in order. Each GDD should be completed before starting the
next (except same-layer systems which can be designed in parallel).

| Order | System | Priority | Layer | Recommended Agent | Est. Effort |
|-------|--------|----------|-------|-------------------|-------------|
| 1 | Crop & Seed Database | MVP | Foundation | game-designer + systems-designer | S |
| 2 | Spirit & Island Data | MVP | Foundation | game-designer + narrative-director | S |
| 3 | In-Game Day Cycle | MVP | Foundation | game-designer | S |
| 4 | Farm Grid Manager | MVP | Core | game-designer + gameplay-programmer | M |
| 5 | Inventory / Crop Storage | MVP | Core | game-designer | S |
| 6 | Tile Farming System | MVP | Feature | game-designer + ux-designer | M |
| 7 | Spirit Quest System | MVP | Feature | game-designer + systems-designer | M |
| 8 | Save / Load System | MVP | Feature | lead-programmer | S |
| 9 | Farm HUD | MVP | Presentation | ux-designer + ui-programmer | M |
| 10 | Quest Tracker UI | MVP | Presentation | ux-designer + ui-programmer | S |
| 11 | Drift / Travel System | Vertical Slice | Feature | game-designer + technical-artist | M |
| 12 | Island Transition Cinematic | Vertical Slice | Presentation | technical-artist | S |
| 13 | Seed Discovery System | Vertical Slice | Feature | game-designer | S |
| 14 | Soft Consequence System | Alpha | Feature | game-designer | S |
| 15 | Main Menu / Settings | Alpha | Presentation | ux-designer + ui-programmer | S |

*Effort: S = 1 session, M = 2–3 sessions. Design 1–3 in parallel (all Foundation, no deps).*

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| **Tile Farming System** | Technical | Touch input on mobile tile grid must feel satisfying and not frustrating — unproven until tested on a device | Prototype touch controls in Week 1 before designing full system GDD |
| **Save / Load System** | Technical | Mobile OS can background/kill the app mid-session, causing save loss | Auto-save on every significant action; prototype save pattern in Week 2 |
| **Drift / Travel System** | Design | The island transition must feel like "wonder", not a loading screen — design risk | Test a simple Godot tween animation early; fail fast on aesthetic |
| **Farm Grid Manager** | Scope | Grid size and tile count affects all downstream systems (UI layout, touch targets, crop balance) | Lock grid size (6×8) early and treat it as a constraint, not a variable |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 15 |
| Design docs started | 0 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 0 / 10 |
| Vertical Slice systems designed | 0 / 3 |

---

## Next Steps

- [ ] Design MVP Foundation systems first (can be done in parallel):
  - `/design-system crop-and-seed-database`
  - `/design-system spirit-and-island-data`
  - `/design-system day-cycle`
- [ ] Prototype touch tile interaction early to validate risk: `/prototype tile-farming-touch`
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check pre-production` when all MVP systems are designed
