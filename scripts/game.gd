extends Node2D

const GameLogic = preload("res://scripts/game_logic.gd")
const LevelData = preload("res://scripts/level_data.gd")
const NutsProceduralAudio = preload("res://scripts/procedural_audio.gd")

const W := 1080.0
const H := 1920.0
const SAFE_TOP := 84.0
const PAUSE_RECT := Rect2(953.0, SAFE_TOP, 85.0, 85.0)
const PAUSE_MODAL_RECT := Rect2(130.0, 650.0, 670.0, 520.0)
const PAUSE_BUTTON_RECTS := [Rect2(170.0, 815.0, 590.0, 86.0), Rect2(170.0, 920.0, 590.0, 86.0), Rect2(170.0, 1025.0, 590.0, 86.0)]
const RESULTS_PANEL_RECT := Rect2(50.0, SAFE_TOP + 30.0, 980.0, 1660.0)
const RESULTS_HEADER_RECT := Rect2(120.0, SAFE_TOP + 60.0, 840.0, 178.0)
const RESULTS_MEDALLION_CENTER := Vector2(540.0, 710.0)
const RESULTS_MEDALLION_RADIUS := 296.0
const RESULTS_RIBBON_RECT := Rect2(175.0, 1040.0, 730.0, 82.0)
const RESULTS_BUTTON_RECTS := [Rect2(210.0, 1335.0, 660.0, 92.0), Rect2(210.0, 1447.0, 660.0, 92.0), Rect2(210.0, 1559.0, 660.0, 92.0)]
const RESULTS_SQUIRREL_POSITION := Vector2(550.0, 720.0)
const RESULTS_SQUIRREL_SCALE := 0.42
const RESULTS_SQUIRREL_HEADROOM := 18.0
const RESULTS_CARRY_SIZE := 74.0
const RESULTS_CARRY_ANCHOR := Vector2(640.0, 795.0)
const RESULTS_CARRY_STEP_Y := 45.0
const MAP_PAGE_LEVELS := 10
const MAP_PAGE_COUNT := 5
const MAP_NODE_RADIUS := 59.0
const MAP_LABEL_GAP := 16.0
const MAP_LABEL_SIZE := Vector2(188.0, 36.0)
const MAP_PREVIOUS_RECT := Rect2(62.0, 228.0, 246.0, 68.0)
const MAP_NEXT_RECT := Rect2(772.0, 228.0, 246.0, 68.0)
# Authored positions sit on the visible roots, trunk forks and major boughs
# in the two painted trees; there is deliberately no artificial rail overlay.
const MAP_NODE_POSITIONS := [
    [Vector2(432.0,1614.0),Vector2(625.0,1490.0),Vector2(445.0,1358.0),Vector2(647.0,1224.0),Vector2(448.0,1088.0),Vector2(636.0,952.0),Vector2(450.0,816.0),Vector2(632.0,682.0),Vector2(466.0,548.0),Vector2(620.0,408.0)],
    [Vector2(430.0,1608.0),Vector2(650.0,1476.0),Vector2(448.0,1340.0),Vector2(660.0,1202.0),Vector2(438.0,1060.0),Vector2(660.0,918.0),Vector2(450.0,774.0),Vector2(665.0,626.0),Vector2(458.0,482.0),Vector2(650.0,360.0)],
    [Vector2(432.0,1608.0),Vector2(620.0,1480.0),Vector2(450.0,1344.0),Vector2(640.0,1208.0),Vector2(452.0,1068.0),Vector2(632.0,930.0),Vector2(462.0,788.0),Vector2(642.0,646.0),Vector2(470.0,506.0),Vector2(630.0,370.0)],
    [Vector2(426.0,1610.0),Vector2(642.0,1482.0),Vector2(444.0,1348.0),Vector2(654.0,1214.0),Vector2(446.0,1074.0),Vector2(650.0,938.0),Vector2(456.0,798.0),Vector2(650.0,656.0),Vector2(466.0,516.0),Vector2(640.0,378.0)],
    [Vector2(434.0,1612.0),Vector2(630.0,1486.0),Vector2(450.0,1350.0),Vector2(646.0,1218.0),Vector2(456.0,1080.0),Vector2(638.0,944.0),Vector2(464.0,804.0),Vector2(644.0,664.0),Vector2(472.0,524.0),Vector2(634.0,386.0)]
]
const PLAY_RIGHT := 800.0
const FLOOR_Y := H - 175.0
const GROUND_LINE_Y := H - 90.0
const SQUIRREL_BASE_SCALE := 0.64
# The packed pose's visible feet sit this far below the cell origin at scale 1.
const SQUIRREL_FOOT_SOURCE_OFFSET := 208.0
const SQUIRREL_FOOT_OFFSET := SQUIRREL_FOOT_SOURCE_OFFSET * SQUIRREL_BASE_SCALE
const SQUIRREL_Y := GROUND_LINE_Y - SQUIRREL_FOOT_OFFSET
const TITLE_CARD_RECT := Rect2(90.0, 190.0, 900.0, 590.0)
const TITLE_SQUIRREL_SCALE := 0.70
const TITLE_SQUIRREL_SOURCE_SIZE := Vector2(1172.0, 1342.0)
const TITLE_SQUIRREL_SOURCE_BOUNDS := Rect2(82.0, 52.0, 901.0, 1181.0)
const TITLE_SQUIRREL_VISIBLE_FEET_Y := 1232.0
const TITLE_SQUIRREL_POSITION := Vector2(W * 0.5, GROUND_LINE_Y - (TITLE_SQUIRREL_VISIBLE_FEET_Y - TITLE_SQUIRREL_SOURCE_SIZE.y * 0.5) * TITLE_SQUIRREL_SCALE)
const IDLE_BOB_PIXELS := 3.0
const IDLE_BREATH_SCALE := 0.018
const IDLE_BREATH_SPEED := 3.0
const IDLE_SWAY_RADIANS := 0.018
const IDLE_SWAY_SPEED := 2.4
const FLATTEN_HOLD_SECONDS := 1.5
const POP_RECOVERY_SECONDS := 0.55
const ICICLE_BASE_ROTATION := 0.0
const ICICLE_WOBBLE_RADIANS := 0.055
const BRANCH_BASE_ROTATION := 0.0
const BRANCH_WOBBLE_RADIANS := 0.07
const BRANCH_LATERAL_SWAY_PIXELS := 5.0
const WARNING_SHADOW_Y_OFFSET := 22.0
const WARNING_LABEL_Y_OFFSET := 338.0
const WARNING_LABEL_SIZE := Vector2(224.0, 66.0)
const LANE_X := [105.0, 270.0, 435.0, 600.0, 765.0]
const ACORN_COLORS := [Color("#bb7136"), Color("#c94838"), Color("#8064a8"), Color("#e3ae35")]
const ACORN_NAMES := ["Oak", "Redcap", "Striped", "Gold"]
const PINECONE_NAMES := ["Ponderosa", "Sugar Pine", "Spruce", "Fir"]
const TITLE_CTA := "TAP TO PLAY"

const UI_LEAF_HEADING_SIZE := 74.0
const UI_LEAF_BUTTON_SIZE := 42.0
const UI_LEAF_RESULT_SIZE := 70.0
const UI_LEAF_GEAR_SIZE := 30.0
const NIGHT_BASE_VISIBILITY := 0.24
const FIREFLY_LIGHT_RADIUS := 520.0
const FIREFLY_STAGGER_Y := [350.0, 470.0, 390.0, 530.0, 430.0]
var screen := "title"
var level_number := 1
var map_page := 1
var definition: Dictionary = {}
var logic := GameLogic.new()
var events: Array = []
var drops: Array = []
var particles: Array = []
var elapsed := 0.0
var event_cursor := 0
var schedule_seed := 0
var schedule_cycle := 0
var scheduled_tail: Array = []
var player_lane := 2
var player_x := LANE_X[2]
var player_target_x := player_x
var squirrel: AnimatedSprite2D
var title_squirrel: Sprite2D
var results_squirrel: Sprite2D
var carry_sprites: Array[Sprite2D] = []
var sheet: Texture2D
var background: Texture2D
var trail_backgrounds: Array[Texture2D] = []
var item_textures: Dictionary = {}
var hazard_texture: Texture2D
var branch_texture: Texture2D
var leaf_texture: Texture2D
var yellow_leaf_texture: Texture2D
var needle_texture: Texture2D
var play_limb_texture: Texture2D
var hawk_texture: Texture2D
var owl_texture: Texture2D
var lightning_fx_texture: Texture2D
var firefly_swarm_texture: Texture2D
var title_squirrel_texture: Texture2D
var results_squirrel_texture: Texture2D
var bark_texture: Texture2D
var pause_log_texture: Texture2D
var moss_texture: Texture2D
var leaf_button_texture: Texture2D
var lightning_flash := 0.0
var save_data := {"version": 1, "unlocked": 1, "ratings": {}, "music": true, "sfx": true, "haptics": true}
var ui_leaf_green_texture: Texture2D
var ui_leaf_amber_texture: Texture2D
var paused := false
var recover_phase := 0
var recover_time := 0.0
var status_text := ""
var status_time := 0.0
var rng := RandomNumberGenerator.new()
var audio_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var audio_bank: NutsProceduralAudio
var idle_time := 0.0
var crossing_time := 0.0
var crossing_target_page := 1
var crossing_start_page := 1
var mouse_left_down := false

