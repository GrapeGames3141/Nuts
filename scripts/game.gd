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
const RESULTS_SQUIRREL_POSITION := Vector2(500.0, 840.0)
const RESULTS_SQUIRREL_SCALE := 1.25
const RESULTS_SQUIRREL_SOURCE_BOUNDS := Rect2(130.0, 29.0, 251.0, 274.0)
const RESULTS_CARRY_SIZE := 74.0
const RESULTS_CARRY_BASE_OFFSET := Vector2(140.0, -25.0)
const RESULTS_CARRY_STEP_Y := 45.0
const MAP_PAGE_LEVELS := 10
const MAP_PAGE_COUNT := 2
const MAP_NODE_RADIUS := 59.0
const MAP_LABEL_SIZE := Vector2(188.0, 36.0)
const MAP_PREVIOUS_RECT := Rect2(62.0, 228.0, 246.0, 68.0)
const MAP_NEXT_RECT := Rect2(772.0, 228.0, 246.0, 68.0)
# Authored positions sit on the visible roots, trunk forks and major boughs
# in the two painted trees; there is deliberately no artificial rail overlay.
const MAP_NODE_POSITIONS := [
    [
        Vector2(432.0, 1614.0), Vector2(625.0, 1490.0),
        Vector2(445.0, 1358.0), Vector2(647.0, 1224.0),
        Vector2(448.0, 1088.0), Vector2(636.0, 952.0),
        Vector2(450.0, 816.0), Vector2(632.0, 682.0),
        Vector2(466.0, 548.0), Vector2(620.0, 408.0)
    ],
    [
        Vector2(430.0, 1608.0), Vector2(650.0, 1476.0),
        Vector2(448.0, 1340.0), Vector2(660.0, 1202.0),
        Vector2(438.0, 1060.0), Vector2(660.0, 918.0),
        Vector2(450.0, 774.0), Vector2(665.0, 626.0),
        Vector2(458.0, 482.0), Vector2(650.0, 360.0)
    ]
]
const PLAY_RIGHT := 800.0
const FLOOR_Y := H - 175.0
const GROUND_LINE_Y := H - 90.0
const SQUIRREL_BASE_SCALE := 0.64
# The packed pose's visible feet sit this far below the cell origin at scale 1.
const SQUIRREL_FOOT_SOURCE_OFFSET := 68.17308
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
var player_lane := 2
var player_x := LANE_X[2]
var player_target_x := player_x
var squirrel: AnimatedSprite2D
var title_squirrel: Sprite2D
var carry_sprites: Array[Sprite2D] = []
var sheet: Texture2D
var background: Texture2D
var trail_background: Texture2D
var trail_background_2: Texture2D
var item_textures: Dictionary = {}
var hazard_texture: Texture2D
var branch_texture: Texture2D
var leaf_texture: Texture2D
var needle_texture: Texture2D
var title_squirrel_texture: Texture2D
var bark_texture: Texture2D
var moss_texture: Texture2D
var leaf_button_texture: Texture2D
var save_data := {"version": 1, "unlocked": 1, "ratings": {}, "music": true, "sfx": true, "haptics": true}
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
    trail_background = load("res://assets/art/seasonal/tree_trail_real_v1.png")
    trail_background_2 = load("res://assets/art/seasonal/tree_trail_real_v2.png")
    item_textures = {
        "acorn": load("res://assets/art/items/acorn_strip.png"),
        "pinecone": load("res://assets/art/items/pinecone_strip.png")
    }
    hazard_texture = load("res://assets/art/items/seasonal_hazards.png")
    branch_texture = load("res://assets/art/items/branch_clean_v1.png")
    leaf_texture = load("res://assets/art/items/leaf_strip.png")
    needle_texture = load("res://assets/art/items/pine_needle_cluster_v1.png")
    title_squirrel_texture = load("res://assets/art/squirrel_front_acorn_v1.png")
    bark_texture = load("res://assets/art/ui_textures/oak_bark_tile_v1.png")
    moss_texture = load("res://assets/art/ui_textures/moss_panel_tile_v1.png")
    leaf_button_texture = load("res://assets/art/ui_textures/leaf_button_plaque_v1.png")
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
        frames.set_animation_loop(animation, animation != "flatten")
        var indexes := [8] if animation == "idle" else [0, 1, 2, 3] if animation == "run_left" else [4, 5, 6, 7] if animation == "run_right" else [9, 10] if animation == "flatten" else [11, 8]
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
    if screen == "title":
        squirrel.visible = false
    elif screen == "results":
        squirrel.visible = true
        squirrel.position = RESULTS_SQUIRREL_POSITION
        squirrel.scale = Vector2.ONE * RESULTS_SQUIRREL_SCALE
        squirrel.rotation = 0.0
        squirrel.flip_h = false
        if squirrel.animation != "pop": squirrel.play("pop")
    else:
        squirrel.visible = screen == "play" or screen == "recover"

