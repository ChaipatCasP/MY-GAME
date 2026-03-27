# Game Concept: Drifting Seasons

*Created: 2026-03-27*
*Status: Draft*

---

## Elevator Pitch

> It's a cozy farming sim where you tend crops on a floating island that drifts
> between seasonal spirit realms, fulfilling each spirit's harvest request to
> restore peace to the world — one season at a time.

---

## Core Identity

| Aspect | Detail |
| ---- | ---- |
| **Genre** | Cozy Farming Sim / Light Adventure |
| **Platform** | Mobile (iOS / Android) |
| **Target Audience** | Casual-to-midcore players who love Harvest Moon / Stardew Valley, 18–35 |
| **Player Count** | Single-player |
| **Session Length** | 10–20 minutes (mobile-friendly) |
| **Monetization** | Premium (paid once) — no energy systems |
| **Estimated Scope** | Small (3–4 months solo) |
| **Comparable Titles** | Harvest Moon: Light of Hope, Stardew Valley, Alba: A Wildlife Adventure |

---

## Core Fantasy

You are a wandering farmer whose floating island home drifts between the four
spirit realms of the seasons. The spirits — guardians of Spring, Summer, Autumn,
and Winter — have grown quiet, their lands falling out of balance. Only by
growing the correct harvest and offering it to each spirit can you restore the
natural cycle and find your way home.

The fantasy is: *peaceful mastery in motion* — you are never stuck in one place
long enough to feel bored, but every visit feels meaningful because a spirit
is waiting for what only you can grow.

---

## Unique Hook

Like Harvest Moon, **AND ALSO** your farm travels — each season you drift to a
new spirit island with a unique harvest quest, new crop seeds to discover, and a
world that reacts to whether you succeeded or fell short.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics (What the player FEELS)

| Aesthetic | Priority | How We Deliver It |
| ---- | ---- | ---- |
| **Sensation** (sensory pleasure) | 2 | Warm pixel art, satisfying crop-tap sounds, smooth drift animation |
| **Fantasy** (make-believe, role-playing) | 3 | Wandering spirit-world farmer identity |
| **Narrative** (drama, story arc) | 4 | Each spirit has a short story unlocked through offerings |
| **Challenge** (obstacle course, mastery) | 5 | Soft — planning which crops to plant given quest constraints |
| **Fellowship** (social connection) | N/A | Single-player only |
| **Discovery** (exploration, secrets) | 3 | New islands, rare seed combinations, hidden spirit lore |
| **Expression** (self-expression, creativity) | N/A | Minimal — not a builder game |
| **Submission** (relaxation, comfort zone) | 1 | Low-stress loop, no fail state, ambient music |

### Key Dynamics (Emergent player behaviors)
- Players will plan ahead: "I need 8 Autumn Wheat, so I'll plant now and water every 2 days"
- Players will experiment with rare seed cross-breeding to discover special offerings
- Players will re-visit completed islands to find missed spirit dialogue
- Players will delay traveling to squeeze in "one more harvest"

### Core Mechanics (Systems we build)

1. **Tile Farming** — tap-to-plant, tap-to-water, tap-to-harvest on a grid-based floating farm
2. **Spirit Quest System** — each island has a spirit with 1–3 harvest requirements to fulfill
3. **Drift / Travel System** — when quest is complete (or player chooses), farm drifts to next island; brief cinematic transition
4. **Seed Discovery** — new seeds found on each island; some require combining crops to unlock rare varieties
5. **Soft Consequence System** — if you leave an island without completing the quest, the next island is slightly harder (e.g., shorter growing season window)

---

## Player Motivation Profile

### Primary Psychological Needs Served

| Need | How This Game Satisfies It | Strength |
| ---- | ---- | ---- |
| **Autonomy** | Choose what to plant, when to travel, whether to chase rare seeds | Supporting |
| **Competence** | Clear visual feedback on crop growth; satisfying "quest complete" ceremony | Core |
| **Relatedness** | Emotional connection to the spirits through short story snippets | Supporting |

### Player Type Appeal (Bartle Taxonomy)

- [x] **Achievers** — Spirit quest completion, seed collection log, "all spirits restored" end goal
- [x] **Explorers** — Hidden island events, rare seed combinations, spirit lore fragments
- [ ] **Socializers** — N/A (single-player)
- [ ] **Killers/Competitors** — N/A

### Flow State Design

