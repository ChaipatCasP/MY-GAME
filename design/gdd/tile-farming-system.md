# Tile Farming System

> **Status**: Approved
> **Author**: game-designer + ux-designer
> **Last Updated**: 2026-04-03
> **Implements Pillar**: Every Day Has Purpose · Cozy Always Wins

---

## Overview

The Tile Farming System is the player's primary interaction surface. It defines
everything the player can do by tapping a tile: plant a seed, water a crop, and
harvest a mature crop. It sits on top of the Farm Grid Manager (which owns
tile state) and writes to Inventory (which owns crop counts). The system has
exactly three verbs: **Plant, Water, Harvest**. Nothing else.

---

## Player Fantasy

Tapping tiles should feel as satisfying as cracking knuckles. The feedback
should be immediate and rewarding — a small pop of color, a brief animation,
a soft audio cue. The verbs are intentionally simple so the player never has
to think about what to do — they just tend the garden.

---

## Detailed Design

### The Three Verbs

#### Verb 1: PLANT

**Trigger**: Tap on an EMPTY tile when a seed is selected

**Preconditions**:
- Tile state is `EMPTY`
- A valid seed is selected in the Seed Selection Bar
- `inventory_count(selected_seed) > 0`

**Effects in order**:
1. `GameState.remove_from_inventory(selected_seed, 1)`
2. Tile state → `SEEDED`
3. Tile stores `crop_id`, `crop_yield`, `crop_base_grow_days`, `season_affinity`
4. Visual: soil darkens slightly; a small seed icon appears
5. Audio: `plant.ogg` SFX

**Blocked if**: No seed selected, or inventory empty for that seed.
Visual feedback: tile jiggles gently ("nothing to plant here").

---

#### Verb 2: WATER

**Trigger**: Tap on a SEEDED or GROWING tile

**Preconditions**:
- Tile state is `SEEDED` or `GROWING`
- `tile.is_watered_today == false` (watering twice does nothing)

**Effects in order**:
1. `tile.is_watered_today = true`
2. If `SEEDED`: tile state → `GROWING`
3. Visual: water droplet animation plays over tile; tile color brightens
4. Audio: `water.ogg` SFX

**Already-watered tile**: Tap is accepted but has no effect; no SFX plays.
A subtle visual (water ripple, already-present) confirms it was watered earlier.

---

#### Verb 3: HARVEST

**Trigger**: Tap on a HARVESTABLE tile

**Preconditions**:
- Tile state is `HARVESTABLE`

**Effects in order**:
1. `GameState.add_to_inventory(crop_id, crop_yield)`
2. Tile state → `EMPTY`
3. Visual: crop pops up with a quick scale bounce, then disappears
4. Audio: `harvest.ogg` SFX
5. HUD harvest counter increments

**No precondition failures** — any tap on a HARVESTABLE tile always harvests.

---

### Seed Selection Bar

A persistent bar above the grid showing the player's known seeds as tappable
buttons. The currently selected seed is highlighted. Tapping a seed button
selects it. Tapping again deselects (no seed selected = tapping EMPTY tiles
has no effect).

- Max visible: all known seeds (up to 8 in MVP)
- Layout: horizontal scroll if seeds exceed viewport width (max 8 in MVP = no scroll needed)

This component is owned by the Tile Farming System but rendered by the Farm HUD.

---

### Tap State Machine

```
Tile state:  EMPTY    → SEEDED   (Plant verb, requires selected seed)
             SEEDED   → GROWING  (Water verb)
             GROWING  → GROWING  (Water each day moves growth counter via DayManager)
             GROWING  → HARVESTABLE (when days_grown >= effective_grow_days)
             HARVESTABLE → EMPTY (Harvest verb)
```

Transitions not listed above are ignored (no error, no effect).

---

### Touch Area

Each tile's touch area is its full 56×56 px ColorRect. No invisible margins.
This meets the 44pt minimum touch target on all supported screen densities.

---

## Formulas

See Crop & Seed Database GDD for `effective_grow_days` formula.

### "Already watered" indicator

```
is_watered_today == true  →  show blue tint or droplet icon on tile
is_watered_today == false →  no indicator (default state)
```

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Tap EMPTY with no seed selected | Gentle jiggle animation, no state change | Tactile feedback without error text |
| Tap EMPTY when selected seed has 0 in inventory | Same jiggle; Seed Selection Bar automatically deselects that seed | Keeps UI honest |
| Tap GROWING tile a second time same day | Water animation plays but `is_watered_today` already true; no state change | Idempotent — feels forgiving |
| Tap HARVESTABLE when inventory is very full | Harvests anyway; no crop cap on delivery-ready crops | Cozy Always Wins |
| Very fast repeated taps on same tile | State transitions only process one tap per frame; extra taps ignored via `set_input_as_handled()` | No double-harvest possible |
| All 48 tiles are HARVESTABLE | Player can harvest all in sequence; no performance issue | 48 ColorRects is trivial |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Farm Grid Manager | Farming depends on Grid | All tile state lives in CropTile nodes managed by FarmGrid |
| Inventory / Crop Storage | Farming → Inventory | Plant removes seeds; Harvest adds crops |
| Crop & Seed Database | Farming depends on DB | Reads crop data on plant |
| In-Game Day Cycle | Indirect | GROWING → HARVESTABLE transition happens during `advance_day()` |
| Farm HUD | HUD depends on Farming | Seed Selection Bar is a HUD component showing known seeds |
| Spirit Quest System | Quest depends on Farming | Quest progress checks inventory after each harvest |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect |
|-----------|--------------|------------|--------|
| Tile size | 56 px | 52–64 px | Smaller = more tiles visible; larger = easier to tap |
| Harvest animation duration | 200ms | 100–400ms | Faster = snappier; slower = more satisfying |
| Water animation duration | 300ms | 150–500ms | Same |
| Jiggle animation (empty tap) | 150ms | 100–250ms | Should feel light, not punishing |

---

## Acceptance Criteria

- [ ] Tapping an EMPTY tile with a valid seed selected plants the crop and removes 1 seed from inventory
- [ ] Tapping an EMPTY tile with no seed selected plays jiggle animation; no state change
- [ ] Tapping a SEEDED tile sets `is_watered_today = true` and transitions to GROWING
- [ ] Tapping a GROWING tile that was already watered today plays water animation but state is unchanged
- [ ] Tapping a HARVESTABLE tile adds `crop_yield` crops to inventory and resets tile to EMPTY
- [ ] All three verbs play their respective SFX
- [ ] Seed Selection Bar shows all known seeds; tapping one selects it
- [ ] Double-tapping a HARVESTABLE tile only harvests once

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Should there be a visual distinction between SEEDED and GROWING on the same day? | Art Director | Yes — SEEDED shows a tiny seed sprite; GROWING shows a sprout. Placeholder: SEEDED = lighter brown, GROWING = green |
| Is the Seed Selection Bar scrollable at 8+ seeds? | UX Designer | Horizontal scroll, but 8 seeds exactly fits 390px at ~46px per button — no scroll needed in MVP |