func _update_play(delta: float) -> void:
    elapsed += delta
    while event_cursor < events.size() and float(events[event_cursor].time) <= elapsed:
        _spawn_event(events[event_cursor])
        event_cursor += 1
    player_x = move_toward(player_x, player_target_x, delta * 1320.0)
    if absf(player_x - player_target_x) > 12.0:
        _reset_squirrel_visual()
        squirrel.flip_h = false
        squirrel.play("run_left" if player_target_x < player_x else "run_right")
    else:
        if squirrel.animation != "idle": squirrel.play("idle")
        squirrel.flip_h = player_lane == 4
        _apply_idle_visual(delta)
    for drop in drops.duplicate():
        _move_drop(drop, delta)
        if drop.kind == "limb" and drop.phase == "falling" and _limb_hits_player(drop):
            _limb_hit(drop)
            return
        if drop.kind != "limb" and drop.y > FLOOR_Y - 90.0 and drop.y < FLOOR_Y + 90.0 and absf(drop.x - player_x) < 79.0:
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
        elapsed = 0.0
        event_cursor = 0
        drops.clear()
        logic.reset_after_limb()
        _reset_squirrel_visual()
        squirrel.play("idle")
        status_text = "Try again!"
        status_time = 1.2

func _move_drop(drop: Dictionary, delta: float) -> void:
    drop.age += delta
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
    var lane: int = event.lane
    var base_x: float = LANE_X[lane]
    var drop := {"kind": event.kind, "family": event.get("family", definition.theme.family), "skin": event.get("skin", ""), "variant": event.variant, "lane": lane, "base_x": base_x, "x": base_x,
        "y": -120.0, "speed": float(event.speed), "rotation": 0.0, "wobble": rng.randf_range(-0.45, 0.45),
        "seed": rng.randf_range(0.0, 9.0), "age": 0.0, "scale": 1.0, "bob": 0.0,
        "phase": "warning", "warning": float(event.get("warning", 0.0)), "width": int(event.get("width", 1)), "shadow": 0.0}
    if drop.kind != "limb": drop.phase = "falling"
    drops.append(drop)

func _ensure_next_target() -> void:
    if logic.progress >= logic.recipe.size(): return
    var wanted := logic.current_variant()
    for drop in drops:
        if drop.kind == "acorn" and drop.variant == wanted and drop.y < FLOOR_Y + 60.0:
            return
    # A missed required acorn is harmless: produce an unambiguous replacement.
    if event_cursor >= events.size() and elapsed > 0.75:
        _spawn_event({"kind": "acorn", "family": definition.theme.family, "variant": wanted, "lane": _replacement_lane(), "speed": definition.base_speed, "warning": 0.0})
        elapsed = -2.5

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
            var active_eta := maxf(0.0, (FLOOR_Y - float(drop.y)) / maxf(1.0, float(drop.speed)))
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
        _spark(Vector2(drop.x, FLOOR_Y), ACORN_COLORS[drop.variant], 10)
        _haptic(18)
    elif outcome == "complete":
        _play_sfx("catch")
        _finish_level()
    elif outcome == "wrong":
        _play_sfx("wrong")
        _feedback("Oops - one nut slipped away", Color("#ffd1ae"))
        _spark(Vector2(drop.x, FLOOR_Y), Color("#d85840"), 8)
        _haptic(45)
    _update_carry_stack()

