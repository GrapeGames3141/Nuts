extends Node2D

const GameLogic = preload("res://scripts/game_logic.gd")
const LevelData = preload("res://scripts/level_data.gd")
const NutsProceduralAudio = preload("res://scripts/procedural_audio.gd")

const W := 1080.0
const H := 1920.0
const PLAY_RIGHT := 800.0
const FLOOR_Y := 1510.0
const FLATTEN_HOLD_SECONDS := 1.5
const POP_RECOVERY_SECONDS := 0.55
const LANE_X := [105.0, 270.0, 435.0, 600.0, 765.0]
const ACORN_COLORS := [Color("#bb7136"), Color("#c94838"), Color("#8064a8"), Color("#e3ae35")]
const ACORN_NAMES := ["Oak", "Redcap", "Striped", "Gold"]

var screen := "title"
var level_number := 1
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
var sheet: Texture2D
var background: Texture2D
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

func _ready() -> void:
    rng.seed = 84519
    background = load("res://assets/art/forest_background.png")
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
    squirrel.position = Vector2(player_x, FLOOR_Y + 25.0)
    squirrel.scale = Vector2(0.44, 0.44)
    squirrel.centered = true
    sheet = load("res://assets/art/squirrel_sheet_clean.png")
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

func _sheet_frame(index: int) -> Texture2D:
    if sheet == null: return null
    var atlas := AtlasTexture.new()
    atlas.atlas = sheet
    var cell := Vector2i(sheet.get_width() / 4, sheet.get_height() / 3)
    atlas.region = Rect2i((index % 4) * cell.x, (index / 4) * cell.y, cell.x, cell.y)
    return atlas

func _process(delta: float) -> void:
    if status_time > 0.0:
        status_time -= delta
    if screen == "play" and not paused:
        _update_play(delta)
    elif screen == "recover":
        _update_recovery(delta)
    _update_particles(delta)
    queue_redraw()

