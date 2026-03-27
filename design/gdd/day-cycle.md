# In-Game Day Cycle

> **Status**: Approved
> **Author**: game-designer + systems-designer
> **Last Updated**: 2026-03-27
> **Implements Pillar**: Every Day Has Purpose · Cozy Always Wins

---

## Overview

The Day Cycle system governs the passage of in-game time. A "day" is a logical
unit — not a real-time clock. The player advances the day manually by tapping
the **"Next Day"** button. When the day advances, all farmtiles process their
growth tick. The day counter increments, and the HUD updates. There is no
energy, no time pressure, no penalty for not playing. The game waits patiently
for the player.

---

## Player Fantasy

The player should feel in complete control of the day's pace. They tend their
crops, reflect on what to plant next, maybe deliver some harvests to the spirit,
and then — when they're ready — tap "Next Day" and watch the world quietly tick
forward. It should feel like turning a page, not pressing an alarm clock.

---

## Detailed Design

### Day Counter

- The day counter is a global integer, starting at **Day 1**.
- The counter is displayed persistently in the Farm HUD.
- There is no maximum day — the counter increases indefinitely.
- Day 1 is always the first day on Spring Island.

### Advancing the Day

**Trigger**: Player taps the "Next Day" button.

On **"Next Day"** tap, the following happen **in order**:

1. **Growth Tick** — Farm Grid Manager calls `advance_day()` on every `CropTile`
2. **Water Reset** — Every `CropTile.is_watered_today` resets to `false`
3. **Day Counter Increment** — `current_day += 1`
4. **HUD Refresh** — Farm HUD reads new `current_day` and refreshes display
5. **Quest Check** — Spirit Quest System checks if pending quest is now fulfillable
6. **Save** — Save/Load System auto-saves state _(optional, see Edge Cases)_

There is no automatic time passing. Nothing happens until the player taps.

### Watering Rules

- A tile can be watered **once per day**. Watering again before next day is a no-op.
- Watering advances the tile toward harvest only if done **within the same day**.
  - i.e., watering on Day 5 counts for Day 5's growth tick when "Next Day" fires.
- Example: If growth takes 3 days, player must water on Day N, Day N+1, Day N+2
  before tapping "Next Day" on the morning of those days. The tile is harvestable
  on Day N+3.

### Session Flow

A typical mobile session looks like:
```
Open app
→ Farm is in same state they left it (auto-saved)
→ Water tiles
→ Harvest if ready
→ Deliver to spirit if quest in progress
→ Optionally plant new seeds
→ Tap "Next Day"
→ (Repeat or close app)
```

There is no incentive to play for long sessions. The "Next Day" button works
whether the player has done 1 action or 20 actions that day.
Player can tap "Next Day" immediately if they want to skip a day.

### Day Display Format

- HUD shows: `"Day 12"` — simple, no season labels at this layer.
- Season label ("Spring", "Summer", etc.) is determined by the active island,
  not by the day count, and is displayed separately in the Island HUD area.

---

## Formulas

### Growth Tick (executed for each CropTile)

```
if tile.state == GROWING:
    if tile.is_watered_today:
        tile.days_grown += 1
    if tile.days_grown >= tile.crop.effective_grow_days:
        tile.state = HARVESTABLE
```

`effective_grow_days` is defined in the Crop & Seed Database:
```
effective_grow_days = crop.base_grow_days
    + (current_island.season != crop.season_affinity ? 1 : 0)
```

### Day Counter

```
fn advance_day():
    _tick_all_crops()
    _reset_water_flags()
    current_day += 1
    emit_signal("day_advanced", current_day)
```

`day_advanced` signal is the single broadcast mechanism. All other systems
(HUD, Quest, Save) listen to this signal. Day Cycle does not call them directly.

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Player taps "Next Day" with no seeds planted | Day advances, nothing else changes | No penalty for idle days |
| Player taps "Next Day" without watering any tiles | Growth ticks fire but no tile increments (`is_watered_today == false`) | Skipping is valid |
| Player waters a tile, then taps "Next Day" twice quickly | Only one growth tick fires — debounce the button for 300ms after advance completes | Prevents accidental double-advance |
| Player closes the app while "Next Day" animation is playing | State was saved before animation; reopening loads correctly | Save happens synchronously before visual feedback |
| Day count overflows int32 (day ~2 billion) | Handled by GDScript's arbitrary int size — no overflow | Not a real risk in a farming game |
| Spirit Quest System is not yet loaded at day advance | Day Cycle emits signal regardless; Quest System connects when ready | Decoupled via signals |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Farm Grid Manager | Day Cycle → Grid | `advance_day()` call triggers all tile growth ticks |
| Crop & Seed Database | Indirect | `effective_grow_days` formula reads crop data |
| Spirit & Island Data | Indirect | Season affinity reads `current_island.season` |
| Spirit Quest System | Listens to `day_advanced` | May update quest state after each day |
| Farm HUD | Listens to `day_advanced` | Refreshes day counter display |
| Save / Load System | Listens to `day_advanced` | Auto-save after each day advance |
| Tile Farming System | Contains CropTile | Day Cycle drives tick; CropTile executes it |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect of Increase | Effect of Decrease |
|-----------|--------------|------------|-------------------|-------------------|
| Button debounce duration | 300ms | 150–500ms | Prevents double-tap accident | May feel sluggish |
| Auto-save: save on every day advance? | Yes | N/A (boolean) | More data integrity | Save-point-only approach |
| Day counter starting value | 1 | Always 1 | — | — |

---

## Signal Contract

The Day Cycle System **owns** one signal:

```gdscript
signal day_advanced(new_day: int)
```

All downstream systems connect to this signal. Day Cycle does not reference
downstream systems directly (no tight coupling).

---

## Acceptance Criteria

- [ ] Tapping "Next Day" increments `current_day` by exactly 1
- [ ] All watered tiles grow by 1 day on advance
- [ ] All unwired tiles are unaffected on advance
- [ ] `is_watered_today` is reset to `false` on every tile after advance
- [ ] `day_advanced` signal fires after every advance with correct `new_day` value
- [ ] HUD displays correct day number immediately after advance
- [ ] Double-tapping "Next Day" within 300ms triggers only one advance
- [ ] Closing app mid-animation and reopening loads correct state
- [ ] Day advances with zero planted seeds without error

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Should there be a visible "day ending" animation (screen dimming, stars, etc.)? | Art Director | Yes — brief screen-dim tween (~500ms) before HUD refreshes. Adds to page-turning feel. |
| Should the player be able to undo a "Next Day" tap within a grace window? | Lead Designer | No — adds complexity and undermines predictability |