func _ready() -> void:
    rng.seed = 84519
    background = load("res://assets/art/forest_background.png")
    trail_backgrounds = [load("res://assets/art/seasonal/tree_trail_real_v1.png"), load("res://assets/art/seasonal/tree_trail_real_v2.png"), load("res://assets/art/seasonal/tree_trail_real_v3.png"), load("res://assets/art/seasonal/tree_trail_real_v4.png"), load("res://assets/art/seasonal/tree_trail_real_v5.png")]
    item_textures = {
        "acorn": load("res://assets/art/items/acorn_strip.png"),
        "pinecone": load("res://assets/art/items/pinecone_strip.png")
    }
    hazard_texture = load("res://assets/art/items/seasonal_hazards.png")
    branch_texture = load("res://assets/art/items/branch_clean_v1.png")
    leaf_texture = load("res://assets/art/items/leaf_strip.png")
    yellow_leaf_texture = load("res://assets/art/items/leaf_yellow_clean_v1.png")
    needle_texture = load("res://assets/art/items/pine_needle_cluster_v1.png")
    play_limb_texture = load("res://assets/art/canopy/play_limb_v1.png")
    hawk_texture = load("res://assets/art/canopy/hawk_swoop_v1.png")
    owl_texture = load("res://assets/art/canopy/owl_swoop_v1.png")
    lightning_fx_texture = load("res://assets/art/canopy/lightning_fx_v1.png")
    firefly_swarm_texture = load("res://assets/art/canopy/firefly_swarm_v1.png")
    title_squirrel_texture = load("res://assets/art/squirrel_front_acorn_v1.png")
    results_squirrel_texture = load("res://assets/art/squirrel_idle_full_v2.png")
    bark_texture = load("res://assets/art/ui_textures/oak_bark_tile_v1.png")
    pause_log_texture = load("res://assets/art/ui_textures/pause_log_v1.png")
    moss_texture = load("res://assets/art/ui_textures/moss_panel_tile_v1.png")
    leaf_button_texture = load("res://assets/art/ui_textures/leaf_button_plaque_v1.png")
    ui_leaf_green_texture = load("res://assets/art/ui_textures/ui_leaf_green_v1.png")
    ui_leaf_amber_texture = load("res://assets/art/ui_textures/ui_leaf_amber_v1.png")
    _load_save()
    _make_squirrel()
    _make_audio()
    queue_redraw()

func _make_audio() -> void:
    audio_bank = NutsProceduralAudio.new()
    audio_player = AudioStreamPlayer.new()
    music_player = AudioStreamPlayer.new()
    audio_player.bus = &"Master"
    music_player.bus = &"Master"
    add_child(audio_player)
    add_child(music_player)
    music_player.stream = audio_bank.music_loop()
    _apply_audio_settings()

func _apply_audio_settings() -> void:
    if bool(save_data.music):
        if not music_player.playing: music_player.play()
    else:
        music_player.stop()

func _play_sfx(kind: String) -> void:
    if bool(save_data.sfx):
        audio_player.stream = audio_bank.cue(kind)
        audio_player.play()

func _make_squirrel() -> void:
    squirrel = AnimatedSprite2D.new()
    squirrel.name = "SquirrelAnimatedSprite"
    squirrel.position = Vector2(player_x, SQUIRREL_Y)
    squirrel.scale = Vector2.ONE * SQUIRREL_BASE_SCALE
    squirrel.centered = true
    sheet = load("res://assets/art/squirrel_sheet_packed.png")
    if sheet == null:
        sheet = load("res://assets/art/squirrel_reference.png")
    var frames := SpriteFrames.new()
    for animation in ["idle", "run_left", "run_right", "flatten", "pop"]:
        frames.add_animation(animation)
        frames.set_animation_speed(animation, 8.0 if animation.begins_with("run") else 5.0)
        frames.set_animation_loop(animation, animation != "flatten" and animation != "pop")
        # Both directions use the intact left-run cells. Rightward motion
        # mirrors them at runtime; the old right-run source has clipped tails.
        var indexes := [8] if animation == "idle" else [0, 1, 2, 3] if animation == "run_left" else [0, 1, 2, 3] if animation == "run_right" else [9, 10] if animation == "flatten" else [9, 11, 8]
        for index in indexes:
            frames.add_frame(animation, _sheet_frame(index))
    squirrel.sprite_frames = frames
    squirrel.animation = "idle"
    squirrel.play()
    add_child(squirrel)
    # These are deliberately separate children, added after the squirrel, so the
    # collected stack sits in front of the paws instead of being hidden by it.
    for slot in 5:
        var carried := Sprite2D.new()
        carried.name = "CarriedItem%d" % slot
        carried.visible = false
        carried.z_index = 2
        add_child(carried)
        carry_sprites.append(carried)
    title_squirrel = Sprite2D.new()
    title_squirrel.name = "TitleFrontSquirrel"
    title_squirrel.texture = title_squirrel_texture
    title_squirrel.centered = true
    title_squirrel.position = TITLE_SQUIRREL_POSITION
    title_squirrel.scale = Vector2.ONE * TITLE_SQUIRREL_SCALE
    title_squirrel.z_index = 1
    title_squirrel.visible = false
    add_child(title_squirrel)
    # The packed pop frames have baked-in clipped ears. Results uses the dedicated
    # full-ear celebratory artwork instead, while gameplay retains its own sheet.
    results_squirrel = Sprite2D.new()
    results_squirrel.name = "ResultsCelebrationSquirrel"
    results_squirrel.texture = results_squirrel_texture
    results_squirrel.centered = true
    results_squirrel.position = RESULTS_SQUIRREL_POSITION
    results_squirrel.scale = Vector2.ONE * RESULTS_SQUIRREL_SCALE
    results_squirrel.z_index = 1
    results_squirrel.visible = false
    add_child(results_squirrel)

func _sheet_frame(index: int) -> Texture2D:
    if sheet == null: return null
    var atlas := AtlasTexture.new()
    atlas.atlas = sheet
    var cell := Vector2i(sheet.get_width() / 4, sheet.get_height() / 3)
    atlas.region = Rect2i((index % 4) * cell.x, (index / 4) * cell.y, cell.x, cell.y)
    return atlas

func _process(delta: float) -> void:
    _update_map_crossing(delta)
    if crossing_time <= 0.0:
        _apply_screen_squirrel()
    if status_time > 0.0:
        status_time -= delta
    if screen == "play" and not paused:
        _update_play(delta)
    elif screen == "recover":
        _update_recovery(delta)
    _update_particles(delta)
    _update_carry_stack()
    queue_redraw()

func _update_map_crossing(delta: float) -> void:
    if crossing_time <= 0.0:
        return
    crossing_time = maxf(0.0, crossing_time - delta)
    var progress := 1.0 - crossing_time / 0.6
    var path := _map_crossing_path(crossing_target_page > crossing_start_page)
    squirrel.visible = true
    squirrel.position = path[0].bezier_interpolate(path[1], path[2], path[3], progress)
    squirrel.scale = Vector2.ONE * SQUIRREL_BASE_SCALE * 0.42
    var tangent := path[0].bezier_derivative(path[1], path[2], path[3], progress)
    squirrel.rotation = clampf(tangent.angle() * 0.16, -0.12, 0.12)
    squirrel.flip_h = crossing_target_page > crossing_start_page
    squirrel.play("run_right" if crossing_target_page > crossing_start_page else "run_left")
    if crossing_time <= 0.0:
        map_page = crossing_target_page
        squirrel.visible = false

func _begin_tree_crossing(target_page: int) -> void:
    if target_page == map_page:
        return
    if target_page < 1 or target_page > MAP_PAGE_COUNT:
        return
    if target_page > map_page and int(save_data.unlocked) < _map_page_first(target_page):
        return
    crossing_start_page = map_page
    crossing_target_page = target_page
    crossing_time = 0.6

func _map_crossing_path(forward: bool) -> PackedVector2Array:
    # A short natural bough leaves the current tree at the canopy edge. The
    # page changes only after the squirrel reaches the neighboring tree.
    if forward:
        return PackedVector2Array([Vector2(690, 344), Vector2(790, 278), Vector2(938, 286), Vector2(1110, 246)])
    return PackedVector2Array([Vector2(390, 344), Vector2(290, 278), Vector2(142, 286), Vector2(-30, 246)])

func _map_page_first(page: int) -> int:
    return (page - 1) * MAP_PAGE_LEVELS + 1

func _map_can_navigate(direction: int) -> bool:
    var target := map_page + direction
    if target < 1 or target > MAP_PAGE_COUNT:
        return false
    return direction < 0 or int(save_data.unlocked) >= _map_page_first(target)

func _apply_screen_squirrel() -> void:
    if title_squirrel != null:
        title_squirrel.visible = screen == "title"
    if results_squirrel != null:
        results_squirrel.visible = screen == "results"
        results_squirrel.position = RESULTS_SQUIRREL_POSITION
        results_squirrel.scale = Vector2.ONE * RESULTS_SQUIRREL_SCALE
        results_squirrel.rotation = 0.0
    if screen == "title":
        squirrel.visible = false
    elif screen == "results":
        # Never show the clipped sheet animation behind the repair artwork.
        squirrel.visible = false
    else:
        squirrel.visible = screen == "play" or screen == "recover"

