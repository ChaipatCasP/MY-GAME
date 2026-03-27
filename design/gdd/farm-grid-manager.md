# Farm Grid Manager

> **Status**: Approved
> **Author**: game-designer + gameplay-programmer
> **Last Updated**: 2026-04-03
> **Implements Pillar**: Every Day Has Purpose

---

## Overview

The Farm Grid Manager owns the 6×8 grid of CropTile nodes. It creates tiles,
positions them on screen, routes daily growth ticks from the Day Cycle, and
bubbles harvest events up to the Inventory system. It does not own crop data
(that lives in Crop & Seed Database) and it does not advance the day (that is
DayManager's job). It is purely a spatial container and event router.

---

## Player Fantasy

The grid should feel like a garden — a space the player tends with care. The
6×8 size is chosen to be large enough to feel meaningful but small enough that
every tile is accessible by thumb on a 390-wide screen without pinching or
scrolling. The grid is permanent — it does not grow or shrink in MVP.

---

## Detailed Design

### Grid Dimensions

- **Columns**: 6
- **Rows**: 8
- **Total tiles**: 48
- **Tile size**: 56×56 px (minimum 44pt touch target — Apple HIG)
- **Tile gap**: 4 px between tiles
- **Total grid width**: 6 × (56+4) − 4 = 356 px (fits in 390 viewport with 17px margin each side)
- **Total grid height**: 8 × (56+4) − 4 = 476 px

The grid is centered horizontally at x = (390 − 356) / 2 = 17 px.
The grid is positioned vertically to leave ~180 px for the HUD below and ~100 px above.

### Tile Coordinate System

Tiles are addressed by `(col, row)` where:
- `col` ∈ [0, 5] — left to right
- `row` ∈ [0, 7] — top to bottom
- Tile at `(col, row)` has position `origin + Vector2(col × (TILE_SIZE+GAP), row × (TILE_SIZE+GAP))`

Tile identity is encoded as `"col_row"` string (e.g., `"2_3"`) for save/load keys.

### Grid Lifecycle

1. **Spawn** (`_ready`): FarmGrid creates 48 CropTile nodes, assigns `col`/`row`, positions them, and calls `add_child`.
2. **Day Tick**: When `DayManager.day_advanced` fires, FarmGrid calls `tile.advance_day()` on each tile.
3. **Harvest Event**: Each `CropTile` emits `harvested(tile)` when the player taps a harvestable tile. FarmGrid listens and emits `crop_harvested(crop_id, amount)` — this is picked up by Inventory.
4. **Serialize / Deserialize**: Before save, FarmGrid writes all tile states to `GameState.farm_tiles`. On load, FarmGrid restores from that dict.

### Touch Delegation

The FarmGrid does not handle input directly. Each `CropTile` handles its own
`_input` and determines if the tap is within its own rect. FarmGrid only
provides the grid infrastructure.

---

## Formulas

### Grid Centering

```
total_w = COLS * (TILE_SIZE + TILE_GAP) - TILE_GAP   // 356.0
total_h = ROWS * (TILE_SIZE + TILE_GAP) - TILE_GAP   // 476.0
origin.x = (390.0 - total_w) / 2.0                   // 17.0
origin.y = HUD_TOP_HEIGHT + TOP_PADDING               // configurable; default 120.0
```

### Tile Index

```
tile_index = row * COLS + col
```

All tiles are stored in a flat `Array[CropTile]` in row-major order.

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Two simultaneous taps on adjacent tiles | Each tile handles its own input independently; both fire | Mobile multi-touch is valid |
| `advance_day()` called before any tiles are seeded | All tiles skip growth tick silently | No-op is correct |
| Grid is constructed before `GameState.farm_tiles` is populated | Tiles start EMPTY; `deserialize()` is called after grid is ready | Boot scene coordinates the ordering |
| Player rotates device | Grid re-centers to new viewport (if orientation is ever enabled) | Not applicable — portrait locked |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Crop & Seed Database | Grid depends on | CropTile reads `CropDatabase` when a seed is planted |
| In-Game Day Cycle | Grid depends on | Listens to `DayManager.day_advanced` to tick all tiles |
| Tile Farming System | Farming depends on Grid | Tile Farming is conceptually the player-facing view of tile interaction |
| Inventory | Grid → Inventory | FarmGrid emits harvest events; Inventory listens |
| Save / Load System | Grid depends on | Serialize/deserialize farm tile state |
| GameState | Grid depends on | Reads/writes `GameState.farm_tiles` |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect |
|-----------|--------------|------------|--------|
| COLS | 6 | 4–8 | Fewer cols = simpler, less crop variety |
| ROWS | 8 | 6–10 | Fewer rows = less total planting capacity |
| TILE_SIZE | 56 px | 52–64 px | Smaller reduces margin; larger reduces row count |
| TILE_GAP | 4 px | 2–8 px | Visual breathing room between tiles |
| origin.y offset | 120.0 | 80–160 | Lower = more HUD space above |

---

## Acceptance Criteria

- [ ] Grid always displays exactly 48 tiles (6×8)
- [ ] All tiles are tap-reachable by thumb in 390px viewport (no tile narrower than 44px touch target)
- [ ] Grid is horizontally centered on screen
- [ ] `advance_day()` fires for every tile on every day advance
- [ ] Harvest events from tiles reach `FarmGrid.crop_harvested` signal
- [ ] Serialization round-trip: `serialize()` followed by `deserialize()` restores all tile states
- [ ] No tile coordinate collisions (each tile has unique col/row)

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Should tile gap increase slightly on larger screens (iPads)? | Tech Director | Tablet not in MVP scope — ignore for now |