func _limb_hits_player(drop: Dictionary) -> bool:
    if str(drop.get("phase", "falling")) != "falling":
        return false
    var half_width := 72.0 + 74.0 * float(drop.width - 1)
    return drop.y > FLOOR_Y - 100.0 and drop.y < FLOOR_Y + 85.0 and absf(drop.x - player_x) < half_width

func _limb_is_visible(drop: Dictionary) -> bool:
    return str(drop.get("phase", "warning")) == "falling"

func _limb_hit(drop: Dictionary) -> void:
    drops.clear()
    for i in 22:
        particles.append({"p": Vector2(player_x, FLOOR_Y), "v": Vector2(rng.randf_range(-390,390), rng.randf_range(-380,-80)), "life": rng.randf_range(0.45, 0.95), "color": Color("#8d5533")})
    logic.catch_object("limb", -1)
    _reset_squirrel_visual()
    squirrel.play("flatten")
    screen = "recover"
    recover_phase = 0
    recover_time = 0.0
    _feedback("TIMBER!", Color("#fff0bd"))
    _play_sfx("limb")
    _haptic(120)
    _update_carry_stack()

func _finish_level() -> void:
    var stars := logic.stars()
    var key := str(level_number)
    save_data.ratings[key] = max(int(save_data.ratings.get(key, 0)), stars)
    save_data.unlocked = min(20, max(int(save_data.unlocked), level_number + 1))
    _save()
    screen = "results"
    drops.clear()
    _reset_squirrel_visual()
    squirrel.play("pop")
    _feedback("Recipe complete!", Color("#fff4ad"))
    _spark(Vector2(player_x, FLOOR_Y), Color("#ffe58b"), 24)
    _haptic(45)
    _update_carry_stack()

func _start_level(number: int) -> void:
    level_number = clampi(number, 1, 20)
    definition = LevelData.make(level_number, 7000 + level_number * 31)
    background = _background_for(str(definition.theme.background))
    logic.begin(definition.recipe, 7000 + level_number * 31)
    events = definition.events
    drops.clear()
    particles.clear()
    elapsed = 0.0
    event_cursor = 0
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
        "winter_pine": "res://assets/art/seasonal/winter_pine.png"
    }
    return load(paths.get(background_id, paths.summer_oak))

func _reset_squirrel_visual() -> void:
    idle_time = 0.0
    squirrel.position = Vector2(player_x, SQUIRREL_Y)
    squirrel.scale = Vector2.ONE * SQUIRREL_BASE_SCALE
    squirrel.rotation = 0.0

