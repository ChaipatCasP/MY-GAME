# Crop & Seed Database

> **Status**: Approved
> **Author**: game-designer + systems-designer
> **Last Updated**: 2026-03-27
> **Implements Pillar**: Every Day Has Purpose

---

## Overview

The Crop & Seed Database is the data foundation of Drifting Seasons. It defines
every plant in the game: what it looks like across growth stages, how long it
takes to grow, how much yield it produces, and where its seeds can be found.
The player interacts with this system indirectly — by planting seeds and
harvesting results — but every satisfying harvest moment is rooted in the data
defined here.

---

## Player Fantasy

The player should feel like a knowledgeable gardener who understands their crops.
"I know this sunflower takes 3 days. If I plant it now, it'll be ready just as
the Spirit's window opens." The satisfaction comes from planning, not from
randomness.

---

## Detailed Design

### Core Rules

1. Every crop has a unique `crop_id` (string, snake_case, e.g., `"sunflower"`).
2. Every crop belongs to exactly one `season_affinity` — the season whose island
   it grows best on. Crops can grow on other islands but with +1 grow day penalty.
3. Every crop has a fixed `grow_days` value (integer, 1–5). This does NOT change
   at runtime; the Day Cycle ticks crops forward, not the crop itself.
4. Every crop yields exactly `harvest_yield` units when harvested (integer, 1–4).
   Yield does NOT vary randomly — predictability is a cozy pillar design choice.
5. Seeds are obtained in two ways:
   - **Island seeds**: each island offers 2–3 crops for purchase/free collection
   - **Cross-seeds**: combining two crops triggers discovery of a rare seed (see Seed Discovery system)
6. A crop that has not been watered on a given day does NOT die. It simply does
   not advance its growth counter that day. ("Crops do not die.") This is a
   locked anti-pillar rule — do NOT add a "withering" mechanic.

### Crop State Lifecycle

| State | Entry Condition | Exit Condition | Visual |
|-------|----------------|----------------|--------|
| `EMPTY` | Tile has no seed | Player taps tile and has a seed | Brown soil |
| `SEEDED` | Seed planted (day 0) | `days_grown >= 1` | Tiny sprout |
| `GROWING` | `1 <= days_grown < grow_days` | `days_grown == grow_days` AND watered | Mid-size plant |
| `HARVESTABLE` | `days_grown == grow_days` | Player taps tile (harvest) | Full plant, glows |

**Note**: `days_grown` increments only on days when the tile was watered.
Unwatered tiles stay in their current state silently.

### Crop Data Table (Full MVP Set)

| Crop ID | Display Name | Season | Grow Days | Yield | Obtained At |
|---------|-------------|--------|-----------|-------|-------------|
| `sunflower` | サンフラワー / Sunflower | Summer | 2 | 2 | Summer Island (free) |
| `wheat` | 小麦 / Wheat | Autumn | 3 | 3 | Autumn Island (free) |
| `snowdrop` | スノードロップ / Snowdrop | Winter | 4 | 1 | Winter Island (free) |
| `clover` | クローバー / Clover | Spring | 1 | 1 | Spring Island (free, tutorial) |
| `moonbloom` | 月花 / Moonbloom | Summer | 3 | 2 | Summer Island (reward) |
| `amber_wheat` | 琥珀麦 / Amber Wheat | Autumn | 4 | 4 | Cross-seed: wheat + sunflower |
| `frostbell` | 霜鈴 / Frostbell | Winter | 5 | 3 | Cross-seed: snowdrop + clover |
| `spiritgrass` | 精霊草 / Spiritgrass | Spring | 2 | 2 | Cross-seed: clover + moonbloom |

*Full Vertical Slice + Alpha expansions add 12 more crops.*

### Seed Stack Rules

- The player's seed inventory holds up to **48 seeds** total (one per grid tile —
  prevents the player from hoarding unplantable excess).
- Seeds are consumed 1-per-plant. There is no "bulk buy."
- Seeds do NOT expire.

---

## Formulas

### Growth Check Per Day

```
advances = (tile.is_watered_today == true) ? 1 : 0
tile.days_grown += advances
```

| Variable | Type | Range | Source |
|----------|------|-------|--------|
| `tile.is_watered_today` | bool | true/false | Set by player tap action |
| `tile.days_grown` | int | 0 to grow_days | Tracked in FarmGrid tile state |

