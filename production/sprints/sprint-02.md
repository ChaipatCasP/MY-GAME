# Sprint 2 — 2026-04-03 to 2026-04-10

## Sprint Goal

Design all 4 remaining Core/Feature-layer GDDs and implement the Spirit Quest
System so the complete plant → harvest → deliver loop can be played end-to-end.

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days reserved
- Available: ~5.5 focused days

---

## Tasks

### Must Have (Critical Path)

| ID | Task | Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------|-----------|-------------|---------------------|
| S2-01 | Design GDD: Farm Grid Manager | Developer | 0.75 | crop-seed-database.md, day-cycle.md | `design/gdd/farm-grid-manager.md` written; tile states, touch area, growth tick contract documented |
| S2-02 | Design GDD: Inventory / Crop Storage | Developer | 0.5 | crop-seed-database.md | `design/gdd/inventory.md` written; seed cap (48), add/remove API, display contract |
| S2-03 | Design GDD: Tile Farming System | Developer | 0.75 | farm-grid-manager.md, inventory.md | `design/gdd/tile-farming-system.md` written; tap flow, seed selection, harvest visual |
| S2-04 | Design GDD: Spirit Quest System | Developer | 0.75 | spirit-island-data.md, inventory.md | `design/gdd/spirit-quest-system.md` written; delivery flow, substitution rule, reward grant |
| S2-05 | Implement SpiritQuestSystem.gd | Developer | 1.0 | S2-04, GameState.gd, islands.json | SpiritQuestSystem autoload; reads island quest; tracks delivery; emits quest_completed signal |
| S2-06 | Implement QuestTrackerUI | Developer | 0.75 | S2-05 | QuestTrackerUI scene displays required crops and current inventory count; updates live |

### Should Have

| ID | Task | Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------|-----------|-------------|---------------------|
| S2-07 | Update FarmScene to wire SpiritQuestSystem | Developer | 0.25 | S2-05, S2-06 | Delivering crops via UI triggers quest progress |
| S2-08 | Design GDD: Save / Load System (skeleton) | Developer | 0.5 | All MVP system GDDs | `design/gdd/save-load.md` skeleton written — context + rules sections |

---

## Carryover from Sprint 1

| ID | Task | Note |
|----|------|------|
| S1-01 | Prototype device test | Blocked on Godot install — carry to Sprint 3 |
| S1-07 | Farm Grid Manager GDD (skeleton) | Rolled into S2-01 |

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Spirit Quest substitution logic is complex | Low | Medium | Substitution is documented in GDD; keep it to a single rule (amber_wheat = 2 wheat) |
| Quest Tracker UI requires polish time | Medium | Low | Plain Labels only in Sprint 2 — no art, no animation |
