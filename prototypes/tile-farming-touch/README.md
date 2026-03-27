# Prototype: Tile Farming Touch Controls

**Status**: In Progress
**Date**: 2026-03-27
**Engine**: Godot 4.6

## Hypothesis

Touch-based tap-to-interact on a 6×8 farm tile grid on mobile feels satisfying
and is not frustrating. Specifically:
- Tile tap targets are large enough to hit accurately without a mouse
- The plant → water → harvest flow reads clearly from visual state alone
- Advancing the day feels rewarding, not like waiting

## How to Run

1. Open Godot 4.6
2. Open `prototypes/tile-farming-touch/` as a project
3. Run the main scene (`Main.tscn`)
4. On desktop: use left mouse button to simulate touch taps
5. On device: export to Android/iOS via Godot's one-click export (debug template)

## Files

```
prototypes/tile-farming-touch/
├── README.md              # This file
├── project.godot          # Godot project config
├── Main.tscn              # Entry scene
├── Main.gd                # Main controller
├── FarmGrid.gd            # 6×8 tile grid logic
├── CropTile.gd            # Single tile state machine
└── REPORT.md              # Findings (filled after testing)
```

## Scope

- [x] 6×8 tile grid with tap-to-interact
- [x] 3 tile states: Empty → Growing → Harvestable
- [x] "Next Day" button advances all growing crops
- [x] Visual color coding per state (placeholder art)
- [ ] Real pixel art sprites (not needed for this prototype)
- [ ] Spirit quest system (not tested here)
- [ ] Save/load (not tested here)

## Current Findings

*To be filled after testing on a device.*