func _update_play(delta: float) -> void:
    lightning_flash = maxf(0.0, lightning_flash - delta)
    elapsed += delta
    if event_cursor >= events.size():
        _queue_continuation_cycle()
    while event_cursor < events.size() and float(events[event_cursor].time) <= elapsed:
        _spawn_event(events[event_cursor])
        event_cursor += 1
    if event_cursor >= events.size():
        _queue_continuation_cycle()
    player_x = move_toward(player_x, player_target_x, delta * 1320.0)
    if absf(player_x - player_target_x) > 12.0:
        _reset_squirrel_visual()
        squirrel.flip_h = player_target_x > player_x
        squirrel.play("run_left" if player_target_x < player_x else "run_right")
    else:
        if squirrel.animation != "idle": squirrel.play("idle")
        squirrel.flip_h = player_lane == 4
        _apply_idle_visual(delta)
    for drop in drops.duplicate():
        _move_drop(drop, delta)
        if (drop.kind == "limb" or drop.kind == "predator") and drop.phase == "falling" and _limb_hits_player(drop):
            _limb_hit(drop)
            return
        if drop.kind == "acorn" or drop.kind == "leaf":
            if drop.y > _catch_y() - 90.0 and drop.y < _catch_y() + 90.0 and absf(drop.x - player_x) < 79.0:
                _catch(drop)
                drops.erase(drop)
        elif drop.y > H + 170.0:
            drops.erase(drop)
    _ensure_next_target()

func _update_recovery(delta: float) -> void:
    recover_time += delta
    if recover_phase == 0:
        # Let the impact clip reach its fully flattened final frame first.
        if squirrel.frame >= squirrel.sprite_frames.get_frame_count("flatten") - 1:
            recover_phase = 1
            recover_time = 0.0
    elif recover_phase == 1 and recover_time >= FLATTEN_HOLD_SECONDS:
        # The final flattened frame now remains on screen for a readable 1.5 s hold.
        recover_phase = 2
        recover_time = 0.0
        _reset_squirrel_visual()
        squirrel.play("pop")
        status_text = "Shake it off!"
    elif recover_phase == 2 and recover_time >= POP_RECOVERY_SECONDS:
        screen = "play"
        recover_phase = 0
        recover_time = 0.0
        _reset_schedule()
        drops.clear()
        logic.reset_after_limb()
        _reset_squirrel_visual()
        squirrel.play("idle")
        status_text = "Try again!"
        status_time = 1.2

func _move_drop(drop: Dictionary, delta: float) -> void:
    drop.age += delta
    if drop.kind == "gust":
        if drop.phase == "warning" and drop.age >= drop.warning:
            _resolve_gust(int(drop.direction)); drop.phase = "active"; drop.age = 0.0
        elif drop.phase == "active" and drop.age >= drop.duration: drop.y = H + 200.0
        return
    if drop.kind == "lightning":
        if drop.phase == "warning" and drop.age >= drop.warning:
            lightning_flash = drop.duration; drop.phase = "active"; drop.age = 0.0
        elif drop.phase == "active" and drop.age >= drop.duration: drop.y = H + 200.0
        return
    if drop.kind == "predator":
        if drop.phase == "warning":
            drop.y = lerpf(-120.0, 220.0, clampf(drop.age / drop.warning, 0.0, 1.0))
            drop.x = drop.base_x
            if drop.age >= drop.warning: drop.phase = "falling"; drop.age = 0.0
        elif drop.phase == "falling": drop.y += drop.speed * delta
        return
    if drop.kind == "limb":
        if drop.phase == "warning":
            drop.shadow = minf(1.0, drop.age / drop.warning)
            if drop.age >= drop.warning:
                drop.phase = "falling"
                drop.age = 0.0
            return
        drop.y += drop.speed * delta * (1.0 + drop.age * 0.32)
        if str(drop.skin) == "icicle":
            # The source cell narrows toward its bottom edge, so zero rotation is
            # point-down. Keep its fall vertical with only a small returning sway.
            drop.rotation = ICICLE_BASE_ROTATION + sin(drop.age * 2.8 + drop.seed) * ICICLE_WOBBLE_RADIANS
        else:
            # The branch asset is horizontal at zero rotation. A heavy limb only
            # rocks a little while falling; it never tumbles end-over-end.
            drop.rotation = BRANCH_BASE_ROTATION + sin(drop.age * 2.15 + drop.seed) * BRANCH_WOBBLE_RADIANS
        drop.x = drop.base_x + sin(drop.age * 2.4 + drop.seed) * (BRANCH_LATERAL_SWAY_PIXELS if str(drop.skin) == "branch" else 18.0)
    elif drop.kind == "leaf":
        drop.y += drop.speed * delta
        drop.rotation += delta * (2.4 + drop.wobble)
        drop.x = drop.base_x + sin(drop.age * 5.2 + drop.seed) * 54.0
        drop.scale = 0.82 + sin(drop.age * 6.0 + drop.seed) * 0.16
    else:
        drop.y += drop.speed * delta * (1.0 + minf(drop.age * 0.028, 0.26))
        drop.rotation += delta * (1.7 + drop.wobble)
        drop.x = drop.base_x + sin(drop.age * 2.2 + drop.seed) * 20.0
        drop.bob = sin(drop.age * 4.4 + drop.seed) * 5.0

func _spawn_event(event: Dictionary) -> void:
    if event.kind == "gust" or event.kind == "lightning":
        drops.append({"kind":event.kind, "phase":"warning", "warning":float(event.warning), "duration":float(event.duration), "direction":int(event.get("direction", 0)), "variant":int(event.get("variant", 0)), "age":0.0, "y":-120.0})
        return
    var lane: int = event.lane
    var base_x: float = LANE_X[lane]
    var drop := {"kind": event.kind, "family": event.get("family", definition.theme.family), "skin": event.get("skin", ""), "variant": int(event.get("variant", -1)), "lane": lane, "base_x": base_x, "x": base_x,
        "y": -120.0, "speed": float(event.speed), "rotation": 0.0, "wobble": rng.randf_range(-0.45, 0.45),
        "seed": rng.randf_range(0.0, 9.0), "age": 0.0, "scale": 1.0, "bob": 0.0,
        "phase": "warning", "warning": float(event.get("warning", 0.0)), "width": int(event.get("width", 1)), "shadow": 0.0}
    if drop.kind != "limb" and drop.kind != "predator": drop.phase = "falling"
    drops.append(drop)

func _resolve_gust(direction: int) -> void:
    for falling in drops:
        if not _gust_eligible(falling, direction):
            continue
        var next_lane := int(falling.lane) + direction
        falling.lane = next_lane
        falling.base_x = LANE_X[next_lane]
        falling.x = falling.base_x

func _gust_eligible(drop: Dictionary, direction: int) -> bool:
    if abs(direction) != 1:
        return false
    if str(drop.get("kind", "")) != "acorn" and str(drop.get("kind", "")) != "leaf":
        return false
    if str(drop.get("phase", "falling")) != "falling":
        return false
    var next_lane := int(drop.get("lane", -1)) + direction
    return next_lane >= 0 and next_lane < LANE_X.size()

func _ensure_next_target() -> void:
    # Every authored cycle contains the complete recipe mix. Missing anything
    # is harmless because the current target recurs in the next cycle; never
    # replace the stream with target-only drops after a long dodge.
    if logic.progress >= logic.recipe.size(): return

func _reset_schedule() -> void:
    events = definition.events.duplicate(true)
    elapsed = 0.0
    event_cursor = 0
    schedule_cycle = 0
    scheduled_tail = definition.events.duplicate(true)

func _queue_continuation_cycle() -> void:
    schedule_cycle += 1
    var continuation := LevelData.make_continuation(definition, schedule_seed, schedule_cycle, scheduled_tail)
    events.append_array(continuation)
    scheduled_tail = continuation.duplicate(true)
    # Events before the cursor have already spawned. Keep only future events
    # so an extended dodge cannot grow stale timeline data without bound.
    if event_cursor > 48:
        events = events.slice(event_cursor)
        event_cursor = 0

func _replacement_lane() -> int:
    # Prefer a lane whose speed-aware arrival time does not coincide with an active acorn.
    var replacement_eta := LevelData.SPAWN_TO_CATCH_DISTANCE / float(definition.base_speed)
    var window := LevelData.acorn_arrival_safety_window(level_number)
    for offset in range(5):
        var lane := (player_lane + 2 + offset) % 5
        var clear := true
        for drop in drops:
            if drop.kind != "acorn" or drop.lane != lane:
                continue
            var active_eta := maxf(0.0, (_catch_y() - float(drop.y)) / maxf(1.0, float(drop.speed)))
            if absf(active_eta - replacement_eta) < window:
                clear = false
                break
        if clear:
            return lane
    return (player_lane + 2) % 5

func _catch(drop: Dictionary) -> void:
    var outcome := logic.catch_object(drop.kind, drop.variant)
    if outcome == "correct":
        _play_sfx("catch")
        _feedback("Nice! " + _item_name(drop.variant), Color("#fff3bd"))
        _spark(Vector2(drop.x, _catch_y()), ACORN_COLORS[drop.variant], 10)
        _haptic(18)
    elif outcome == "complete":
        _play_sfx("catch")
        _finish_level()
    elif outcome == "wrong":
        _play_sfx("wrong")
        _feedback("Oops - one nut slipped away", Color("#ffd1ae"))
        _spark(Vector2(drop.x, _catch_y()), Color("#d85840"), 8)
        _haptic(45)
    _update_carry_stack()