- **Onboarding curve**: First island (Spring Spirit) is a tutorial-lite — only 2 crop types, simple quest. No text walls.
- **Difficulty scaling**: Later islands require more crop variety, longer grow times, and juggling multiple spirit requests simultaneously.
- **Feedback clarity**: Crops visually show growth stages. Quest tracker always visible. Spirit reacts emotionally to offerings.
- **Recovery from failure**: No fail state. Missing a quest just adds a "cloudy weather" modifier to the next island — still playable, just slightly constrained.

---

## Core Loop

### Moment-to-Moment (30 seconds)
Tap a soil tile → plant a seed → tap crops to water → harvest when ready.
The action is tactile, satisfying, and requires no complex input. Works
perfectly with one-thumb mobile play.

### Short-Term (5–15 minutes)
Check current spirit quest → plan which crops to plant → tend the farm
across several in-game days → deliver harvest to the spirit altar.
Each island contains 3–5 in-game days of content.

### Session-Level (15–20 minutes)
A typical session: tend existing crops, complete the current spirit quest,
trigger the drift cinematic to a new island, plant the first crops there.
Natural stopping point: just after arriving at a new island.
Hook to return: "I wonder what the next spirit looks like / wants."

### Long-Term Progression
- Restore all 4 seasonal spirits (Spring, Summer, Autumn, Winter)
- Discover all rare seed varieties (~20 seeds total)
- Unlock all spirit backstory fragments
- Post-completion: New Game+ with increased spirit demands

### Retention Hooks
- **Curiosity**: "What does the Winter Spirit look like? What's the rarest seed?"
- **Investment**: Partially-grown crops on the farm that need tending tomorrow
- **Mastery**: Optimizing farm layout to maximize yield within the quest deadline

---

## Game Pillars

### Pillar 1: Every Day Has Purpose
Every in-game day on the island has a clear, visible goal tied to the
spirit quest. Players always know what they are working toward.

*Design test*: If we're debating "add a free-roam island with no quest" vs
"each island always has a spirit waiting," this pillar says we keep the spirit.

### Pillar 2: Journey Is the Joy
The act of traveling between islands — the drift animation, the first reveal
of a new spirit realm — must feel as good as the farming itself. Travel is
not a loading screen; it's a moment of wonder.

*Design test*: If we're debating "fast travel button" vs "animated drift
sequence with ambient discovery," this pillar says we keep the drift sequence.

### Pillar 3: Cozy Always Wins
There are no punishing fail states. Stress is never the tool we use to create
engagement. Mild consequences exist to add planning depth, not anxiety.

*Design test*: If we're debating "time limit with harsh penalty" vs "soft
weather modifier if you miss a quest," this pillar says we choose the soft
modifier every time.

### Anti-Pillars (What This Game Is NOT)

- **NOT combat**: No enemies, no weapons. Introducing combat would betray
  the core cozy fantasy and blow scope.
- **NOT an energy system**: No "come back in 4 hours to play." This is
  premium / all-session accessibility.
- **NOT a base builder**: Players cannot freely rearrange the island layout
  into a complex base. Farm is fixed-grid. This protects scope.
- **NOT multiplayer**: Solo only. Adding co-op would triple the technical scope.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
| ---- | ---- | ---- | ---- |
| Harvest Moon: Light of Hope | Seasonal farming rhythm, NPC gift-giving loop | Replace NPC village with traveling spirit realms | Validates that farming + story goals resonate on mobile |
| Stardew Valley | Crop growth satisfaction, pixel visual language | Tighter scope, no combat, no relationship web | Shows the audience exists and values the loop |
| Alba: A Wildlife Adventure | Calm mobile pacing, clear daily goals, emotional payoff | Farming instead of wildlife; spirit mythology | Shows premium mobile cozy games can succeed |

**Non-game inspirations**:
- Studio Ghibli films (*Castle in the Sky*, *Nausicaä*) — floating world, relationship with spirits of nature
- Thai floating markets — the sense of community and commerce while adrift
- Seasonal matsuri (Japanese festivals) — ritual and purpose tied to each season

---

## Target Player Profile

| Attribute | Detail |
| ---- | ---- |
| **Age range** | 18–35 |
| **Gaming experience** | Casual to mid-core |
| **Time availability** | 10–20 minute sessions on commute, lunch break, evening wind-down |
| **Platform preference** | Mobile primary |
| **Current games they play** | Stardew Valley, Animal Crossing, Tsuki Adventure |
| **What they're looking for** | A game that feels rewarding without demanding too much time or skill |
| **What would turn them away** | Energy timers, complex menus, punishment for missing sessions, combat |