### Season Affinity Penalty

```
effective_grow_days = crop.grow_days + (current_island.season != crop.season_affinity ? 1 : 0)
```

| Variable | Type | Range | Notes |
|----------|------|-------|-------|
| `crop.grow_days` | int | 1–5 | From crop database |
| `current_island.season` | enum | Spring/Summer/Autumn/Winter | From Island Data |
| `crop.season_affinity` | enum | Spring/Summer/Autumn/Winter | From crop data |

**Expected output range**: 1 (clover on Spring) to 6 (frostbell off-season)

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Player waters an already-watered tile | No effect, no error | Idempotent taps are safe |
| Player harvests a GROWING (not ready) tile | Not allowed — tile does not respond to harvest tap | Prevents accidental early harvest |
| `days_grown` overshoots `grow_days` | Clamped to `grow_days`; state becomes `HARVESTABLE` | Defensive; shouldn't happen but safe |
| Seed inventory full (48) when collecting | New seed is not added; player sees "Seeds Full" toast | Inventory cap is hard |
| Cross-seed crop planted on wrong season | +1 day penalty still applies | Consistent rule, no exceptions |
| Spirit quest requires crop not in inventory | Quest shows unfulfillable; player can still deliver partial amounts | No blocking win — soft consequence only |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Farm Grid Manager | Farm Grid depends on this | Grid tiles reference `crop_id` from this DB; grow times come from here |
| Tile Farming System | Tile Farming depends on this | Actions (plant/water/harvest) operate on crops defined here |
| Inventory / Crop Storage | Inventory depends on this | Items in inventory reference `crop_id` for display names, icons |
| Spirit Quest System | Quest depends on this | Quests specify delivery amounts by `crop_id` |
| Seed Discovery System (VS) | Seed Discovery depends on this | Cross-seed recipes defined here |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect of Increase | Effect of Decrease |
|-----------|--------------|------------|-------------------|-------------------|
| `clover.grow_days` | 1 | 1–2 | Tutorial feels slower | — (already minimum) |
| `wheat.grow_days` | 3 | 2–4 | More planning required | Too fast for Autumn quest tension |
| `frostbell.grow_days` | 5 | 4–6 | Winter island hardest | Reduces late-game challenge |
| Max seed inventory | 48 | 24–48 | More hoarding possible | Forces tighter planning |
| Season affinity penalty | +1 day | 0–2 | More reason to match season | No reason to care about season |

---

## Visual / Audio Requirements

| Event | Visual Feedback | Audio Feedback | Priority |
|-------|----------------|---------------|----------|
| Tile state: SEEDED | Small sprout icon on tile | Soft "plop" SFX | High |
| Tile state: GROWING | Taller plant icon, day counter badge | — | High |
| Tile state: HARVESTABLE | Full plant + golden shimmer particle | Gentle sparkle SFX | High |
| Harvest action | Scale-pop animation + crop flies to inventory | Satisfying "ding" SFX | Critical |
| Season affinity bonus (no penalty) | Subtle bloom around tile | — | Low |

---

## UI Requirements

| Information | Display Location | Update Frequency | Condition |
|-------------|----------------|-----------------|-----------|
| Crop name + grow progress | Tile tooltip on long-press | On demand | When tile is GROWING/HARVESTABLE |
| Days remaining | Badge on tile | On day advance | When tile is GROWING |
| Inventory count per crop | Inventory panel | On harvest / on plant | Always visible |
| Seeds remaining | Seed selector popup | When planting | Open during plant action |

---

## Acceptance Criteria

- [ ] Planting a `clover` seed on Spring Island advances to HARVESTABLE after 1 day advance
- [ ] Planting `sunflower` on Winter Island (off-season) takes 3 days, not 2
- [ ] Harvesting a GROWING tile has no effect (tile stays GROWING)
- [ ] Watring an already-watered tile has no effect and does not error
- [ ] When seed inventory reaches 48, new seeds cannot be added; toast shown
- [ ] All 8 MVP crops exist in the database with correct `grow_days` and `yield`
- [ ] `crop_id` values are unique across all crops
- [ ] No hardcoded crop values in game logic — all fetched from Resource data

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Should watering animation persist to next day visit? | Developer | Assume no — watering resets each day on the Day Cycle tick |
| Do cross-seeds inherit season affinity from parent crops or have their own? | Developer | Own affinity (defined above in table) |