func _apply_idle_visual(delta: float) -> void:
    idle_time += delta
    var breath := 1.0 + sin(idle_time * IDLE_BREATH_SPEED) * IDLE_BREATH_SCALE
    squirrel.scale = Vector2.ONE * SQUIRREL_BASE_SCALE * breath
    squirrel.position = Vector2(player_x, SQUIRREL_Y + sin(idle_time * IDLE_SWAY_SPEED) * IDLE_BOB_PIXELS)
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
    if RESULTS_BUTTON_RECTS[0].has_point(point) and level_number < 20:
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
    var last: int = min(first + MAP_PAGE_LEVELS, LevelData.NAMES.size() + 1)
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
    var page_background := (trail_background if map_page == 1 else trail_background_2) if screen == "map" else background
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
    var x := position.x - MAP_LABEL_SIZE.x - 20.0 if position.x < W * 0.5 else position.x + 20.0
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
    var last: int = min(first + MAP_PAGE_LEVELS, LevelData.NAMES.size() + 1)
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
        _text(LevelData.NAMES[n-1], Vector2(label_rect.position.x, label_rect.position.y + 25), 19, Color("#f6f2ce"), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x)
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
    _draw_tree_ring(RESULTS_MEDALLION_CENTER, RESULTS_MEDALLION_RADIUS)
    for leaf_index in 6:
        var leaf_angle := TAU * leaf_index / 6.0 + 0.24
        var leaf_center := RESULTS_MEDALLION_CENTER + Vector2(cos(leaf_angle), sin(leaf_angle)) * (RESULTS_MEDALLION_RADIUS + 18.0)
        _draw_leaf(leaf_center, Color("#b76b3d") if leaf_index % 2 == 0 else Color("#6e9c56"), 0.9, leaf_angle + 0.4)
    _draw_wood_panel(RESULTS_RIBBON_RECT, Color("#8d512f", 0.97))
    _text("LEVEL %d  •  %s" % [level_number, definition.name], Vector2(RESULTS_RIBBON_RECT.position.x, RESULTS_RIBBON_RECT.position.y + 55.0), 31, Color("#fff4cb"), HORIZONTAL_ALIGNMENT_CENTER, RESULTS_RIBBON_RECT.size.x)
    for slot in range(3):
        _draw_collectible(Vector2(430 + slot * 110, 1178), 0.0, slot, 0.58, "acorn", slot >= stars)
    _text("%d mistake%s" % [logic.mistakes, "" if logic.mistakes == 1 else "s"], Vector2(0, 1280), 32, Color("#f7dfb9"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _draw_leaf_button(RESULTS_BUTTON_RECTS[0], "NEXT LEVEL" if level_number < 20 else "ALL 20 LEVELS COMPLETE", level_number < 20, Color("#ba6e3d"))
    _draw_leaf_button(RESULTS_BUTTON_RECTS[1], "RETRY LEVEL", true, Color("#9a5637"))
    _draw_leaf_button(RESULTS_BUTTON_RECTS[2], "TREE TRAIL", true, Color("#5f8958"))

func _results_squirrel_visual_rect() -> Rect2:
    # Union of packed pop frames 11 and 8. Keeping this explicit ties the
    # celebration layout to the actual alpha artwork rather than its cell size.
    var top_left := RESULTS_SQUIRREL_POSITION + (RESULTS_SQUIRREL_SOURCE_BOUNDS.position - Vector2(256.0, 256.0)) * RESULTS_SQUIRREL_SCALE
    return Rect2(top_left, RESULTS_SQUIRREL_SOURCE_BOUNDS.size * RESULTS_SQUIRREL_SCALE)

func _title_squirrel_visual_rect() -> Rect2:
    var top_left := TITLE_SQUIRREL_POSITION + (TITLE_SQUIRREL_SOURCE_BOUNDS.position - TITLE_SQUIRREL_SOURCE_SIZE * 0.5) * TITLE_SQUIRREL_SCALE
    return Rect2(top_left, TITLE_SQUIRREL_SOURCE_BOUNDS.size * TITLE_SQUIRREL_SCALE)

func _draw_game() -> void:
    if bool(definition.get("theme", {}).get("ambient", false)):
        _draw_ambient_snow()
    _draw_goal()
    _draw_wood_panel(Rect2(38, SAFE_TOP, 505, 94), Color("#244338",0.88))
    _text("LEVEL %d  %s" % [level_number, definition.name], Vector2(65, SAFE_TOP + 62), 31, Color("#fff0b0"))
    _draw_textured_medallion(PAUSE_RECT.get_center(), 40.0, true, false)
    _text("II", Vector2(972, SAFE_TOP + 58), 30)
    for drop in drops:
        _draw_drop(drop)
    for particle in particles:
        draw_circle(particle.p, 7.0 * particle.life + 2.0, particle.color)
    draw_line(Vector2(55,GROUND_LINE_Y), Vector2(PLAY_RIGHT,GROUND_LINE_Y), Color("#6a4a31"), 12)
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
    _draw_leaf(rect.position + Vector2(55.0, rect.size.y * 0.5), Color("#769b53"), 0.9, -0.55)
    _draw_leaf(rect.end - Vector2(55.0, rect.size.y * 0.5), Color("#d2893f"), 0.9, 0.55)
    _text(label, Vector2(rect.position.x, rect.position.y + 115.0), 58, Color("#fff3b7"), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)

func _draw_tree_ring(center: Vector2, radius: float) -> void:
    draw_circle(center, radius + 18.0, Color("#523321", 0.78))
    draw_circle(center, radius, Color("#a56438", 0.72))
    # Keep the square bark tile wholly inside the circular face; it cannot leak
    # into the bark rim or leave square corners around the medallion.
    var tile_half := radius * 0.58
    if bark_texture != null:
        draw_texture_rect(bark_texture, Rect2(center - Vector2.ONE * tile_half, Vector2.ONE * tile_half * 2.0), true, Color(1.0, 0.78, 0.55, 0.72))
    draw_circle(center, radius - 20.0, Color("#d29a5b", 0.68))
    for ring in [0.25, 0.46, 0.67, 0.84]:
        draw_arc(center + Vector2(-12.0, 8.0), (radius - 30.0) * ring, -2.7, 2.5, 42, Color("#805035", 0.47), 3.0)
    for notch in 16:
        var angle := TAU * notch / 16.0
        var from := center + Vector2(cos(angle), sin(angle)) * (radius - 8.0)
        var to := center + Vector2(cos(angle), sin(angle)) * (radius + 15.0)
        draw_line(from, to, Color("#6d4129", 0.8), 7.0)

func _draw_leaf(center: Vector2, color: Color, scale: float, rotation: float) -> void:
    var points := PackedVector2Array([Vector2(-26, 0), Vector2(-4, -19), Vector2(31, -5), Vector2(39, 7), Vector2(4, 20), Vector2(-22, 13)])
    draw_set_transform(center, rotation, Vector2.ONE * scale)
    draw_colored_polygon(points, color)
    draw_line(Vector2(-21, 7), Vector2(28, -2), Color("#f7d99a", 0.45), 2.0)
    draw_set_transform(Vector2.ZERO)

func _draw_leaf_button(rect: Rect2, label: String, enabled: bool, color: Color) -> void:
    var button_color := color if enabled else Color("#596257", 0.94)
    _draw_wood_panel(rect, button_color)
    if leaf_button_texture != null:
        var plaque_height := rect.size.y * 1.04
        var plaque_width := minf(rect.size.x - 16.0, plaque_height * float(leaf_button_texture.get_width()) / float(leaf_button_texture.get_height()))
        var plaque_rect := Rect2(rect.get_center() - Vector2(plaque_width, plaque_height) * 0.5, Vector2(plaque_width, plaque_height))
        draw_texture_rect(leaf_button_texture, plaque_rect, false, Color(1.0, 1.0, 1.0, 0.9 if enabled else 0.42))
    _draw_leaf(rect.position + Vector2(31.0, rect.size.y * 0.5), Color("#d8ae55"), 0.55, -0.55)
    _draw_leaf(rect.end - Vector2(31.0, rect.size.y * 0.5), Color("#e1bd63"), 0.55, 0.55)
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
            # in front of the pop sprite, with a small alternating lean instead of
            # cutting through the face or the carved heading.
            var result_offset := RESULTS_CARRY_BASE_OFFSET + Vector2((i % 2) * 10.0 - 4.0, -i * RESULTS_CARRY_STEP_Y)
            carried.position = RESULTS_SQUIRREL_POSITION + result_offset
            carried.rotation = wobble + (-0.08 if i % 2 == 0 else 0.08)
        else:
            # Attach to the raised paw-side, not the face. On lane 4 the stack
            # mirrors inward, preserving the goal rail and the squirrel's eye.
            var side := -1.0 if player_lane == 4 else 1.0
            var offset := Vector2(side * (76.0 + (i % 2) * 11.0), -56.0 - i * 42.0)
            carried.position = Vector2(player_x, SQUIRREL_Y) + offset
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
    _draw_leaf(center + Vector2(-radius * 0.56, -radius * 0.34), Color("#7d9e54"), 0.35, -0.55)

func _draw_textured_medallion(center: Vector2, radius: float, unlocked: bool, completed: bool) -> void:
    draw_circle(center, radius, Color("#8d5a33", 0.78) if unlocked else Color("#45514b", 0.92))
    # The tiled bark sits within the inscribed face, avoiding square texture
    # corners outside the carved circular rim.
    var tile_half := radius * 0.58
    if bark_texture != null:
        draw_texture_rect(bark_texture, Rect2(center - Vector2.ONE * tile_half, Vector2.ONE * tile_half * 2.0), true, Color(0.85, 0.68, 0.46, 0.76) if unlocked else Color(0.38, 0.43, 0.40, 0.76))
    draw_circle(center, radius - 15.0, Color("#d9a15c", 0.62) if completed else Color("#b57842", 0.58) if unlocked else Color("#69746c", 0.72))

func _draw_drop(drop: Dictionary) -> void:
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
            _text("RUSTLE!", Vector2(label_rect.position.x, label_rect.position.y + 46.0), 31, Color("#fff2a6"), HORIZONTAL_ALIGNMENT_CENTER, label_rect.size.x)
        else:
            _draw_hazard(Vector2(drop.x, drop.y), drop.rotation, str(drop.skin), drop.variant, 1.35 * drop.width)
    elif drop.kind == "leaf":
        _draw_hazard(Vector2(drop.x, drop.y), drop.rotation, str(drop.skin), drop.variant, drop.scale)
    else:
        _draw_collectible(Vector2(drop.x, drop.y + drop.bob), drop.rotation, drop.variant, 1.0, str(drop.family), false)

func _limb_warning_shadow_center(drop: Dictionary) -> Vector2:
    return Vector2(clampf(float(drop.base_x), 92.0, PLAY_RIGHT - 92.0), GROUND_LINE_Y - WARNING_SHADOW_Y_OFFSET)

func _limb_warning_label_rect(drop: Dictionary) -> Rect2:
    var x := clampf(float(drop.base_x) - WARNING_LABEL_SIZE.x * 0.5, 24.0, PLAY_RIGHT - WARNING_LABEL_SIZE.x - 18.0)
    return Rect2(x, GROUND_LINE_Y - WARNING_LABEL_Y_OFFSET, WARNING_LABEL_SIZE.x, WARNING_LABEL_SIZE.y)

func _draw_collectible(center: Vector2, rotation: float, variant: int, scale: float, family: String, dimmed: bool) -> void:
    var texture: Texture2D = item_textures.get(family)
    if texture == null:
        _draw_acorn(center, rotation, Color("#727d72") if dimmed else ACORN_COLORS[variant], variant, scale)
        return
    var cell_width := texture.get_width() / 4
    draw_set_transform(center, rotation, Vector2.ONE * scale)
    var color := Color(0.42, 0.46, 0.42, 0.85) if dimmed else Color.WHITE
    draw_texture_rect_region(texture, Rect2(-72, -72, 144, 144), Rect2(variant * cell_width, 0, cell_width, texture.get_height()), color)
    draw_set_transform(Vector2.ZERO)

func _draw_hazard(center: Vector2, rotation: float, skin: String, variant: int, scale: float) -> void:
    var texture := _hazard_texture_for(skin)
    if texture == null:
        _draw_acorn(center, rotation, Color("#d57136"), 0, scale)
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
    draw_texture_rect_region(texture, Rect2(-78, -78, 156, 156), source)
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
