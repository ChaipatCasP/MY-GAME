# Spirit & Island Data

> **Status**: Approved
> **Author**: game-designer + narrative-director
> **Last Updated**: 2026-03-27
> **Implements Pillar**: Every Day Has Purpose · Journey Is the Joy

---

## Overview

The Spirit & Island Data system defines the 4 spiritual realms the player's
floating farm drifts through. Each island belongs to one season, is guarded
by a Spirit with a name and personality, and contains a harvest quest the player
must fulfill before they can drift onward. This system is pure data — it does
not execute logic itself; the Spirit Quest System and Drift System read from it.

---

## Player Fantasy

The player should feel a sense of gentle anticipation before each island — "I
wonder what the Autumn Spirit needs this time." Each spirit should feel like a
distinct personality, not a generic quest-giver. The island itself should
visually feel like that season's world, reinforcing the fantasy that the player
is literally farming at the edge of autumn or in the heart of winter.

---

## Detailed Design

### Island Structure

Each island is defined by:
- `island_id` — unique identifier (e.g., `"island_spring"`)
- `season` — Spring / Summer / Autumn / Winter
- `spirit` — nested Spirit definition (see below)
- `available_seeds` — 2–3 crop_ids the player can collect here (free on first visit)
- `quest` — the spirit's harvest request (see Quest Structure below)
- `color_palette` — 4 hex colors defining the visual theme (passed to art pipeline)
- `ambient_music_track` — filename reference for the island's background music

### Spirit Structure

Each Spirit has:
- `spirit_id` — e.g., `"spirit_spring"`
- `name` — display name
- `title` — one-line flavour description
- `personality` — short note for writers (not player-facing; guides dialogue tone)
- `portrait_asset` — filename reference for spirit portrait image
- `dialogue_intro` — short greeting shown on arrival (1–2 sentences)
- `dialogue_quest_given` — dialogue when quest is presented
- `dialogue_partial_deliver` — dialogue when player delivers some but not all
- `dialogue_complete` — dialogue when quest is fulfilled
- `dialogue_leave_incomplete` — dialogue when player drifts away without completing

### Quest Structure

Each island has exactly **one quest** (MVP scope — no multi-step quests at launch).

A quest is defined by:
- `required_crops` — array of `{ crop_id, amount }` pairs (1–3 entries)
- `reward_seed` — a `crop_id` the spirit gives on completion (unlocks if new)
- `reward_lore_fragment` — index of a lore text entry unlocked on completion

---

### The 4 Islands (Full Data)

---

#### Island 1 — Spring Island

```
island_id:        "island_spring"
season:           Spring
color_palette:    ["#B8E4A0", "#F9F3C7", "#8FC97A", "#FFFFFF"]
ambient_music:    "spring_ambient.ogg"
available_seeds:  ["clover"]
```

**Spirit: Haru (春)**
```
spirit_id:        "spirit_spring"
name:             "Haru"
title:            "The Waker of Seeds"
personality:      Gentle, encouraging, motherly. Speaks in soft, uplifting tones.
                  Smells like rain on warm soil.
portrait_asset:   "spirit_spring.png"

dialogue_intro:
  "Oh! A floating farm... I haven't seen one of those in a long, long time.
   Welcome, wanderer. My name is Haru."

dialogue_quest_given:
  "My meadow is tired. It needs 6 Clover to bloom again.
   Will you grow them for me?"

dialogue_partial_deliver:
  "These are lovely. Keep going — the meadow can feel them already."

dialogue_complete:
  "The meadow is singing! You may take some Moonbloom seeds as thanks.
   May the wind carry you somewhere beautiful."

dialogue_leave_incomplete:
  "Oh... I understand. The wind is calling you. Come back someday."
```

**Quest:**
```
required_crops:   [{ crop_id: "clover", amount: 6 }]
reward_seed:      "moonbloom"
reward_lore_fragment: 0  // "Before the seasons drifted apart..."
```

---

#### Island 2 — Summer Island

```
island_id:        "island_summer"
season:           Summer
color_palette:    ["#F5C84A", "#F9954A", "#FFE87A", "#4A9BCC"]
ambient_music:    "summer_ambient.ogg"
available_seeds:  ["sunflower", "moonbloom"]
```