func _limb_hits_player(drop: Dictionary) -> bool:
    if str(drop.get("phase", "falling")) != "falling":
        return false
    var half_width := 72.0 + 74.0 * float(int(drop.get("width", 1)) - 1)
    return drop.y > _catch_y() - 100.0 and drop.y < _catch_y() + 85.0 and absf(drop.x - player_x) < half_width

func _limb_is_visible(drop: Dictionary) -> bool:
    return str(drop.get("phase", "warning")) == "falling"

func _limb_hit(drop: Dictionary) -> void:
    drops.clear()
    for i in 22:
        particles.append({"p": Vector2(player_x, _catch_y()), "v": Vector2(rng.randf_range(-390,390), rng.randf_range(-380,-80)), "life": rng.randf_range(0.45, 0.95), "color": Color("#8d5533")})
    logic.catch_object("limb", -1)
    _reset_squirrel_visual()
    squirrel.play("flatten")
    screen = "recover"
    recover_phase = 0
    recover_time = 0.0
    _feedback("WING HIT!" if str(drop.get("kind", "limb")) == "predator" else "TIMBER!", Color("#fff0bd"))
    _play_sfx("limb")
    _haptic(120)
    _update_carry_stack()

func _finish_level() -> void:
    var stars := logic.stars()
    var key := str(level_number)
    save_data.ratings[key] = max(int(save_data.ratings.get(key, 0)), stars)
    save_data.unlocked = min(LevelData.MAX_LEVEL, max(int(save_data.unlocked), level_number + 1))
    _save()
    screen = "results"
    drops.clear()
    _reset_squirrel_visual()
    squirrel.play("pop")
    _feedback("Recipe complete!", Color("#fff4ad"))
    _spark(Vector2(player_x, _catch_y()), Color("#ffe58b"), 24)
    _haptic(45)
    _update_carry_stack()

func _start_level(number: int) -> void:
    level_number = clampi(number, 1, LevelData.MAX_LEVEL)
    definition = LevelData.make(level_number, 7000 + level_number * 31)
    background = _background_for(str(definition.theme.background))
    logic.begin(definition.recipe, 7000 + level_number * 31)
    schedule_seed = 7000 + level_number * 31
    drops.clear()
    particles.clear()
    lightning_flash = 0.0
    _reset_schedule()
    player_lane = 2
    player_x = LANE_X[2]
    player_target_x = player_x
    _reset_squirrel_visual()
    squirrel.play("idle")
    paused = false
    map_page = clampi(int((level_number - 1) / MAP_PAGE_LEVELS) + 1, 1, MAP_PAGE_COUNT)
    screen = "play"
    _feedback("Level %d: %s" % [level_number, definition.name], Color("#fff1bb"))
    status_time = 1.8

func _feedback(message: String, color: Color) -> void:
    status_text = message
    status_time = 1.35

func _haptic(milliseconds: int) -> void:
    if bool(save_data.haptics):
        Input.vibrate_handheld(milliseconds)

func _spark(origin: Vector2, color: Color, count: int) -> void:
    for i in count:
        particles.append({"p": origin, "v": Vector2(rng.randf_range(-250,250), rng.randf_range(-300,-50)), "life": rng.randf_range(0.3,0.8), "color": color})

func _update_particles(delta: float) -> void:
    for particle in particles.duplicate():
        particle.life -= delta
        particle.v.y += 620.0 * delta
        particle.p += particle.v * delta
        if particle.life <= 0.0: particles.erase(particle)

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("move_left") and screen == "play": _set_lane(player_lane - 1)
    if event.is_action_pressed("move_right") and screen == "play": _set_lane(player_lane + 1)
    if event.is_action_pressed("pause") and screen == "play": paused = not paused
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        mouse_left_down = event.pressed
    var press: bool = event is InputEventScreenTouch and event.pressed
    var drag: bool = event is InputEventScreenDrag
    var mouse: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
    var mouse_drag: bool = event is InputEventMouseMotion and mouse_left_down
    if press or drag or mouse or mouse_drag:
        var point: Vector2 = event.position
        if screen == "map" and crossing_time > 0.0:
            return
        if screen == "play":
            if paused:
                _pause_click(point)
            elif PAUSE_RECT.has_point(point):
                paused = true
                _play_sfx("button")
            else:
                _set_lane(clampi(roundi((point.x - LANE_X[0]) / 165.0), 0, 4))
        elif screen == "title":
            screen = "map"
        elif screen == "map":
            _map_click(point)
        elif screen == "results":
            _results_click(point)
        elif screen == "settings":
            _settings_click(point)
        queue_redraw()

func _set_lane(next_lane: int) -> void:
    player_lane = clampi(next_lane, 0, 4)
    player_target_x = LANE_X[player_lane]

func _item_name(variant: int) -> String:
    return PINECONE_NAMES[variant] if definition.get("theme", {}).get("family", "acorn") == "pinecone" else ACORN_NAMES[variant]

func _background_for(background_id: String) -> Texture2D:
    var paths := {
        "spring_oak": "res://assets/art/seasonal/spring_oak.png",
        "summer_oak": "res://assets/art/forest_background.png",
        "autumn_oak": "res://assets/art/seasonal/autumn_oak.png",
        "pine_grove": "res://assets/art/seasonal/pine_grove.png",
        "winter_pine": "res://assets/art/seasonal/winter_pine.png",
        "high_canopy_day": "res://assets/art/seasonal/high_canopy_day_v1.png", "high_canopy_night": "res://assets/art/seasonal/high_canopy_night_v1.png",
        "high_canopy_storm": "res://assets/art/seasonal/high_canopy_storm_v1.png"
    }
    return load(paths.get(background_id, paths.summer_oak))

func _play_surface_y() -> float:
    return GROUND_LINE_Y + _branch_y_offset()

func _catch_y() -> float:
    return _play_surface_y() - (GROUND_LINE_Y - FLOOR_Y)

func _firefly_centers() -> Array[Vector2]:
    var centers: Array[Vector2] = []
    for lane in LANE_X.size():
        var phase := float(lane) * 1.43
        var x: float = LANE_X[lane] + sin(elapsed * (1.0 + lane * 0.07) + phase) * 34.0 + sin(elapsed * 2.37 + phase * 0.61) * 12.0
        var y: float = FIREFLY_STAGGER_Y[lane] + cos(elapsed * (1.18 + lane * 0.05) + phase) * 42.0 + sin(elapsed * 0.63 + phase * 0.47) * 18.0
        var lane_left: float = 70.0 if lane == 0 else (LANE_X[lane - 1] + LANE_X[lane]) * 0.5 + 12.0
        var lane_right: float = PLAY_RIGHT - 70.0 if lane == LANE_X.size() - 1 else (LANE_X[lane] + LANE_X[lane + 1]) * 0.5 - 12.0
        centers.append(Vector2(clampf(x, lane_left, lane_right), clampf(y, SAFE_TOP + 150.0, 900.0)))
    return centers

func _night_visibility_at(point: Vector2) -> float:
    var theme: Dictionary = definition.get("theme", {})
    if not bool(theme.get("night", false)) and not bool(theme.get("lightning", false)):
        return 1.0
    if lightning_flash > 0.0:
        return 1.0
    var visibility := NIGHT_BASE_VISIBILITY
    if not bool(theme.get("fireflies", false)):
        return visibility
    for light_center in _firefly_centers():
        var proximity := 1.0 - clampf(point.distance_to(light_center) / FIREFLY_LIGHT_RADIUS, 0.0, 1.0)
        var smooth_light := proximity * proximity * (3.0 - 2.0 * proximity)
        visibility = maxf(visibility, lerpf(NIGHT_BASE_VISIBILITY, 1.0, smooth_light))
    return visibility

func _night_world_modulate(point: Vector2) -> Color:
    var visibility := _night_visibility_at(point)
    return Color(visibility, minf(1.0, visibility * 1.04), minf(1.0, visibility * 1.16), 1.0)

func _lightning_warning_strength() -> float:
    var strength := 0.0
    for drop in drops:
        if str(drop.get("kind", "")) != "lightning" or str(drop.get("phase", "")) != "warning":
            continue
        var warning := maxf(0.001, float(drop.get("warning", 1.0)))
        strength = maxf(strength, clampf(float(drop.get("age", 0.0)) / warning, 0.0, 1.0))
    return strength

func _draw_firefly_lighting() -> void:
    var centers := _firefly_centers()
    for i in centers.size():
        var p: Vector2 = centers[i]
        var pulse := 0.5 + 0.5 * sin(elapsed * 2.8 + i * 1.9)
        # Draw only the painted swarm; illumination is applied to falling sprites by distance.
        if firefly_swarm_texture != null:
            var fx_size := Vector2.ONE * (156.0 + pulse * 12.0)
            draw_set_transform(p, sin(elapsed * 0.7 + i) * 0.055)
            draw_texture_rect(firefly_swarm_texture, Rect2(-fx_size * 0.5, fx_size), false, Color(1.0, 1.0, 1.0, 0.64 + pulse * 0.18))
            draw_set_transform(Vector2.ZERO)
        else:
            draw_circle(p, 9.0, Color("#f4ffac", 0.92))

func _lightning_layout_variant() -> int:
    for drop in drops:
        if str(drop.get("kind", "")) == "lightning":
            return posmod(int(drop.get("variant", 0)), 3)
    return 0

