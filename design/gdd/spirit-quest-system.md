# Spirit Quest System

> **Status**: Approved
> **Author**: game-designer + narrative-director
> **Last Updated**: 2026-04-03
> **Implements Pillar**: Every Day Has Purpose · Journey Is the Joy

---

## Overview

The Spirit Quest System presents the active island's harvest quest to the
player, tracks their delivery progress against the quest's required crops,
grants the reward when complete, and marks the island as finished. It reads
quest definitions from Spirit & Island Data and crop counts from Inventory.
It does not own any data — it is a pure business logic layer.

---

## Player Fantasy

Delivering crops to a spirit should feel like bringing a gift to a friend.
The moment of "quest complete" should be a small ceremony — the spirit's
expression changes, a warm dialogue plays, and you receive something new.
The quest goal should always be visible so the player never feels lost —
"I know I need 4 sunflowers, I have 2, I'm making progress."

---

## Detailed Design

### Quest Lifecycle

```
IDLE                   → No island loaded or quest already completed
ACTIVE                 → Island loaded, quest in progress
DELIVER_IN_PROGRESS    → Player opened deliver screen; delivery being reviewed
COMPLETED              → All required crops delivered; reward granted
EXPIRED (not in MVP)   → Player drifted away before completing
```

#### State Transitions

| From | To | Trigger |
|------|----|---------|
| IDLE | ACTIVE | Player arrives on island (`island_loaded` signal) |
| ACTIVE | DELIVER_IN_PROGRESS | Player taps "Deliver" button in Quest Tracker UI |
| DELIVER_IN_PROGRESS | ACTIVE | Player cancels delivery (changes mind) |
| DELIVER_IN_PROGRESS | COMPLETED | Inventory has all required crops; player confirms |
| COMPLETED | IDLE | Drift / Travel System loads next island |

### Delivery Check

**When the player taps "Deliver":**

1. Load island quest definition from `IslandDatabase.get_island(GameState.current_island_id)`
2. For each entry in `quest.required_crops`:
   - Compute `effective_count` using substitution rules (see below)
   - If `effective_count < required_amount` → delivery blocked; show which crops are missing
3. If all requirements met:
   - Remove required crops from inventory (exact amounts)
   - Call `GameState.discover_seed(quest.reward_seed)`
   - `GameState.add_to_inventory(quest.reward_seed, 4)` — give 4 seeds of the reward crop
   - Unlock `quest.reward_lore_fragment` in `GameState.lore_fragments`
   - Emit `quest_completed(island_id)`
   - Add `island_id` to `GameState.completed_quests`

### Substitution Rule (Autumn Island only, MVP)

Autumn Island allows `amber_wheat` to count double toward the wheat quota:

```
effective_wheat =
  inventory_count("wheat") + inventory_count("amber_wheat") * 2
```

This rule is applied inside the delivery check when `current_island_id == "island_autumn"`.

Substitutions are defined in `islands.json` under `quest.substitutions` and
the Spirit Quest System reads them dynamically — no hardcoded island IDs in logic.

```gdscript
for sub in quest.get("substitutions", []):
    var sub_id: String = sub["crop_id"]
    var counts_as: String = sub["counts_as"]
    var multiplier: int = sub["multiplier"]
    effective[counts_as] += inventory_count(sub_id) * multiplier
```

### Partial Delivery Feedback

If the player taps Deliver but doesn't have enough:
- Quest Tracker UI shows each requirement with current/needed count
- Requirements NOT met are shown in red; met requirements in green
- Spirit plays `dialogue_partial_deliver` (if delivery was attempted with ≥1 crop delivered in previous partial)

### Reward Grant Details

On quest completion:
1. If `reward_seed` is already known: Give 4 seeds (not 1) — `add_to_inventory("reward_seed", 4)`
2. If `reward_seed` is new: `discover_seed(reward_seed)` → add to `known_seeds`; give 4 seeds
3. `lore_fragments` array appended with `reward_lore_fragment` index (if not already present)

---

## Formulas

### Effective crop count for delivery check

```
effective_count = {}
for crop_id in quest.required_crops:
    effective_count[crop_id] = GameState.inventory_count(crop_id)

for sub in quest.substitutions:
    effective_count[sub.counts_as] += GameState.inventory_count(sub.crop_id) * sub.multiplier
```

### Quest completion condition

```
quest_complete = all(effective_count[req.crop_id] >= req.amount
                     for req in quest.required_crops)
```

---

## Signals

```gdscript
signal quest_loaded(island_id: String)
signal quest_completed(island_id: String)
signal delivery_failed(missing_crops: Dictionary)  # crop_id -> amount_still_needed
```

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Player delivers more than required | Excess crops consumed; no error | Generosity is valid |
| Quest already completed for current island | Deliver button hidden in UI; spirit plays `dialogue_complete` | Clean state |
| Island has no quest (shouldn't happen in MVP) | System stays IDLE; no deliver button shown | Defensive |
| Reward seed inventory would exceed 48-cap | Seeds still given — cap only blocks island seed pickups, not quest rewards | Quest reward is special |
| `deliver()` called twice quickly | Second call is a no-op if state is already COMPLETED | Guard via state check |
| `reward_lore_fragment` already unlocked | Fragment is not duplicated in `lore_fragments` | Idempotent |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Spirit & Island Data | Quest depends on | Reads island quest definition via `IslandDatabase` |
| Inventory / Crop Storage | Quest depends on | Reads crop counts; removes crops on delivery |
| GameState | Quest depends on | Reads `current_island_id`; writes `completed_quests`, `lore_fragments`, `known_seeds` |
| Drift / Travel System | Drift depends on Quest | Drift unlocked only after `quest_completed` fires |
| Quest Tracker UI | UI depends on Quest | Displays quest requirements and delivery state |
| Save / Load System | Save depends on Quest | `completed_quests` and `lore_fragments` persisted |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect |
|-----------|--------------|------------|--------|
| Reward seed quantity | 4 | 2–8 | More seeds = faster crop discovery |
| Amber wheat substitution multiplier | ×2 | ×1.5–×3 | Higher = amber wheat more powerful |
| Allow partial delivery (keep crops, save state) | No (all-or-nothing) | N/A | Partial delivery adds UX complexity |

---

## Acceptance Criteria

- [ ] Loading an island sets quest state to ACTIVE and shows requirements
- [ ] Tapping Deliver with insufficient crops shows which crops are missing
- [ ] Delivering exactly the required crops completes the quest
- [ ] `reward_seed` is added to `known_seeds` and +4 seeds added to inventory
- [ ] `quest_completed` signal fires after successful delivery
- [ ] `island_id` appears in `GameState.completed_quests` after completion
- [ ] Amber wheat counts double toward wheat requirement on Autumn Island
- [ ] Delivering excess crops consumes exact required amounts, not all
- [ ] Quest deliver is blocked (button hidden) if quest already completed

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Can the player partially deliver crops (one by one)? | Lead Designer | No — all-or-nothing delivery in MVP. Reduces UI complexity. |
| Should there be a visual "delivery ceremony" animation? | Art Director | Yes — spirit portrait flash + particle burst. Spec in Quest Tracker UI GDD. |