func _update_play(delta: float) -> void:
    elapsed += delta
    while event_cursor < events.size() and float(events[event_cursor].time) <= elapsed:
        _spawn_event(events[event_cursor])
        event_cursor += 1
    player_x = move_toward(player_x, player_target_x, delta * 1320.0)
    squirrel.position.x = player_x
    if absf(player_x - player_target_x) > 12.0:
        squirrel.play("run_left" if player_target_x < player_x else "run_right")
    elif squirrel.animation != "idle":
        squirrel.play("idle")
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
        drop.rotation += delta * (0.85 + drop.wobble)
        drop.x = drop.base_x + sin(drop.age * 3.7 + drop.seed) * 18.0
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
    var drop := {"kind": event.kind, "variant": event.variant, "lane": lane, "base_x": base_x, "x": base_x,
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
        _spawn_event({"kind": "acorn", "variant": wanted, "lane": (player_lane + 2) % 5, "speed": definition.base_speed, "warning": 0.0})
        elapsed = -2.5

func _catch(drop: Dictionary) -> void:
    var outcome := logic.catch_object(drop.kind, drop.variant)
    if outcome == "correct":
        _play_sfx("catch")
        _feedback("Nice! " + ACORN_NAMES[drop.variant], Color("#fff3bd"))
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

func _limb_hits_player(drop: Dictionary) -> bool:
    var half_width := 72.0 + 74.0 * float(drop.width - 1)
    return drop.y > FLOOR_Y - 100.0 and drop.y < FLOOR_Y + 85.0 and absf(drop.x - player_x) < half_width

func _limb_hit(drop: Dictionary) -> void:
    drops.clear()
    for i in 22:
        particles.append({"p": Vector2(player_x, FLOOR_Y), "v": Vector2(rng.randf_range(-390,390), rng.randf_range(-380,-80)), "life": rng.randf_range(0.45, 0.95), "color": Color("#8d5533")})
    logic.catch_object("limb", -1)
    squirrel.play("flatten")
    screen = "recover"
    recover_phase = 0
    recover_time = 0.0
    _feedback("TIMBER!", Color("#fff0bd"))
    _play_sfx("limb")
    _haptic(120)

func _finish_level() -> void:
    var stars := logic.stars()
    var key := str(level_number)
    save_data.ratings[key] = max(int(save_data.ratings.get(key, 0)), stars)
    save_data.unlocked = min(10, max(int(save_data.unlocked), level_number + 1))
    _save()
    screen = "results"
    drops.clear()
    squirrel.play("idle")
    _feedback("Recipe complete!", Color("#fff4ad"))
    _spark(Vector2(player_x, FLOOR_Y), Color("#ffe58b"), 24)
    _haptic(45)

func _start_level(number: int) -> void:
    level_number = number
    definition = LevelData.make(number, 7000 + number * 31)
    logic.begin(definition.recipe, 7000 + number * 31)
    events = definition.events
    drops.clear()
    particles.clear()
    elapsed = 0.0
    event_cursor = 0
    player_lane = 2
    player_x = LANE_X[2]
    player_target_x = player_x
    squirrel.position.x = player_x
    squirrel.play("idle")
    paused = false
    screen = "play"
    _feedback("Level %d: %s" % [number, definition.name], Color("#fff1bb"))
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
    var press: bool = event is InputEventScreenTouch and event.pressed
    var drag: bool = event is InputEventScreenDrag
    var mouse: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
    if press or drag or mouse:
        var point: Vector2 = event.position
        if screen == "play":
            if paused:
                _pause_click(point)
            elif point.x > 940 and point.y < 150:
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

func _retry_level() -> void:
    _start_level(level_number)

func _pause_click(point: Vector2) -> void:
    if Rect2(230, 815, 620, 86).has_point(point):
        paused = false
    elif Rect2(230, 920, 620, 86).has_point(point):
        _retry_level()
    elif Rect2(230, 1025, 620, 86).has_point(point):
        paused = false
        screen = "map"
    _play_sfx("button")

func _results_click(point: Vector2) -> void:
    if Rect2(230, 950, 620, 76).has_point(point) and level_number < 10:
        _start_level(level_number + 1)
    elif Rect2(230, 1040, 620, 76).has_point(point):
        _retry_level()
    elif Rect2(230, 1130, 620, 76).has_point(point):
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
    if point.x > 875 and point.y < 190:
        screen = "settings"
        return
    for number in range(1, 11):
        var pos := _map_node_position(number)
        if point.distance_to(pos) < 80.0 and number <= int(save_data.unlocked):
            _start_level(number)
            return

func _map_node_position(number: int) -> Vector2:
    var row := (number - 1) / 2
    return Vector2(220.0 if number % 2 == 1 else 640.0, 440.0 + row * 245.0)

func _draw() -> void:
    if background != null:
        draw_texture_rect(background, Rect2(0, 0, W, H), false, Color(1,1,1,0.62))
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
    draw_style_box(_round_box(color, 28), rect)

func _round_box(color: Color, radius: int) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = color
    box.corner_radius_top_left = radius; box.corner_radius_top_right = radius
    box.corner_radius_bottom_left = radius; box.corner_radius_bottom_right = radius
    box.border_width_left = 3; box.border_width_right = 3; box.border_width_top = 3; box.border_width_bottom = 3
    box.border_color = Color("#f4d98a", 0.48)
    return box

func _draw_title() -> void:
    _panel(Rect2(95, 420, 890, 760), Color("#234538", 0.91))
    _text("Nuts!", Vector2(0, 620), 182, Color("#fff1ad"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("Catch the acorns in recipe order", Vector2(0, 705), 42, Color("#fff9dd"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("Drag the squirrel through five lanes", Vector2(0, 765), 32, Color("#cfe4bd"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _panel(Rect2(265, 900, 550, 130), Color("#c87538", 0.96))
    _text("TAP TO CLIMB", Vector2(0, 985), 46, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("A woodland pocket game", Vector2(0, 1100), 25, Color("#d5e6ca"), HORIZONTAL_ALIGNMENT_CENTER, W)

func _draw_map() -> void:
    _panel(Rect2(60, 70, 960, 145))
    _text("TREE TRAIL", Vector2(95, 168), 62, Color("#fff0ac"))
    _text("Progress is saved", Vector2(620, 150), 28, Color("#d7e9cc"))
    _panel(Rect2(880, 92, 105, 90), Color("#6f8c70"))
    _text("...", Vector2(906, 151), 44)
    for n in range(1, 11):
        var p := _map_node_position(n)
        var unlocked := n <= int(save_data.unlocked)
        draw_circle(p, 72, Color("#d08b42") if unlocked else Color("#526358"))
        draw_arc(p, 72, 0, TAU, 32, Color("#fff0b4", 0.7), 5)
        _text(str(n), p + Vector2(-17, 17), 48, Color.WHITE)
        var stars := int(save_data.ratings.get(str(n), 0))
        _text("o".repeat(stars) + "-".repeat(3-stars), p + Vector2(-42, 118), 27, Color("#ffe69a"))
        _text(LevelData.NAMES[n-1], p + Vector2(-105, -95), 25, Color("#f6f2ce"), HORIZONTAL_ALIGNMENT_CENTER, 210)
    _text("Complete a level to grow to the next branch.", Vector2(0, 1770), 29, Color("#eef1d7"), HORIZONTAL_ALIGNMENT_CENTER, W)

func _draw_settings() -> void:
    _panel(Rect2(105, 420, 870, 760))
    _text("SETTINGS", Vector2(0, 545), 70, Color("#fff0ac"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _draw_button(Rect2(175, 620, 730, 76), "MUSIC     " + ("ON" if save_data.music else "OFF"), bool(save_data.music))
    _draw_button(Rect2(175, 725, 730, 76), "SOUND EFFECTS     " + ("ON" if save_data.sfx else "OFF"), bool(save_data.sfx))
    _draw_button(Rect2(175, 830, 730, 76), "HAPTICS     " + ("ON" if save_data.haptics else "OFF"), bool(save_data.haptics))
    _text("Tap outside a switch to return", Vector2(0, 1030), 31, Color("#d5e6ca"), HORIZONTAL_ALIGNMENT_CENTER, W)

func _draw_results() -> void:
    var stars := logic.stars()
    _panel(Rect2(100, 430, 880, 700))
    _text("RECIPE COMPLETE!", Vector2(0, 585), 65, Color("#fff0ac"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("Level %d - %s" % [level_number, definition.name], Vector2(0, 665), 35, Color("#e5efd2"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("o".repeat(stars) + "-".repeat(3-stars), Vector2(0, 815), 108, Color("#ffe699"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _text("%d mistake%s" % [logic.mistakes, "" if logic.mistakes == 1 else "s"], Vector2(0, 890), 32, Color("#f7dfb9"), HORIZONTAL_ALIGNMENT_CENTER, W)
    _draw_button(Rect2(230, 950, 620, 76), "NEXT LEVEL" if level_number < 10 else "ALL 10 LEVELS COMPLETE", level_number < 10)
    _draw_button(Rect2(230, 1040, 620, 76), "RETRY LEVEL", true)
    _draw_button(Rect2(230, 1130, 620, 76), "TREE TRAIL", true)

func _draw_game() -> void:
    for x in LANE_X:
        draw_line(Vector2(x, 250), Vector2(x, FLOOR_Y+75), Color("#e2d894",0.18), 3)
    _draw_goal()
    _panel(Rect2(38, 34, 505, 94), Color("#244338",0.88))
    _text("LEVEL %d  %s" % [level_number, definition.name], Vector2(65, 96), 31, Color("#fff0b0"))
    _panel(Rect2(953, 36, 85, 85), Color("#6e875e"))
    _text("II", Vector2(972, 94), 30)
    for drop in drops:
        _draw_drop(drop)
    for particle in particles:
        draw_circle(particle.p, 7.0 * particle.life + 2.0, particle.color)
    draw_line(Vector2(55,FLOOR_Y+85), Vector2(PLAY_RIGHT,FLOOR_Y+85), Color("#6a4a31"), 12)
    if status_time > 0.0:
        _panel(Rect2(80, 1290, 700, 90), Color("#315443",0.93))
        _text(status_text, Vector2(105, 1350), 35, Color("#fff5cc"), HORIZONTAL_ALIGNMENT_CENTER, 650)
    if paused:
        _panel(Rect2(130, 650, 670, 520), Color("#203b34",0.96))
        _text("PAUSED", Vector2(0, 790), 72, Color("#fff0ac"), HORIZONTAL_ALIGNMENT_CENTER, W)
        _draw_button(Rect2(230, 815, 620, 86), "RESUME", true)
        _draw_button(Rect2(230, 920, 620, 86), "RETRY", true)
        _draw_button(Rect2(230, 1025, 620, 86), "TREE TRAIL", true)

func _draw_button(rect: Rect2, label: String, enabled: bool) -> void:
    _panel(rect, Color("#c87538", 0.97) if enabled else Color("#596257", 0.92))
    _text(label, Vector2(rect.position.x, rect.position.y + rect.size.y * 0.67), 29, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)

func _draw_goal() -> void:
    _panel(Rect2(824, 235, 228, 790), Color("#244239",0.93))
    _text("GOAL", Vector2(850, 292), 36, Color("#fff0aa"))
    _text("BOTTOM", Vector2(850, 332), 20, Color("#bed7bc"))
    for i in logic.recipe.size():
        var y := 920.0 - i * 125.0
        var state := "held" if i < logic.progress else "current" if i == logic.progress else "waiting"
        var c: Color = Color("#727d72") if state == "held" else ACORN_COLORS[logic.recipe[i]]
        if state == "current": draw_circle(Vector2(938,y), 56 + sin(elapsed*5.0)*5.0, Color("#fff2a8",0.24))
        _draw_acorn(Vector2(938,y), 0.0, c, logic.recipe[i], 0.72)
        _text(str(i+1), Vector2(850,y+12), 25, Color.WHITE)
    _text("FIRST", Vector2(850, 973), 20, Color("#bed7bc"))

func _draw_drop(drop: Dictionary) -> void:
    if drop.kind == "limb":
        if drop.phase == "warning":
            var shadow_w: float = 82.0 + 90.0 * drop.width * drop.shadow
            _draw_shadow_ellipse(Vector2(drop.base_x, FLOOR_Y+55), Vector2(shadow_w, 16 + 20*drop.shadow), Color("#202016",0.13 + 0.26*drop.shadow))
            draw_arc(Vector2(drop.base_x, FLOOR_Y+55), shadow_w, 0, TAU, 20, Color("#ffd66b", drop.shadow), 5)
            _text("RUSTLE!", Vector2(drop.base_x-72, FLOOR_Y-155), 24, Color("#ffe998"))
        else:
            draw_set_transform(Vector2(drop.x, drop.y), drop.rotation, Vector2.ONE)
            draw_rect(Rect2(-65*drop.width,-24,130*drop.width,48), Color("#70452c"))
            draw_circle(Vector2(-52*drop.width,0), 30, Color("#a36a3c"))
            draw_circle(Vector2(52*drop.width,0), 30, Color("#9c6138"))
            draw_set_transform(Vector2.ZERO)
    elif drop.kind == "leaf":
        draw_set_transform(Vector2(drop.x, drop.y), drop.rotation, Vector2(drop.scale,drop.scale))
        var leaf := PackedVector2Array([Vector2(0,-42),Vector2(30,-5),Vector2(0,42),Vector2(-30,-5)])
        draw_colored_polygon(leaf, Color("#d57136"))
        draw_line(Vector2(0,-35),Vector2(0,40),Color("#774e2d"),4)
        draw_set_transform(Vector2.ZERO)
    else:
        _draw_acorn(Vector2(drop.x, drop.y + drop.bob), drop.rotation, ACORN_COLORS[drop.variant], drop.variant, 1.0)

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