**Spirit: Natsu (夏)**
```
spirit_id:        "spirit_summer"
name:             "Natsu"
title:            "The Keeper of Brilliant Things"
personality:      Boisterous, joyful, slightly dramatic. Laughs easily.
                  Gives the impression of heat shimmer and festival noise.
portrait_asset:   "spirit_summer.png"

dialogue_intro:
  "AHAHA! A FARM! FLOATING! Right here! This is the most wonderful thing
   I have seen all season, and I have seen MANY wonderful things."

dialogue_quest_given:
  "My festival is almost here and I need something golden. Bring me
   4 Sunflowers and 2 Moonblooms. BIG ones, yes? Well, any size."

dialogue_partial_deliver:
  "Yes, yes! More, more! The festival drums are already beating!"

dialogue_complete:
  "PERFECT! The festival can begin! Here — Amber Wheat seeds. A gift
   from the sun itself. Well. From me. Same thing."

dialogue_leave_incomplete:
  "Ah... the festival will be a little quieter this year. Come back
   before next summer, yes? The drums will still be waiting."
```

**Quest:**
```
required_crops:   [
  { crop_id: "sunflower", amount: 4 },
  { crop_id: "moonbloom", amount: 2 }
]
reward_seed:      "amber_wheat"
reward_lore_fragment: 1  // "The seasons began drifting when the festival fire went out..."
```

---

#### Island 3 — Autumn Island

```
island_id:        "island_autumn"
season:           Autumn
color_palette:    ["#D4622A", "#8B3A1A", "#F0A830", "#3A2A18"]
ambient_music:    "autumn_ambient.ogg"
available_seeds:  ["wheat"]
```

**Spirit: Aki (秋)**
```
spirit_id:        "spirit_autumn"
name:             "Aki"
title:            "The Keeper of What Remains"
personality:      Quiet, melancholic, wise. Speaks slowly, as if choosing every
                  word. Long silences are comfortable, not awkward.
portrait_asset:   "spirit_autumn.png"

dialogue_intro:
  "...You came.
   The wind doesn't bring visitors very often anymore."

dialogue_quest_given:
  "The harvest was... thin this year. If you could bring me
   8 Wheat — or some Amber if you've found it —
   I could put the field to rest properly."

dialogue_partial_deliver:
  "...This helps.
   A little."

dialogue_complete:
  "...Thank you.
   The field is resting now. Here. Frostbell seeds.
   For the winter ahead."

dialogue_leave_incomplete:
  "...
   It's all right.
   The field understands."
```

**Quest:**
```
required_crops:   [
  { crop_id: "wheat", amount: 6 },
  { crop_id: "amber_wheat", amount: 2 }   // amber_wheat optional substitution (2 = 1 wheat)
]
reward_seed:      "frostbell"
reward_lore_fragment: 2  // "Aki remembers the last harvest before the great drift..."
```

**Special Rule**: `amber_wheat` counts double toward the wheat requirement (1 amber_wheat = 2 wheat toward quota). Defined here as a quest-level substitution rule, implemented by Spirit Quest System.

---

#### Island 4 — Winter Island

```
island_id:        "island_winter"
season:           Winter
color_palette:    ["#D8EEFF", "#8BB8D8", "#FFFFFF", "#2A4060"]
ambient_music:    "winter_ambient.ogg"
available_seeds:  ["snowdrop"]
```

**Spirit: Fuyu (冬)**
```
spirit_id:        "spirit_winter"
name:             "Fuyu"
title:            "The One Who Remembers"
personality:      Ancient, calm, vast. The only spirit who seems to know why
                  the seasons drifted apart. Speaks with gentle finality.
portrait_asset:   "spirit_winter.png"

dialogue_intro:
  "I have been waiting a very long time.
   I am glad you found me before the cold grew too deep."

dialogue_quest_given:
  "There is one thing I need before I can let the world
   remember spring again. Can you bring me 4 Snowdrops?
   Something that survives the cold, to prove life persists."

dialogue_partial_deliver:
  "They're beautiful. Each one that survives the frost is a small miracle."

dialogue_complete:
  "...Yes.
   It is enough. The world remembers now.

   You may go home, wanderer.
   The seasons will find their way back."

dialogue_leave_incomplete:
  "The cold will hold a little longer.
   But you will return.
   I have always known you would return."
```

**Quest:**
```
required_crops:   [
  { crop_id: "snowdrop", amount: 3 },
  { crop_id: "frostbell", amount: 1 }
]
reward_seed:      "spiritgrass"     // unlocks the post-game "restored world" seed
reward_lore_fragment: 3  // "The last fragment: why the seasons drifted apart"
```

