# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6
- **Language**: GDScript (primary) — statically typed, all variables must have type annotations
- **Rendering**: Godot Forward+ renderer (2D)
- **Physics**: Godot Jolt (default in 4.6)

## Naming Conventions

- **Classes**: PascalCase (e.g., `FarmGrid`, `SpiritQuest`)
- **Variables / Functions**: snake_case (e.g., `move_speed`, `get_crop_at()`)
- **Signals**: snake_case, past tense (e.g., `crop_harvested`, `day_advanced`)
- **Files**: snake_case matching class (e.g., `farm_grid.gd`, `spirit_quest.gd`)
- **Scenes**: PascalCase matching root node (e.g., `FarmGrid.tscn`, `IslandScene.tscn`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `MAX_TILES`, `DAYS_PER_ISLAND`)
- **Resources**: PascalCase (e.g., `CropData.tres`, `IslandData.tres`)

## Performance Budgets (Mobile)

- **Target Framerate**: 60fps
- **Frame Budget**: 16.6ms
- **Draw Calls**: < 50 per frame (mobile constraint)
- **Memory Ceiling**: < 200MB total
- **Texture Budget**: 512×512 max per spritesheet, PNG

## Testing

- **Framework**: GUT (Godot Unit Testing)
- **Minimum Coverage**: Core data systems (crop database, quest logic, save/load)
- **Required Tests**: Crop growth calculations, quest completion logic, save/load round-trip

## Forbidden Patterns

- No `get_node()` with string paths — use `@onready var` typed references
- No untyped variables — all `var` declarations must have type annotations
- No `print()` statements in production code — use `push_warning()` / `push_error()`
- No energy systems or timers that block gameplay
- No combat systems (anti-pillar)

## Allowed Libraries / Addons

- GUT (Godot Unit Testing) — test framework
- [Other addons TBD after prototype]

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]