func _lightning_bolt_rects() -> Array[Rect2]:
    match _lightning_layout_variant():
        1:
            return [Rect2(270.0, SAFE_TOP + 20.0, 480.0, 930.0), Rect2(30.0, SAFE_TOP + 300.0, 300.0, 560.0)]
        2:
            return [Rect2(145.0, SAFE_TOP + 20.0, 480.0, 930.0), Rect2(5.0, SAFE_TOP + 220.0, 290.0, 600.0), Rect2(500.0, SAFE_TOP + 260.0, 270.0, 560.0)]
        _:
            return [Rect2(20.0, SAFE_TOP + 30.0, 470.0, 920.0), Rect2(430.0, SAFE_TOP + 250.0, 310.0, 590.0)]

func _draw_lightning_vfx() -> void:
    var warning_strength := _lightning_warning_strength()
    var flash_strength := clampf(lightning_flash * 4.6, 0.0, 1.0)
    if warning_strength <= 0.0 and flash_strength <= 0.0:
        return
    # Ghosted multi-bolt layouts silently telegraph each harmless reveal.
    if lightning_fx_texture != null:
        var variant: int = _lightning_layout_variant()
        var bolt_alpha := maxf(warning_strength * (0.13 + 0.05 * sin(elapsed * 12.0)), flash_strength * 0.88)
        var bolt_rects: Array[Rect2] = _lightning_bolt_rects()
        for bolt_index in bolt_rects.size():
            var bolt_rect: Rect2 = bolt_rects[bolt_index]
            var mirror_x: float = -1.0 if (bolt_index + variant) % 2 == 1 else 1.0
            var bolt_rotation: float = (-0.07 + bolt_index * 0.09) * (-1.0 if variant == 1 else 1.0)
            var copy_alpha: float = bolt_alpha * (1.0 - float(bolt_index) * 0.16)
            draw_set_transform(bolt_rect.get_center(), bolt_rotation, Vector2(mirror_x, 1.0))
            draw_texture_rect(lightning_fx_texture, Rect2(-bolt_rect.size * 0.5, bolt_rect.size), false, Color(0.86, 0.94, 1.0, copy_alpha))
            draw_set_transform(Vector2.ZERO)
    if flash_strength > 0.0:
        draw_rect(Rect2(0, SAFE_TOP, PLAY_RIGHT, H - SAFE_TOP), Color(0.88, 0.95, 1.0, 0.18 + flash_strength * 0.42))

func _finale_stage_label() -> String:
    if level_number != LevelData.MAX_LEVEL:
        return ""
    var stage := clampi(logic.progress + 1, 1, logic.recipe.size())
    return "FINALE PHASE %d / %d" % [stage, logic.recipe.size()]

func _branch_y_offset() -> float:
    return sin(elapsed * 1.65) * 16.0 if str(definition.get("theme", {}).get("branch_mode", "stationary")) == "sway" else 0.0

func _reset_squirrel_visual() -> void:
    idle_time = 0.0
    squirrel.position = Vector2(player_x, _play_surface_y() - SQUIRREL_FOOT_OFFSET)
    squirrel.scale = Vector2.ONE * SQUIRREL_BASE_SCALE
    squirrel.rotation = 0.0

func _apply_idle_visual(delta: float) -> void:
    idle_time += delta
    var breath := 1.0 + sin(idle_time * IDLE_BREATH_SPEED) * IDLE_BREATH_SCALE
    squirrel.scale = Vector2.ONE * SQUIRREL_BASE_SCALE * breath
    squirrel.position = Vector2(player_x, _play_surface_y() - SQUIRREL_FOOT_OFFSET + sin(idle_time * IDLE_SWAY_SPEED) * IDLE_BOB_PIXELS)
    squirrel.rotation = sin(idle_time * IDLE_SWAY_SPEED) * IDLE_SWAY_RADIANS

func _retry_level() -> void:
    _start_level(level_number)

func _pause_click(point: Vector2) -> void:
    if PAUSE_BUTTON_RECTS[0].has_point(point):
        paused = false
    elif PAUSE_BUTTON_RECTS[1].has_point(point):
        _retry_level()
    elif PAUSE_BUTTON_RECTS[2].has_point(point):
        paused = false
        screen = "map"
    _play_sfx("button")

func _results_click(point: Vector2) -> void:
    if RESULTS_BUTTON_RECTS[0].has_point(point) and level_number < LevelData.MAX_LEVEL:
        _start_level(level_number + 1)
    elif RESULTS_BUTTON_RECTS[1].has_point(point):
        _retry_level()
    elif RESULTS_BUTTON_RECTS[2].has_point(point):
        screen = "map"
    _play_sfx("button")

func _settings_click(point: Vector2) -> void:
    if Rect2(175, 620, 730, 76).has_point(point):
        save_data.music = not bool(save_data.music)
        _apply_audio_settings()
    elif Rect2(175, 725, 730, 76).has_point(point):
        save_data.sfx = not bool(save_data.sfx)
    elif Rect2(175, 830, 730, 76).has_point(point):
        save_data.haptics = not bool(save_data.haptics)
    else:
        screen = "map"
    _save()
    _play_sfx("button")

func _map_click(point: Vector2) -> void:
    if Rect2(880, 92, 105, 90).has_point(point):
        screen = "settings"
        return
    if _map_can_navigate(-1) and MAP_PREVIOUS_RECT.has_point(point):
        _begin_tree_crossing(map_page - 1)
        return
    if _map_can_navigate(1) and MAP_NEXT_RECT.has_point(point):
        _begin_tree_crossing(map_page + 1)
        return
    var first := _map_page_first(map_page)
    var last: int = min(first + MAP_PAGE_LEVELS, LevelData.MAX_LEVEL + 1)
    for number in range(first, last):
        var pos := _map_node_position(number)
        if point.distance_to(pos) < MAP_NODE_RADIUS + 22.0 and number <= int(save_data.unlocked):
            _start_level(number)
            return

func _map_node_position(number: int) -> Vector2:
    var page := clampi(int((number - 1) / MAP_PAGE_LEVELS), 0, MAP_NODE_POSITIONS.size() - 1)
    var index := posmod(number - 1, MAP_PAGE_LEVELS)
    return MAP_NODE_POSITIONS[page][index]

func _draw() -> void:
    var page_background: Texture2D = trail_backgrounds[map_page - 1] if screen == "map" else background
    if page_background != null:
        draw_texture_rect(page_background, Rect2(0, 0, W, H), false, Color(1,1,1,0.72))
    draw_rect(Rect2(0,0,W,H), Color("#173f37", 0.32))
    if screen == "title": _draw_title()
    elif screen == "map": _draw_map()
    elif screen == "settings": _draw_settings()
    elif screen == "results": _draw_results()
    else: _draw_game()

func _font() -> Font:
    return ThemeDB.fallback_font

func _text(text: String, pos: Vector2, size: int, color := Color.WHITE, align := HORIZONTAL_ALIGNMENT_LEFT, width := -1.0) -> void:
    draw_string(_font(), pos, text, align, width, size, color)

func _panel(rect: Rect2, color := Color("#253d32", 0.9)) -> void:
    _draw_textured_panel(rect, color)

func _draw_textured_panel(rect: Rect2, color: Color, radius := 28) -> void:
    # Lay down a clean rounded carved frame first. Raster texture is deliberately
    # inset so its square source corners never touch the gold outer border.
    var frame := _round_box(Color("#5b3b29", 0.98), radius)
    frame.border_color = Color("#f4d98a", 0.62)
    frame.border_width_left = 4; frame.border_width_right = 4
    frame.border_width_top = 4; frame.border_width_bottom = 4
    draw_style_box(frame, rect)
    var inset := rect.grow(-17.0)
    if moss_texture != null and inset.size.x > 0.0 and inset.size.y > 0.0:
        if bark_texture != null:
            draw_texture_rect(bark_texture, inset, true, Color(1.0, 0.82, 0.63, 0.62))
        draw_texture_rect(moss_texture, inset, true, Color(0.66, 0.88, 0.62, 0.34))
        _mask_panel_texture_corners(inset, maxf(7.0, float(radius) - 11.0), Color("#5b3b29", 0.98))
    var inner := _round_box(Color(color.r, color.g, color.b, color.a * 0.54), maxi(7, radius - 11))
    inner.border_color = Color("#f4d98a", 0.18)
    inner.border_width_left = 1; inner.border_width_right = 1
    inner.border_width_top = 1; inner.border_width_bottom = 1
    draw_style_box(inner, inset)

func _mask_panel_texture_corners(rect: Rect2, corner_radius: float, color: Color) -> void:
    var centers := [rect.position + Vector2(corner_radius, corner_radius), Vector2(rect.end.x - corner_radius, rect.position.y + corner_radius), Vector2(rect.end.x - corner_radius, rect.end.y - corner_radius), Vector2(rect.position.x + corner_radius, rect.end.y - corner_radius)]
    var starts := [PI, -PI * 0.5, 0.0, PI * 0.5]
    for corner in 4:
        var pivot: Vector2 = rect.position if corner == 0 else Vector2(rect.end.x, rect.position.y) if corner == 1 else rect.end if corner == 2 else Vector2(rect.position.x, rect.end.y)
        var points := PackedVector2Array([pivot])
        for step in 9:
            var angle: float = float(starts[corner]) + step * PI * 0.5 / 8.0
            points.append(centers[corner] + Vector2(cos(angle), sin(angle)) * corner_radius)
        draw_colored_polygon(points, color)

