# VivesPong 3D

3D Pong MVP in Godot 4.7 for VivesCast. First playable target is local versus, primitives only, 1280x720 @ 60 FPS. Do not expand scope until 0.1 is finished.

Spec: [docs/sdd-vivespong-0.1.md](docs/sdd-vivespong-0.1.md). TDD plan: [docs/superpowers/plans/2026-08-15-vivespong-0.1-tdd.md](docs/superpowers/plans/2026-08-15-vivespong-0.1-tdd.md). Implement in red-green order; do not invent behavior the SDD does not list.

## Stack

- Engine: Godot **4.7.1-stable** (features `4.7`, renderer **Forward Plus**, Vulkan)
- Language: **GDScript** only. No external addons for the MVP.
- Gameplay is **3D**: `CharacterBody3D` / `StaticBody3D` / `AnimatableBody3D` / `Area3D`. Jolt is the 3D physics engine.
- Target window: 1280x720, 60 FPS. Think Linux ARM64 / Mali-G610 later; develop on Windows first.
- Live editor: Godot AI MCP plugin `addons/godot_ai` v3.1.5 (enabled). Autoload `_mcp_game_helper` is required for play-mode eval.

## Current project state

- No main scene yet (`application/run/main_scene` is unset)
- No `.tscn` game scenes
- First logic: `scripts/match_state.gd` (`MatchState`) — win at 10 goals
- First test: `tests/test_match.gd` (`suite_name` = `match`)
- Git is **not** initialized. `.gitignore` / `.gitattributes` are the Godot 4 defaults
- `Godot-MCP-6bd23f6a832ac5e75798d4b68e42155c6e3a187a/` is an unused C# MCP dump. **Do not enable, move, or edit it.**

## Commands / editor workflow

There is no CLI build. Work through the connected Godot editor (MCP `godot-ai`) when it is live.

| Action | How |
|---|---|
| Inspect editor | `godot-ai__editor_state` |
| Create / open scenes | `scene_manage` / `scene_open` |
| Create scripts | `script_create` (triggers editor scan + diagnostics) |
| Run game | `project_run` (`mode=main` once a main scene exists; `custom` + `scene=` otherwise) |
| Stop game | `project_manage(op="stop")` |
| Runtime inspect | `editor_manage(op="game_eval")` — only while the game is live and focused |
| Docs | context7 (`/godotengine/godot`) or `godot-ai__api_manage` for ClassDB |

If MCP writes are rejected as `EDITOR_NOT_READY (state=playing)`, stop the game first. If `game_status.status` is `break`, stop, fix the parse/load error, then rerun.

After adding a `class_name` script, call `filesystem_manage(op="scan")` so the global class table updates.

Tests live in `res://tests/test_*.gd`, extend `McpTestSuite`, and preload production scripts (`preload("res://scripts/....gd")`) instead of relying on a freshly-registered `class_name`. Run with `godot-ai__test_run` (`suite="match"` for the first suite). Write the failing test first.

## Target layout (create as you implement)

```
res://
  scenes/           # Main.tscn, Paddle.tscn, Ball.tscn
  scripts/          # match_state.gd, main.gd, paddle.gd, ball.gd
  tests/            # test_*.gd — Godot AI McpTestSuite
  ui/               # score / message / FPS overlays
  assets/audio/
  assets/textures/
  addons/godot_ai/  # vendor — do not edit
```

Set `application/run/main_scene` as soon as `res://scenes/Main.tscn` exists.

## Code style

- GDScript 2.0 static types on every variable, parameter, and return: `var speed: float = 400.0`
- `class_name` on reusable entities (`Paddle`, `Ball`, `ScoreUI`)
- `@export` for tunables (speed, size, serve delay). No magic numbers in `_physics_process`
- `_ready` for node wiring; `_physics_process` for movement; signals for score / serve / reset
- Node paths via `$Child` or `%UniqueName`, never brittle absolute paths
- Input via the Input Map only: `player1_left` / `player1_right` / `player2_left` / `player2_right` (plus Start later). Never read raw keycodes in gameplay
- Tabs for indentation (Godot default). LF line endings (see `.gitattributes`)
- File names: `snake_case.gd` / `snake_case.tscn`. `class_name`: `PascalCase`

## Game conventions

- Two paddles on Z ends, ball in XZ, side walls, goal areas, fixed elevated camera
- Paddles move only on X (A/D and arrows; later gamepad stick/D-pad)
- Paddle bounce angle depends on hit offset (center = straight, edges = wider)
- First to `MatchState.WIN_SCORE` (10) wins; Start resets to 0-0
- No online multiplayer, AI, store, shaders, or extra scenes until 0.1 ships
- Sound comes in a later iteration (paddle / wall / score / go / win)

## Art / audio

Primitives only for 0.1 (`BoxMesh`, `SphereMesh`). Retro + arcade + minimal futurist. When generating textures or UI later, load the matching Grok game-asset skills.

## Do not

- Edit `addons/godot_ai/` or the unused `Godot-MCP-*` tree
- Check in `.godot/`
- Introduce C#, networking, or extra features before VivesPong 0.1
- Hand-edit `.import` files
- Commit secrets or MCP tokens