---

## Technical Considerations

| Consideration | Assessment |
| ---- | ---- |
| **Recommended Engine** | **Godot 4** — free, excellent 2D/tilemap support, strong mobile export to iOS/Android, active community, GDScript is fast to prototype in |
| **Key Technical Challenges** | Touch-optimized tile grid interaction; save/load state reliably on mobile; island transition animation |
| **Art Style** | Warm pixel art, 32×32 tiles, limited palette per island (each season has a distinct warm/cool palette) |
| **Art Pipeline Complexity** | Low-Medium — pixel art tiles are reusable; character sprites are simple top-down |
| **Audio Needs** | Moderate — ambient music per island (4 tracks), satisfying crop SFX, spirit dialogue sounds |
| **Networking** | None |
| **Content Volume** | 4 islands × 3–5 days each = ~16–20 in-game days; ~20 crop types; ~4 spirit characters; 6–8 hours of play |
| **Procedural Systems** | None in MVP — hand-crafted islands and quests for quality control |

---

## Risks and Open Questions

### Design Risks
- **Core loop repetition**: 4 islands × repeat farming loop may feel samey. Mitigation: each spirit introduces 1 unique mechanic twist (e.g., Summer Spirit introduces "combo crops" that must be planted adjacent).
- **Quest pacing on mobile**: Players may not return before crops die. Mitigation: crops do not die — they just stop growing until watered.

### Technical Risks
- **Godot mobile export polish**: Touch input feels different from desktop. Mitigation: prototype touch controls in week 1.
- **Save reliability on mobile**: App backgrounding can cause save loss. Mitigation: auto-save on every significant action.

### Market Risks
- **Cozy farming market is crowded**: Stardew Valley casts a long shadow. Mitigation: the "drifting + spirits" hook is visually distinct; focus on shorter session design that Stardew doesn't serve well.

### Scope Risks
- **Art is the bottleneck**: Solo developer doing both code and art. Mitigation: use limited palette pixel art; consider asset store for base tiles + customize. Start with placeholder art in prototype.
- **Feature creep from Concept C**: The "many biomes" idea must be capped at 4 islands for MVP.

### Open Questions
- **Is the spirit quest system fun in isolation?** → Prototype a single island with paper-prototype quest before writing full code.
- **Does the drift transition feel magical or like a loading screen?** → Test with a simple Godot tween animation in week 2.

---

## MVP Definition

**Core hypothesis**: "Players find tending crops on a mobile tile grid and completing a spirit harvest quest satisfying across a 15–20 minute session."

**Required for MVP**:
1. Touch-based tile farming (plant, water, harvest) on a 6×8 grid
2. 1 spirit with a simple harvest quest (e.g., "Bring me 6 Sunflowers")
3. In-game day cycle (tap "Next Day" to advance)
4. Basic save/load on mobile
5. Drift transition animation to a second island

**Explicitly NOT in MVP**:
- Multiple spirit characters or full story
- Rare seed discovery system
- Soft consequence (cloudy weather) system
- Music / SFX (placeholder only)
- Polished art (placeholder sprites acceptable)

### Scope Tiers (if budget/time shrinks)

| Tier | Content | Features | Timeline |
| ---- | ---- | ---- | ---- |
| **MVP** | 1 island, 1 spirit, 3 crops | Core farming loop + quest | 4 weeks |
| **Vertical Slice** | 2 islands, 2 spirits, 8 crops | Full loop + drift transition | 8 weeks |
| **Alpha** | 4 islands, all spirits, 15 crops | All features, rough art/audio | 14 weeks |
| **Full Vision** | 4 islands + NG+, 20 crops, full story | All features, polished | 18–20 weeks |

---

## Next Steps

- [ ] Run `/setup-engine godot 4` to configure engine and populate reference docs
- [ ] Run `/design-review design/gdd/game-concept.md` to validate completeness
- [ ] Run `/map-systems` to decompose into individual systems and prioritize GDD writing order
- [ ] Prototype core farming loop with touch controls (`/prototype farming-touch-grid`)
- [ ] Validate with `/playtest-report` after first playable prototype
- [ ] Plan first sprint with `/sprint-plan new`