func _round_box(color: Color, radius: int) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = color
    box.corner_radius_top_left = radius; box.corner_radius_top_right = radius
    box.corner_radius_bottom_left = radius; box.corner_radius_bottom_right = radius
    box.border_width_left = 3; box.border_width_right = 3; box.border_width_top = 3; box.border_width_bottom = 3
    box.border_color = Color("#f4d98a", 0.48)
    return box

func _draw_title() -> void:
    _draw_wood_panel(TITLE_CARD_RECT, Color("#234538", 0.91))
    _text("Nuts!", Vector2(0, 410), 164, Color("#fff1ad"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("Catch the acorns in recipe order", Vector2(0, 500), 39, Color("#fff9dd"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("Drag the squirrel through five lanes", Vector2(0, 558), 30, Color("#d8ecc8"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _draw_leaf_button(Rect2(265, 610, 550, 112), TITLE_CTA, true, Color("#b76a39"))

func _map_label_rect(position: Vector2) -> Rect2:
    var horizontal_clearance := MAP_NODE_RADIUS + MAP_LABEL_GAP
    var x := position.x - MAP_LABEL_SIZE.x - horizontal_clearance if position.x < W * 0.5 else position.x + horizontal_clearance
    return Rect2(x, position.y - MAP_LABEL_SIZE.y * 0.5, MAP_LABEL_SIZE.x, MAP_LABEL_SIZE.y)

func _map_crossing_samples(path: PackedVector2Array) -> PackedVector2Array:
    var samples := PackedVector2Array()
    for step in range(17):
        samples.append(path[0].bezier_interpolate(path[1], path[2], path[3], float(step) / 16.0))
    return samples

func _draw_map_crossing_bough() -> void:
    var samples := _map_crossing_samples(_map_crossing_path(crossing_target_page > crossing_start_page))
    if samples.is_empty():
        return
    draw_polyline(samples, Color("#493023", 0.78), 15.0, true)
    draw_polyline(samples, Color("#b17a45", 0.64), 4.0, true)

func _draw_map() -> void:
    if crossing_time > 0.0:
        _draw_map_crossing_bough()
    _draw_wood_panel(Rect2(55, SAFE_TOP, 970, 116), Color("#234238", 0.86))
    _text("TREE %d TRAIL" % map_page, Vector2(92, SAFE_TOP + 82), 49, Color("#fff0ac"))
    _text("ROOTS TO CROWN", Vector2(596, SAFE_TOP + 76), 23, Color("#d7e9cc"))
    _draw_textured_medallion(Vector2(942, 141), 38.0, true, false)
    _draw_settings_gear(Vector2(942, 141), 24.0)
    var first := _map_page_first(map_page)
    var last: int = min(first + MAP_PAGE_LEVELS, LevelData.MAX_LEVEL + 1)
    for n in range(first, last):
        var p := _map_node_position(n)
        var unlocked := n <= int(save_data.unlocked)
        var completed := int(save_data.ratings.get(str(n), 0)) > 0
        _draw_textured_medallion(p, MAP_NODE_RADIUS, unlocked, completed)
        draw_arc(p, MAP_NODE_RADIUS, 0, TAU, 32, Color("#fff0b4", 0.74), 4)
        if n == int(save_data.unlocked):
            draw_arc(p, MAP_NODE_RADIUS + 12.0 + sin(elapsed * 4.0) * 4.0, 0, TAU, 32, Color("#fff3a8", 0.88), 4)
        _text(str(n), p + Vector2(-14, 14), 40, Color.WHITE)
        var stars := int(save_data.ratings.get(str(n), 0))
        for slot in range(3):
            _draw_collectible(p + Vector2(-29 + slot * 29, 82), 0.0, slot, 0.19, "acorn", slot >= stars)
        var label_rect := _map_label_rect(p)
        _panel(label_rect, Color("#315544", 0.74))
        _text(LevelData.level_name(n), Vector2(label_rect.position.x, label_rect.position.y + 25), 19, Color("#f6f2ce"), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x)
    if _map_can_navigate(-1):
        _draw_leaf_button(MAP_PREVIOUS_RECT, "PREVIOUS TREE", true, Color("#6c8757"))
    if _map_can_navigate(1):
        _draw_leaf_button(MAP_NEXT_RECT, "NEXT TREE", true, Color("#6c8757"))

func _draw_settings() -> void:
    _draw_wood_panel(Rect2(105, 420, 870, 760))
    _text("SETTINGS", Vector2(0, 545), 70, Color("#fff0ac"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _draw_leaf_button(Rect2(175, 620, 730, 76), "MUSIC     " + ("ON" if save_data.music else "OFF"), bool(save_data.music), Color("#648957"))
    _draw_leaf_button(Rect2(175, 725, 730, 76), "SOUND EFFECTS     " + ("ON" if save_data.sfx else "OFF"), bool(save_data.sfx), Color("#648957"))
    _draw_leaf_button(Rect2(175, 830, 730, 76), "HAPTICS     " + ("ON" if save_data.haptics else "OFF"), bool(save_data.haptics), Color("#648957"))
    _text("Tap outside a switch to return", Vector2(0, 1030), 31, Color("#d5e6ca"), HORIZONTAL_ALIGNMENT_CENTER, W)

func _draw_results() -> void:
    var stars := logic.stars()
    _draw_wood_panel(RESULTS_PANEL_RECT, Color("#214337", 0.91))
    _draw_nature_heading(RESULTS_HEADER_RECT, "RECIPE COMPLETE!")
    # Keep carved grain out of the character portrait. At phone scale, a grain arc
    # behind the face/body reads as a hard horizontal cut through the squirrel.
    _draw_tree_ring(RESULTS_MEDALLION_CENTER, RESULTS_MEDALLION_RADIUS, false)
    for leaf_index in 6:
        var leaf_angle := TAU * leaf_index / 6.0 + 0.24
        var leaf_center := RESULTS_MEDALLION_CENTER + Vector2(cos(leaf_angle), sin(leaf_angle)) * (RESULTS_MEDALLION_RADIUS + 26.0)
        _draw_ui_leaf(ui_leaf_amber_texture if leaf_index % 2 == 0 else ui_leaf_green_texture, leaf_center, UI_LEAF_RESULT_SIZE, leaf_angle + 0.4)
    _draw_wood_panel(RESULTS_RIBBON_RECT, Color("#8d512f", 0.97))
    _text("LEVEL %d  •  %s" % [level_number, definition.name], Vector2(RESULTS_RIBBON_RECT.position.x, RESULTS_RIBBON_RECT.position.y + 55.0), 31, Color("#fff4cb"), HORIZONTAL_ALIGNMENT_CENTER, RESULTS_RIBBON_RECT.size.x)
    for slot in range(3):
        _draw_collectible(Vector2(430 + slot * 110, 1178), 0.0, slot, 0.58, "acorn", slot >= stars)
    _text("%d mistake%s" % [logic.mistakes, "" if logic.mistakes == 1 else "s"], Vector2(0, 1280), 32, Color("#f7dfb9"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _draw_leaf_button(RESULTS_BUTTON_RECTS[0], "NEXT LEVEL" if level_number < LevelData.MAX_LEVEL else "ALL 50 LEVELS COMPLETE", level_number < LevelData.MAX_LEVEL, Color("#ba6e3d"))
    _draw_leaf_button(RESULTS_BUTTON_RECTS[1], "RETRY LEVEL", true, Color("#9a5637"))
    _draw_leaf_button(RESULTS_BUTTON_RECTS[2], "TREE TRAIL", true, Color("#5f8958"))

func _results_squirrel_visual_rect() -> Rect2:
    # Use the repair image's real alpha footprint, never the clipped packed cells.
    if results_squirrel_texture == null:
        return Rect2()
    var source_image := results_squirrel_texture.get_image()
    if source_image == null:
        return Rect2()
    var source_size := Vector2(source_image.get_size())
    var alpha_bounds := Rect2(source_image.get_used_rect())
    var top_left := RESULTS_SQUIRREL_POSITION + (alpha_bounds.position - source_size * 0.5) * RESULTS_SQUIRREL_SCALE
    return Rect2(top_left, alpha_bounds.size * RESULTS_SQUIRREL_SCALE)

func _title_squirrel_visual_rect() -> Rect2:
    var top_left := TITLE_SQUIRREL_POSITION + (TITLE_SQUIRREL_SOURCE_BOUNDS.position - TITLE_SQUIRREL_SOURCE_SIZE * 0.5) * TITLE_SQUIRREL_SCALE
    return Rect2(top_left, TITLE_SQUIRREL_SOURCE_BOUNDS.size * TITLE_SQUIRREL_SCALE)

func _draw_game() -> void:
    var theme: Dictionary = definition.get("theme", {})
    if bool(theme.get("play_limb", false)):
        var limb_texture: Texture2D = play_limb_texture
        if limb_texture != null: draw_texture_rect(limb_texture, Rect2(0.0, _play_surface_y() - 250.0, PLAY_RIGHT, 340.0), false)
    if bool(theme.get("night", false)):
        # The painted background and play limb stay clear; only falling world
        # sprites receive distance-based night modulation in _draw_drop().
        _draw_firefly_lighting()
    _draw_lightning_vfx()
    if bool(definition.get("theme", {}).get("ambient", false)):
        _draw_ambient_snow()
    _draw_goal()
    _draw_wood_panel(Rect2(38, SAFE_TOP, 505, 94), Color("#244338",0.88))
    _text("LEVEL %d  %s" % [level_number, definition.name], Vector2(65, SAFE_TOP + 62), 31, Color("#fff0b0"))
    if not _finale_stage_label().is_empty():
        _text(_finale_stage_label(), Vector2(80, SAFE_TOP + 132), 27, Color("#fff2a6"))
    if pause_log_texture != null:
        draw_texture_rect(pause_log_texture, PAUSE_RECT, false)
    for drop in drops:
        _draw_drop(drop)
    for particle in particles:
        draw_circle(particle.p, 7.0 * particle.life + 2.0, particle.color)
    if status_time > 0.0:
        _panel(Rect2(80, 1290, 700, 90), Color("#315443",0.93))
        _text(status_text, Vector2(105, 1350), 35, Color("#fff5cc"), HORIZONTAL_ALIGNMENT_CENTER, 650)
    if paused:
        _draw_wood_panel(PAUSE_MODAL_RECT, Color("#203b34",0.96))
        _text("PAUSED", Vector2(0, 790), 72, Color("#fff0ac"), HORIZONTAL_ALIGNMENT_CENTER, W)
        _draw_leaf_button(PAUSE_BUTTON_RECTS[0], "RESUME", true, Color("#69895a"))
        _draw_leaf_button(PAUSE_BUTTON_RECTS[1], "RETRY", true, Color("#a4653b"))
        _draw_leaf_button(PAUSE_BUTTON_RECTS[2], "TREE TRAIL", true, Color("#5f8958"))

func _draw_ambient_snow() -> void:
    for i in 28:
        var x := fmod(float(i * 137) + elapsed * (18.0 + i % 4 * 7.0), PLAY_RIGHT)
        var y := fmod(float(i * 83) + elapsed * (55.0 + i % 5 * 8.0), H)
        draw_circle(Vector2(x, y), 2.0 + i % 3, Color("#eaf7ff", 0.72))

func _draw_button(rect: Rect2, label: String, enabled: bool) -> void:
    _panel(rect, Color("#c87538", 0.97) if enabled else Color("#596257", 0.92))
    _text(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.67), 29, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)

func _draw_wood_panel(rect: Rect2, color := Color("#253d32", 0.9)) -> void:
    _panel(rect, color)
    var inset := 17.0
    draw_line(Vector2(rect.position.x + inset, rect.position.y + inset), Vector2(rect.end.x - inset, rect.position.y + inset), Color("#f2d489", 0.34), 4.0)
    draw_line(Vector2(rect.position.x + inset, rect.end.y - inset), Vector2(rect.end.x - inset, rect.end.y - inset), Color("#1f3028", 0.48), 5.0)
    for ring in 3:
        var y := rect.position.y + 30.0 + ring * 19.0
        draw_arc(Vector2(rect.position.x + 56.0, y), 34.0, -1.35, 1.35, 14, Color("#c98a4a", 0.15), 2.0)
        draw_arc(Vector2(rect.end.x - 56.0, y), 34.0, PI - 1.35, PI + 1.35, 14, Color("#c98a4a", 0.15), 2.0)

func _draw_nature_heading(rect: Rect2, label: String) -> void:
    _draw_wood_panel(rect, Color("#704229", 0.98))
    _draw_ui_leaf(ui_leaf_green_texture, rect.position + Vector2(58.0, rect.size.y * 0.5), UI_LEAF_HEADING_SIZE, -0.55)
    _draw_ui_leaf(ui_leaf_amber_texture, rect.end - Vector2(58.0, rect.size.y * 0.5), UI_LEAF_HEADING_SIZE, 0.55)
    _text(label, Vector2(rect.position.x, rect.position.y + 115.0), 58, Color("#fff3b7"), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)

func _draw_tree_ring(center: Vector2, radius: float, with_inner_grain := true) -> void:
    draw_circle(center, radius + 18.0, Color("#523321", 0.98))
    draw_circle(center, radius + 11.0, Color("#73472c", 0.98))
    draw_circle(center, radius + 4.0, Color("#9a6037", 0.98))
    draw_circle(center, radius - 4.0, Color("#bd7c47", 0.98))
    draw_circle(center, radius - 20.0, Color("#d7a66a", 0.98))
    draw_circle(center + Vector2(-7.0, 6.0), radius * 0.32, Color("#e4bd81", 0.18))
    if with_inner_grain:
        for ring in [0.25, 0.46, 0.67, 0.84]:
            draw_arc(center + Vector2(-12.0, 8.0), (radius - 30.0) * ring, -2.7, 2.5, 42, Color("#805035", 0.58), 3.0)
    for notch in 16:
        var angle := TAU * notch / 16.0
        var from := center + Vector2(cos(angle), sin(angle)) * (radius - 8.0)
        var to := center + Vector2(cos(angle), sin(angle)) * (radius + 15.0)
        draw_line(from, to, Color("#6d4129", 0.88), 7.0)

func _draw_ui_leaf(texture: Texture2D, center: Vector2, size: float, rotation: float) -> void:
    if texture == null:
        return
    var aspect := float(texture.get_width()) / maxf(1.0, float(texture.get_height()))
    var leaf_size := Vector2(size * aspect, size)
    draw_set_transform(center, rotation)
    draw_texture_rect(texture, Rect2(-leaf_size * 0.5, leaf_size), false)
    draw_set_transform(Vector2.ZERO)

func _draw_leaf_button(rect: Rect2, label: String, enabled: bool, color: Color) -> void:
    var button_color := color if enabled else Color("#596257", 0.94)
    _draw_wood_panel(rect, button_color)
    if leaf_button_texture != null:
        var plaque_height := rect.size.y * 1.04
        var plaque_width := minf(rect.size.x - 16.0, plaque_height * float(leaf_button_texture.get_width()) / float(leaf_button_texture.get_height()))
        var plaque_rect := Rect2(rect.get_center() - Vector2(plaque_width, plaque_height) * 0.5, Vector2(plaque_width, plaque_height))
        draw_texture_rect(leaf_button_texture, plaque_rect, false, Color(1.0, 1.0, 1.0, 0.9 if enabled else 0.42))
    _draw_ui_leaf(ui_leaf_green_texture, rect.position + Vector2(36.0, rect.size.y * 0.5), UI_LEAF_BUTTON_SIZE, -0.55)
    _draw_ui_leaf(ui_leaf_amber_texture, rect.end - Vector2(36.0, rect.size.y * 0.5), UI_LEAF_BUTTON_SIZE, 0.55)
    _text(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.66), 29, Color.WHITE if enabled else Color("#d3d8ce"), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)

func _draw_goal() -> void:
    _draw_wood_panel(Rect2(824, 235, 228, 790), Color("#244239",0.93))
    _text("GOAL", Vector2(850, 292), 36, Color("#fff0aa"))
    for i in logic.recipe.size():
        var y := 920.0 - i * 125.0
        var state := "held" if i < logic.progress else "current" if i == logic.progress else "waiting"
        if state == "current": draw_circle(Vector2(938,y), 56 + sin(elapsed*5.0)*5.0, Color("#fff2a8",0.24))
        _draw_collectible(Vector2(938,y), 0.0, logic.recipe[i], 0.72, str(definition.get("theme", {}).get("family", "acorn")), state == "held")
        _text(str(i+1), Vector2(850,y+12), 25, Color.WHITE)

func _update_carry_stack() -> void:
    var family := str(definition.get("theme", {}).get("family", "acorn"))
    var texture: Texture2D = item_textures.get(family)
    if texture == null:
        for carried in carry_sprites:
            carried.visible = false
            carried.texture = null
        return
    for i in carry_sprites.size():
        var carried := carry_sprites[i]
        var show_play_stack := i < logic.progress and i < logic.recipe.size() and screen == "play"
        var show_results_stack := i < logic.recipe.size() and screen == "results"
        carried.visible = show_play_stack or show_results_stack
        if not carried.visible:
            continue
        var wobble := sin(elapsed * 5.0 + i * 1.7) * 0.11
        if screen == "results":
            # The completed recipe rests on the celebratory raised paw. It remains
            # in front of the repair sprite, with a small alternating lean instead of
            # cutting through the face or the carved heading.
            var result_offset := Vector2((i % 2) * 10.0 - 4.0, -i * RESULTS_CARRY_STEP_Y)
            carried.position = RESULTS_CARRY_ANCHOR + result_offset
            carried.rotation = wobble + (-0.08 if i % 2 == 0 else 0.08)
        else:
            # Attach to the raised paw-side, not the face. On lane 4 the stack
            # mirrors inward, preserving the goal rail and the squirrel's eye.
            var side := -1.0 if player_lane == 4 else 1.0
            var offset := Vector2(side * (76.0 + (i % 2) * 11.0), -56.0 - i * 42.0)
            carried.position = Vector2(player_x, _play_surface_y() - SQUIRREL_FOOT_OFFSET) + offset
            carried.rotation = wobble * side
        # Source strips are deliberately high resolution: render the result stack
        # at 74 px and the in-play stack at its established 74 reference pixels.
        var source_cell_width := float(texture.get_width()) / 4.0
        carried.scale = Vector2.ONE * ((RESULTS_CARRY_SIZE if screen == "results" else 74.0) / source_cell_width)
        var atlas := AtlasTexture.new()
        atlas.atlas = texture
        var cell_width := texture.get_width() / 4
        atlas.region = Rect2i(logic.recipe[i] * cell_width, 0, cell_width, texture.get_height())
        carried.texture = atlas

func _draw_settings_gear(center: Vector2, radius: float) -> void:
    for tooth in 8:
        var angle := TAU * tooth / 8.0
        var from := center + Vector2(cos(angle), sin(angle)) * (radius - 2.0)
        var to := center + Vector2(cos(angle), sin(angle)) * (radius + 8.0)
        draw_line(from, to, Color("#d79b56"), 7.0)
    draw_circle(center, radius, Color("#6f472d", 0.95))
    draw_circle(center, radius * 0.72, Color("#d79b56", 0.92))
    draw_circle(center, radius * 0.42, Color("#3f6946"))
    _draw_ui_leaf(ui_leaf_green_texture, center + Vector2(-radius * 0.56, -radius * 0.34), UI_LEAF_GEAR_SIZE, -0.55)

func _draw_textured_medallion(center: Vector2, radius: float, unlocked: bool, completed: bool) -> void:
    draw_circle(center, radius, Color("#8d5a33", 0.78) if unlocked else Color("#45514b", 0.92))
    draw_arc(center, radius - 4.0, 0.0, TAU, 32, Color("#f3d58c", 0.58) if unlocked else Color("#a6b0a3", 0.42), 3.0)
    draw_circle(center, radius - 9.0, Color("#a76c3e", 0.76) if unlocked else Color("#58645d", 0.9))
    draw_arc(center, radius - 12.0, 0.0, TAU, 32, Color("#56331f", 0.65), 3.0)
    draw_circle(center, radius - 15.0, Color("#d9a15c", 0.62) if completed else Color("#b57842", 0.58) if unlocked else Color("#69746c", 0.72))
    draw_arc(center, radius - 19.0, 0.0, TAU, 32, Color("#f5d893", 0.25) if unlocked else Color("#c7d0c2", 0.2), 2.0)

func _draw_drop(drop: Dictionary) -> void:
    if drop.kind == "gust":
        var direction_label := "LEFT" if int(drop.get("direction", 0)) < 0 else "RIGHT"
        _text(("WIND ->" if direction_label == "RIGHT" else "<- WIND") if drop.phase == "warning" else "GUST " + direction_label, Vector2(74, 450), 42, Color("#e7f4bf"))
        return
    if drop.kind == "lightning":
        return
    if drop.kind == "predator":
        var predator_texture: Texture2D = hawk_texture if str(drop.skin) == "hawk" else owl_texture
        if predator_texture != null: draw_texture_rect(predator_texture, Rect2(drop.x - 110.0, drop.y - 110.0, 220.0, 220.0), false, _night_world_modulate(Vector2(drop.x, drop.y)))
        if drop.phase == "warning": _text("LOOK UP!", Vector2(drop.x - 100.0, 270.0), 31, Color("#fff2a6"), HORIZONTAL_ALIGNMENT_CENTER, 200.0)
        return
    if drop.kind == "limb":
        if not _limb_is_visible(drop):
            # Telegraph only: a heavy ground shadow and readable plaque, never a
            # limb sprite, collision shape, circular arc, or ring.
            var strength := clampf(float(drop.get("shadow", 0.0)), 0.0, 1.0)
            var shadow_center := _limb_warning_shadow_center(drop)
            var shadow_w: float = 152.0 + 132.0 * float(drop.width) * strength
            _draw_shadow_ellipse(shadow_center, Vector2(shadow_w, 24.0 + 26.0 * strength), Color("#17140e", 0.26 + 0.42 * strength))
            _draw_shadow_ellipse(shadow_center + Vector2(0.0, 3.0), Vector2(shadow_w * 0.64, 11.0 + 12.0 * strength), Color("#080806", 0.20 + 0.28 * strength))
            var label_rect := _limb_warning_label_rect(drop)
            var plaque := _round_box(Color("#4f2f22", 0.96), 16)
            plaque.border_color = Color("#f6d978", 0.92)
            plaque.border_width_left = 3; plaque.border_width_right = 3
            plaque.border_width_top = 3; plaque.border_width_bottom = 3
            draw_style_box(plaque, label_rect)
            _text("INCOMING!", Vector2(label_rect.position.x, label_rect.position.y + 46.0), 31, Color("#fff2a6"), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x)
        else:
            _draw_hazard(Vector2(drop.x, drop.y), drop.rotation, str(drop.skin), drop.variant, 1.35 * drop.width, _night_world_modulate(Vector2(drop.x, drop.y)))
    elif drop.kind == "leaf":
        _draw_hazard(Vector2(drop.x, drop.y), drop.rotation, str(drop.skin), drop.variant, drop.scale, _night_world_modulate(Vector2(drop.x, drop.y)))
    else:
        var collectible_center := Vector2(drop.x, drop.y + drop.bob)
        _draw_collectible(collectible_center, drop.rotation, drop.variant, 1.0, str(drop.family), false, _night_world_modulate(collectible_center))

func _limb_warning_shadow_center(drop: Dictionary) -> Vector2:
    return Vector2(clampf(float(drop.base_x), 92.0, PLAY_RIGHT - 92.0), _play_surface_y() - WARNING_SHADOW_Y_OFFSET)

func _limb_warning_label_rect(drop: Dictionary) -> Rect2:
    var x := clampf(float(drop.base_x) - WARNING_LABEL_SIZE.x * 0.5, 24.0, PLAY_RIGHT - WARNING_LABEL_SIZE.x - 18.0)
    return Rect2(x, _play_surface_y() - WARNING_LABEL_Y_OFFSET, WARNING_LABEL_SIZE.x, WARNING_LABEL_SIZE.y)

func _draw_collectible(center: Vector2, rotation: float, variant: int, scale: float, family: String, dimmed: bool, world_modulate := Color.WHITE) -> void:
    var texture: Texture2D = item_textures.get(family)
    if texture == null:
        _draw_acorn(center, rotation, (Color("#727d72") if dimmed else ACORN_COLORS[variant]) * world_modulate, variant, scale)
        return
    var cell_width := texture.get_width() / 4
    draw_set_transform(center, rotation, Vector2.ONE * scale)
    var color := (Color(0.42, 0.46, 0.42, 0.85) if dimmed else Color.WHITE) * world_modulate
    draw_texture_rect_region(texture, Rect2(-72, -72, 144, 144), Rect2(variant * cell_width, 0, cell_width, texture.get_height()), color)
    draw_set_transform(Vector2.ZERO)

func _draw_hazard(center: Vector2, rotation: float, skin: String, variant: int, scale: float, world_modulate := Color.WHITE) -> void:
    if skin == "leaf" and posmod(variant, 4) == 3 and yellow_leaf_texture != null:
        draw_set_transform(center, rotation, Vector2.ONE * scale)
        draw_texture_rect(yellow_leaf_texture, Rect2(-78, -78, 156, 156), false, world_modulate)
        draw_set_transform(Vector2.ZERO)
        return
    var texture := _hazard_texture_for(skin)
    if texture == null:
        _draw_acorn(center, rotation, Color("#d57136") * world_modulate, 0, scale)
        return
    var source: Rect2
    if skin == "leaf":
        var leaf_width := texture.get_width() / 4
        source = Rect2((variant % 4) * leaf_width, 0, leaf_width, texture.get_height())
    elif skin == "needle" or skin == "branch":
        source = Rect2(0, 0, texture.get_width(), texture.get_height())
    else:
        var hazard_index := 2 if skin == "snowflake" else 3
        var cell := Vector2(texture.get_width() / 2, texture.get_height() / 2)
        source = Rect2((hazard_index % 2) * cell.x, (hazard_index / 2) * cell.y, cell.x, cell.y)
    draw_set_transform(center, rotation, Vector2.ONE * scale)
    draw_texture_rect_region(texture, Rect2(-78, -78, 156, 156), source, world_modulate)
    draw_set_transform(Vector2.ZERO)

func _hazard_texture_for(skin: String) -> Texture2D:
    if skin == "leaf": return leaf_texture
    if skin == "needle": return needle_texture
    if skin == "branch": return branch_texture
    return hazard_texture

func _draw_acorn(center: Vector2, rotation: float, color: Color, variant: int, scale: float) -> void:
    draw_set_transform(center, rotation, Vector2(scale,scale))
    draw_circle(Vector2(0,14), 36, color)
    draw_circle(Vector2(0,-8), 34, color)
    draw_rect(Rect2(-38,-36,76,27), Color("#5e432d"))
    if variant == 1:
        draw_circle(Vector2(0,-48),15,Color("#b93f35"))
    elif variant == 2:
        for x in [-21,0,21]: draw_line(Vector2(x,-28),Vector2(x,32),Color("#f1d28b",0.8),5)
    elif variant == 3:
        draw_circle(Vector2(0,11),19,Color("#ffe58c",0.75))
    draw_line(Vector2(0,-63),Vector2(11,-80),Color("#4e6935"),7)
    draw_set_transform(Vector2.ZERO)

func _draw_shadow_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in 24: points.append(center + Vector2(cos(i*TAU/24.0)*radii.x,sin(i*TAU/24.0)*radii.y))
    draw_colored_polygon(points, color)

func _load_save() -> void:
    if FileAccess.file_exists("user://nuts_save.json"):
        var file := FileAccess.open("user://nuts_save.json", FileAccess.READ)
        var parsed = JSON.parse_string(file.get_as_text())
        if parsed is Dictionary and int(parsed.get("version",0)) == 1:
            save_data = parsed

func _save() -> void:
    var file := FileAccess.open("user://nuts_save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
