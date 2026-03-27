# Inventory / Crop Storage

> **Status**: Approved
> **Author**: game-designer + systems-designer
> **Last Updated**: 2026-04-03
> **Implements Pillar**: Every Day Has Purpose · Cozy Always Wins

---

## Overview

The Inventory system tracks what crops and seeds the player currently holds.
It is a simple key-value store (`crop_id → count`) that lives in `GameState`.
No weight system, no expiry, no rarity tiers — just "how many of each crop
do you have." The only constraint is a **combined seed cap of 48** to prevent
infinite stockpiling and keep the delivery loop meaningful.

---

## Player Fantasy

The player should feel like they have a cozy basket full of things they grew.
Looking at the inventory should feel satisfying, not stressful. There is no
"your crops are about to expire" pressure — harvested crops wait patiently
until delivered.

---

## Detailed Design

### Structure

The inventory is stored in `GameState.inventory: Dictionary` where:
- **Key**: `crop_id` (String matching an entry in `crops.json`)
- **Value**: non-negative integer count

Empty entries are pruned (when count reaches 0, the key is removed) to keep
the dictionary small and predictable.

### Seed Cap

- **Combined seed cap**: 48 total seeds across all crop types
- If `total_seeds_held() >= 48`, the player cannot pick up new seeds from the island
- Harvested crops do **not** count toward the seed cap — they are awaiting delivery
- Seeds used to plant tiles are removed from inventory immediately (before growth starts)

```
total_seeds = sum(inventory[id] for id in known_seeds if id in inventory)
```

### Harvested Crops

Harvested crops are stored in the same `GameState.inventory` dict as seeds.
Distinction: `GameState.known_seeds` is the list of things the player can plant;
items not in `known_seeds` are treated as deliverables only (not plantable).

For MVP all crops are both plantable and deliverable. The distinction matters
for future Vertical Slice when some islands produce non-plantable resources.

### Crop Storage Cap

No cap on harvested crop quantities in MVP. The player can hold up to the
maximum theoretically harvestable in a single session (~200 crops). This is
intentional — removing anxiety about running out of delivery items.

### API Surface (implemented in `GameState.gd`)

```gdscript
func add_to_inventory(crop_id: String, amount: int) -> void
func remove_from_inventory(crop_id: String, amount: int) -> bool  // returns false if insufficient
func inventory_count(crop_id: String) -> int
func total_seeds_held() -> int
func discover_seed(crop_id: String) -> bool  // returns true if newly discovered
```

### Signals (emitted by GameState)

```gdscript
signal inventory_changed(crop_id: String, new_count: int)
```

The `inventory_changed` signal is emitted by `add_to_inventory` and
`remove_from_inventory` so the Quest Tracker UI can update reactively
without polling.

---

## Formulas

```
total_seeds_held = sum of inventory[crop_id] for each crop_id in known_seeds
```

### Seed cap check (before giving seeds to player):

```
can_receive_seeds = (total_seeds_held() + amount_to_receive) <= MAX_SEED_CAPACITY
```

`MAX_SEED_CAPACITY = 48`

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Player tries to plant when `inventory_count(seed_id) == 0` | Planting blocked; no error shown (just no response) | Player simply needs to find more seeds |
| `remove_from_inventory` called with more than available | Returns `false`; inventory unchanged | Call-site (Quest System) checks return before consuming |
| Seed cap exactly at 48 and island offers a seed | Seed offer shows "inventory full" message | Polite feedback, not a hard error |
| Player has > 48 seeds somehow (e.g., save corruption) | `add_to_inventory` still applies; cap only blocks *receiving island seeds* | Cap is a soft UX gate, not a hard invariant |
| `discover_seed` called for already-known seed | Returns false; no duplicate added to `known_seeds` | Idempotent |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Crop & Seed Database | Inventory depends on | `crop_id` values are validated against Crop DB |
| Farm Grid Manager | Grid → Inventory | Harvest events call `GameState.add_to_inventory` |
| Tile Farming System | Farming → Inventory | Planting removes a seed with `remove_from_inventory` |
| Spirit Quest System | Quest depends on | Reads `inventory_count` to check delivery readiness |
| Save / Load System | Save depends on | Serializes/deserializes `GameState.inventory` |
| Quest Tracker UI | UI depends on | Listens to `inventory_changed` signal |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect of Increase |
|-----------|--------------|------------|--------------------|
| MAX_SEED_CAPACITY | 48 | 24–72 | More seeds = more forward-planning possible |
| Harvested crop cap | None | N/A | Adding a cap would create mild pressure |

---

## Acceptance Criteria

- [ ] `add_to_inventory("clover", 3)` followed by `inventory_count("clover")` returns 3
- [ ] `remove_from_inventory("clover", 5)` when count is 3 returns `false` and count stays at 3
- [ ] `total_seeds_held()` sums only crops in `known_seeds`
- [ ] Inventory dict has no zero-count entries after any operation
- [ ] `inventory_changed` signal fires on every add and remove
- [ ] Seed cap blocks island seed offer at ≥48 total seeds held
- [ ] Round-trip save/load preserves all inventory counts exactly

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Should harvested crops and seeds be in separate inventories visually? | UX Designer | Same inventory dict; UI can group by `known_seeds` membership if needed |
