## Prototype Report: Tile Farming Touch Controls

### Hypothesis
Touch-based tap-to-interact on a 6×8 farm tile grid on mobile:
- Tile tap targets (56px) are large enough to hit accurately
- The plant → water → harvest 3-state flow reads clearly from color alone
- Advancing the day feels rewarding, not tedious

### Approach
Built a minimal Godot 4.6 2D prototype in `prototypes/tile-farming-touch/`.
- No sprites — placeholder colored rectangles per tile state
- No audio
- No quest system
- Single scene: FarmGrid (6×8 tiles) + Next Day button + harvest counter
- Tap detection via `InputEventScreenTouch` and `InputEventMouseButton`
- Took approximately 2–3 hours to implement

Shortcuts taken:
- Scripts directly instantiated with `set_script()` — no .tscn files per tile
- Hardcoded grow time (3 days), grid size, tile size
- No save, no persistence
- Color-only visuals

### Result
*To be filled after testing on a physical device or Godot's mobile simulator.*

Key things to observe during testing:
1. **Tap accuracy** — Can you reliably hit individual tiles without mis-tapping adjacent ones?
2. **Visual legibility** — Is Brown/Green/Gold legible at a glance? Does the day counter on growing tiles read clearly?
3. **Day advance feel** — Does tapping "Next Day" feel like a satisfying rhythm break?
4. **Session feel** — After planting all 48 tiles and waiting 3 days, does harvesting feel rewarding?

### Metrics
*To be filled after testing.*
- Mis-tap rate: [count mis-taps in 10 interactions]
- Feel assessment: [rate 1-5 each: tap precision, visual clarity, day advance satisfaction, harvest satisfaction]
- Session length before feeling complete: [minutes]

### Recommendation: [PENDING — test first]

---

### If Proceeding (expected)
Changes needed for production implementation:
1. Replace colored rectangles with pixel art sprites (3 growth stages + empty soil)
2. Replace `set_script()` instantiation with a proper `CropTile.tscn` scene
3. Add satisfying SFX for plant / water / harvest
4. Connect to real CropData Resource (grow time driven by crop type, not hardcoded)
5. Touch target size: confirm 56px tiles work — increase to 60px if accuracy is below 90%
6. Add haptic feedback on harvest (Godot 4.6: `Input.vibrate_handheld()`)

### If Pivoting
If tap accuracy is too low → increase tile size and reduce grid to 5×6
If 3-state color loop feels boring → add intermediate "watered" state with distinct visual
If "Next Day" feels tedious → replace button with gesture (swipe down = advance day)

### Lessons Learned
*To be filled after testing.*
