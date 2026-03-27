# Sprint 1 — 2026-03-27 to 2026-04-03

## Sprint Goal

Validate that touch tile controls are satisfying on mobile, and lay the
design foundation (3 data-layer system GDDs) so implementation can begin in Sprint 2.

## Capacity

- Total days: 7
- Buffer (20%): 1.4 days reserved for unplanned issues
- Available: ~5.5 focused days

---

## Tasks

### Must Have (Critical Path)

| ID | Task | Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------|-----------|-------------|---------------------|
| S1-01 | Run tile-farming-touch prototype on device / Godot mobile sim | Developer | 0.5 | Prototype code (done) | REPORT.md filled with real observations; tap accuracy assessed |
| S1-02 | Design GDD: Crop & Seed Database | Developer + game-designer agent | 1.0 | game-concept.md, systems-index.md | GDD written to `design/gdd/crop-seed-database.md`; covers all crop types, grow times, yields |
| S1-03 | Design GDD: Spirit & Island Data | Developer + narrative-director agent | 1.0 | game-concept.md | GDD written to `design/gdd/spirit-island-data.md`; covers 4 spirits, 1 island per spirit, quest structure |
| S1-04 | Design GDD: In-Game Day Cycle | Developer + game-designer agent | 0.5 | game-concept.md | GDD written to `design/gdd/day-cycle.md`; specifies day advancement, crop growth ticks, session flow |

### Should Have

| ID | Task | Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------|-----------|-------------|---------------------|
| S1-05 | Set up Godot project structure for production | Developer | 0.5 | — | `src/`, `assets/`, `design/` folders created; `.gitignore` configured |
| S1-06 | Create git repo and first commit | Developer | 0.25 | S1-05 | `git init`, initial commit with project skeleton |

### Nice to Have

| ID | Task | Owner | Est. Days | Dependencies | Acceptance Criteria |
|----|------|-------|-----------|-------------|---------------------|
| S1-07 | Design GDD: Farm Grid Manager (start only) | Developer | 0.5 | S1-02, S1-04 | File skeleton created, context section filled |

---

## Carryover from Previous Sprint

None — this is Sprint 1.

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Prototype touch controls feel bad | Medium | High | S1-01 is first task; if result is PIVOT, adjust grid size before committing to production design |
| GDD writing takes longer than 1 day each | Medium | Medium | Use `/design-system` skill to guide section-by-section; stop at skeleton if over time |

---

## Dependencies on External Factors

- Physical device (iOS/Android) or Godot Android/iOS simulator for S1-01
- Godot 4.6 installed locally

---

## Definition of Done for Sprint 1

- [ ] S1-01: Prototype REPORT.md complete with real device observations
- [ ] S1-02: `design/gdd/crop-seed-database.md` written and reviewed
- [ ] S1-03: `design/gdd/spirit-island-data.md` written and reviewed
- [ ] S1-04: `design/gdd/day-cycle.md` written and reviewed
- [ ] S1-05: Production Godot project scaffold exists
- [ ] No open blockers for Sprint 2

---

## Sprint 2 Preview (next week)

Sprint 2 will implement: Farm Grid Manager, Inventory, and Tile Farming System
as working Godot code — based on the GDDs completed this sprint.