---

### Drift Order

Islands are visited in a fixed order on first playthrough:
`Spring → Summer → Autumn → Winter`

In New Game+, the order shuffles and quest requirements increase by 25%.

---

## Formulas

No runtime formulas in this system. All data is static. The Spirit Quest
System reads `required_crops` at island arrival and evaluates fulfillment.

The amber_wheat substitution rule is the only special logic:

```
effective_wheat_toward_quota =
  sum(crop_id == "wheat") + sum(crop_id == "amber_wheat") * 2
```

This formula lives in Spirit Quest System; it is documented here for traceability.

---

## Edge Cases

| Scenario | Expected Behavior | Rationale |
|----------|------------------|-----------|
| Player hasn't yet unlocked `amber_wheat` when arriving at Autumn Island | Quest shows only wheat requirement; amber_wheat substitution doesn't appear | Can't offer a crop they don't know about |
| Player delivers more than required | Excess ignored; quest completes normally | Generosity is not punished |
| Player revisits a completed island (NG+) | New quest active; spirit dialogue uses `dialogue_quest_given` variant | Fresh state |
| `reward_seed` already known to player | No duplicate seed given; instead player gets +4 of that seed | Prevents inventory dead-end |
| Player leaves Spring Island before completing (soft fail) | Spring island remains accessible next loop (NG+); first playthrough — soft consequence to Summer | Cozy Always Wins |

---

## Dependencies

| System | Direction | Nature |
|--------|-----------|--------|
| Spirit Quest System | Quest depends on this | Reads `required_crops`, `reward_seed`, `reward_lore_fragment` |
| Drift / Travel System | Drift depends on this | Reads island sequence and next island definition |
| Crop & Seed Database | This depends on Crop DB | All `crop_id` references must exist in Crop DB |
| Tile Farming System | Indirect | Season affinity penalty uses `current_island.season` |
| Soft Consequence System | Soft Consequence depends on this | Reads whether quest was completed before drift |

---

## Tuning Knobs

| Parameter | Current Value | Safe Range | Effect of Increase | Effect of Decrease |
|-----------|--------------|------------|-------------------|-------------------|
| Spring quest: clover amount | 6 | 4–8 | Longer tutorial island | Too short to introduce farming |
| Summer quest: sunflower amount | 4 | 3–6 | More sunflower farming | Reduces planning depth |
| Autumn: amber_wheat substitution multiplier | ×2 | ×1.5–×3 | More reward for finding cross-seed | Makes amber_wheat less special |
| Winter: snowdrop amount | 3 | 2–4 | Long final island | Diminishes final emotional moment |

---

## Visual / Audio Requirements

| Event | Visual Feedback | Audio Feedback |
|-------|----------------|---------------|
| Island arrival | Fade in to new color palette; spirit portrait animates in | Island ambient music fades in |
| Quest given | Spirit dialogue box appears; quest tracker populates | Soft chime |
| Quest complete | Spirit portrait brightens; celebration particles | Spirit-specific "thank you" jingle |
| Partial delivery | Spirit reacts (portrait expression changes) | Warm acknowledgment SFX |
| Leave incomplete | Spirit portrait dims slightly | Melancholy musical sting (brief) |

---

## Acceptance Criteria

- [ ] All 4 islands exist with correct `season`, `available_seeds`, and `quest` data
- [ ] All 4 spirits have all 5 dialogue lines populated
- [ ] Spring island quest: 6 clover completes it
- [ ] Summer island quest: 4 sunflower + 2 moonbloom completes it
- [ ] Autumn island: 1 amber_wheat counts as 2 wheat toward quota
- [ ] Winter island: 3 snowdrop + 1 frostbell completes it
- [ ] `reward_seed` is given to player on quest completion
- [ ] All crop_ids referenced in island data exist in Crop & Seed Database

---

## Open Questions

| Question | Owner | Resolution |
|----------|-------|-----------|
| Should spirits appear as full-body sprites or portrait busts only? | Art Director | Portrait busts (scope constraint for solo dev) |
| How does the amber_wheat substitution rule surface in the UI? | UX Designer | Quest Tracker UI shows "6 Wheat (or 3 Amber Wheat)" — to be spec'd in Quest Tracker UI GDD |
