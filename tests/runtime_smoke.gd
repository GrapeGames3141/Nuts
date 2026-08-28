extends SceneTree
func _init() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    var scene: Variant = packed.instantiate()
    root.add_child(scene)
    await process_frame
    var ad_service := root.get_node_or_null("AdBarService")
    assert(ad_service != null)
    assert(ad_service.active_product_key() == "nuts")
    assert(ad_service.banner_unit_id_for("nuts", "Android") == "ca-app-pub-3940256099942544/6300978111")
    assert(is_zero_approx(ad_service.banner_height()))
    assert(ResourceLoader.exists("res://assets/art/game_icon.png"))
    assert(ResourceLoader.exists("res://assets/art/nuts_boot_splash.png"))
    assert(ResourceLoader.exists("res://assets/art/seasonal/tree_trail_real_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/seasonal/tree_trail_real_v2.png"))
    assert(ResourceLoader.exists("res://assets/art/squirrel_sheet_packed.png"))
    assert(ResourceLoader.exists("res://assets/art/squirrel_idle_full_v2.png"))
    assert(ResourceLoader.exists("res://assets/art/squirrel_flatten_hold_full_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/squirrel_pop_full_v2.png"))
    assert(ResourceLoader.exists("res://assets/art/items/acorn_strip.png"))
    assert(ResourceLoader.exists("res://assets/art/items/pinecone_strip.png"))
    assert(ResourceLoader.exists("res://assets/art/items/seasonal_hazards.png"))
    assert(ResourceLoader.exists("res://assets/art/items/branch_clean_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/items/leaf_yellow_clean_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/items/pine_needle_cluster_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/squirrel_front_acorn_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/ui_textures/oak_bark_tile_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/ui_textures/pause_log_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/ui_textures/moss_panel_tile_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/ui_textures/leaf_button_plaque_v1.png"))
    scene.screen = "title"
    assert(ResourceLoader.exists("res://assets/art/ui_textures/ui_leaf_green_v1.png"))
    assert(ResourceLoader.exists("res://assets/art/ui_textures/ui_leaf_amber_v1.png"))
    scene._process(0.0)
    assert(scene.title_squirrel != null and scene.title_squirrel.visible and not scene.squirrel.visible)
    assert(scene.title_squirrel.texture == scene.title_squirrel_texture)
    assert(is_equal_approx(scene.title_squirrel.scale.x, scene.TITLE_SQUIRREL_SCALE))
    var title_visual: Rect2 = scene._title_squirrel_visual_rect()
    assert(absf(title_visual.end.y - scene.GROUND_LINE_Y) <= 1.5)
    assert(title_visual.position.y > scene.TITLE_CARD_RECT.end.y + 100.0)
    assert(title_visual.position.x >= 0.0 and title_visual.end.x <= scene.W)
    assert(title_visual.position.y >= scene.SAFE_TOP and title_visual.end.y <= scene.H)
    scene.validation_ad_reserve = 140.0
    scene._apply_screen_squirrel()
    assert(is_equal_approx(scene._ad_bottom_reserve(), 140.0))
    assert(is_equal_approx(scene._content_bottom_y(), scene.H - 140.0))
    assert(is_equal_approx(scene._play_surface_y(), scene.GROUND_LINE_Y - 140.0))
    assert(absf(scene._title_squirrel_visual_rect().end.y - (scene.GROUND_LINE_Y - 140.0)) <= 1.5)
    assert(scene.RESULTS_PANEL_RECT.end.y <= scene._content_bottom_y())
    assert(scene._map_node_position(1).y + scene.MAP_NODE_RADIUS + 22.0 < scene._content_bottom_y())
    var blocked_ad_tap := InputEventScreenTouch.new()
    blocked_ad_tap.pressed = true
    blocked_ad_tap.position = Vector2(scene.W * 0.5, scene.H - 20.0)
    scene._unhandled_input(blocked_ad_tap)
    assert(scene.screen == "title")
    scene.validation_ad_reserve = 0.0
    scene._apply_screen_squirrel()
    assert(absf(scene._title_squirrel_visual_rect().end.y - scene.GROUND_LINE_Y) <= 1.5)
    assert(scene.bark_texture != null and scene.moss_texture != null and scene.leaf_button_texture != null)
    var title_tap := InputEventScreenTouch.new()
    assert(scene.ui_leaf_green_texture != null and scene.ui_leaf_amber_texture != null)
    assert(scene.ui_leaf_green_texture.get_width() > 0 and scene.ui_leaf_green_texture.get_height() > 0)
    assert(scene.ui_leaf_amber_texture.get_width() > 0 and scene.ui_leaf_amber_texture.get_height() > 0)
    var game_source := FileAccess.get_file_as_string("res://scripts/game.gd")
    assert(not game_source.contains("func _draw_leaf("))
    title_tap.pressed = true
    title_tap.position = Vector2(540.0, 960.0)
    scene._unhandled_input(title_tap)
    assert(scene.screen == "map")
    var level_one_click := InputEventMouseButton.new()
    level_one_click.button_index = MOUSE_BUTTON_LEFT
    level_one_click.pressed = true
    level_one_click.position = scene._map_node_position(1)
    scene._unhandled_input(level_one_click)
    assert(scene.screen == "play" and scene.level_number == 1)
    assert(scene.screen == "play")
    assert(ProjectSettings.get_setting("application/boot_splash/image") == "res://assets/art/nuts_boot_splash.png")
    assert(ProjectSettings.get_setting("application/boot_splash/show_image") == true)
    assert(ProjectSettings.get_setting("application/boot_splash/stretch_mode") == 1)
    assert(scene.TITLE_CTA == "TAP TO PLAY" and scene.TITLE_CTA != "TAP TO CLIMB")
    assert(scene.SQUIRREL_BASE_SCALE >= 0.62)
    assert(is_equal_approx(scene.SQUIRREL_FOOT_OFFSET, scene.SQUIRREL_FOOT_SOURCE_OFFSET * scene.SQUIRREL_BASE_SCALE))
    assert(is_equal_approx(scene.squirrel.position.y, scene.SQUIRREL_Y))
    assert(is_equal_approx(scene.GROUND_LINE_Y - scene.squirrel.position.y, scene.SQUIRREL_FOOT_OFFSET))
    assert(scene.squirrel.sprite_frames.has_animation("idle"))
    assert(scene.squirrel.sprite_frames.has_animation("run_left"))
    assert(scene.squirrel.sprite_frames.has_animation("run_right"))
    assert(scene.squirrel.sprite_frames.has_animation("flatten"))
    assert(scene.squirrel.sprite_frames.has_animation("pop"))
    var idle_frame: AtlasTexture = scene.squirrel.sprite_frames.get_frame_texture("idle", 0)
    assert(scene.sheet.get_width() == 2048 and scene.sheet.get_height() == 1536)
    assert(idle_frame.region.size == Vector2(512, 512))
    assert(idle_frame.region.position == Vector2(0, 1024))
    var right_frame: AtlasTexture = scene.squirrel.sprite_frames.get_frame_texture("run_right", 0)
    # Right movement mirrors the complete left-run cells instead of selecting
    # the damaged source's right-side atlas cells.
    assert(right_frame.region.position == Vector2(0, 0))
    assert(scene.squirrel.sprite_frames.get_frame_count("pop") == 3)
    assert(not scene.squirrel.sprite_frames.get_animation_loop("pop"))
    var pop_rise: AtlasTexture = scene.squirrel.sprite_frames.get_frame_texture("pop", 1)
    assert(pop_rise.region.position == Vector2(1536, 1024))
    var pop_idle: AtlasTexture = scene.squirrel.sprite_frames.get_frame_texture("pop", 2)
    assert(pop_idle.region.position == Vector2(0, 1024))
    scene._update_play(0.2)
    assert(not is_equal_approx(scene.squirrel.scale.x, scene.SQUIRREL_BASE_SCALE))
    assert(not is_equal_approx(scene.squirrel.position.y, scene.SQUIRREL_Y))
    scene._set_lane(4)
    scene._update_play(0.01)
    assert(scene.player_lane == 4 and scene.squirrel.animation == "run_right")
    assert(scene.squirrel.flip_h)
    assert(is_equal_approx(scene.squirrel.scale.x, scene.SQUIRREL_BASE_SCALE))
    assert(is_equal_approx(scene.squirrel.position.y, scene.SQUIRREL_Y) and is_zero_approx(scene.squirrel.rotation))
    scene._start_level(1)
    var mouse_press := InputEventMouseButton.new()
    mouse_press.button_index = MOUSE_BUTTON_LEFT
    mouse_press.pressed = true
    mouse_press.position = Vector2(scene.LANE_X[0], 1200.0)
    scene._unhandled_input(mouse_press)
    assert(scene.player_lane == 0)
    var mouse_motion := InputEventMouseMotion.new()
    mouse_motion.position = Vector2(scene.LANE_X[4], 1200.0)
    scene._unhandled_input(mouse_motion)
    assert(scene.player_lane == 4 and scene.player_target_x == scene.LANE_X[4])
    var mouse_release := InputEventMouseButton.new()
    mouse_release.button_index = MOUSE_BUTTON_LEFT
    mouse_release.pressed = false
    mouse_release.position = Vector2(scene.LANE_X[4], 1200.0)
    scene._unhandled_input(mouse_release)
    var screen_drag := InputEventScreenDrag.new()
    screen_drag.position = Vector2(scene.LANE_X[1], 1200.0)
    scene._unhandled_input(screen_drag)
    assert(scene.player_lane == 1 and scene.player_target_x == scene.LANE_X[1])
    scene._start_level(1)
    var blocked_lane: int = (scene.player_lane + 2) % 5
    scene.drops = [{"kind": "acorn", "lane": blocked_lane, "y": -120.0, "speed": scene.definition.base_speed}]
    assert(scene._replacement_lane() != blocked_lane)
    scene.drops.clear()
    scene._start_level(5)
    assert(scene.definition.theme.family == "pinecone" and scene.definition.theme.minor == "needle" and scene.item_textures.pinecone != null)
    assert(scene.needle_texture != null and scene._hazard_texture_for("needle") == scene.needle_texture and scene._hazard_texture_for("branch") == scene.branch_texture)
    scene._start_level(6)
    var scheduled_needles := 0
    for event in scene.events:
        assert(str(event.get("skin", "")) != "stick")
        if event.kind == "leaf":
            assert(event.skin != "branch")
            if event.skin == "needle": scheduled_needles += 1
    assert(scheduled_needles > 0)
    # Exhaust an authored hazard level without catching. The actual play loop
    # must queue complete deterministic cycles rather than target-only drops.
    scene._start_level(8)
    var authored_event_count: int = scene.events.size()
    var authored_end_time := float(scene.events.back().time)
    scene.elapsed = authored_end_time
    scene.event_cursor = authored_event_count
    scene._update_play(0.0)
    assert(scene.schedule_cycle == 1 and scene.events.size() == authored_event_count * 2)
    var continuation_has_leaf := false
    var continuation_has_limb := false
    for event in scene.scheduled_tail:
        continuation_has_leaf = continuation_has_leaf or event.kind == "leaf"
        continuation_has_limb = continuation_has_limb or event.kind == "limb"
    assert(continuation_has_leaf and continuation_has_limb)
    scene.elapsed = LevelData.cycle_duration(scene.definition) + authored_end_time
    scene._update_play(0.0)
    assert(scene.schedule_cycle >= 2 and scene.scheduled_tail.size() == authored_event_count)

    scene._start_level(9)
    assert(scene.definition.theme.minor == "snowflake" and scene.definition.theme.major == "icicle" and scene.hazard_texture != null)
    var warning_limb := {"kind":"limb", "phase":"warning", "base_x":scene.LANE_X[2], "x":scene.LANE_X[2], "y":-120.0,
        "warning":0.2, "age":0.0, "shadow":0.0, "width":1, "speed":500.0, "rotation":0.0, "wobble":0.0, "seed":0.0, "skin":"icicle"}
    assert(not scene._limb_is_visible(warning_limb) and not scene._limb_hits_player(warning_limb))
    var warning_label: Rect2 = scene._limb_warning_label_rect(warning_limb)
    var warning_shadow: Vector2 = scene._limb_warning_shadow_center(warning_limb)
    assert(warning_label.size.x >= 200.0 and warning_label.position.y < scene.GROUND_LINE_Y - 250.0)
    assert(warning_shadow.y < scene.GROUND_LINE_Y and absf(warning_shadow.x - scene.LANE_X[2]) < 1.0)
    scene._move_drop(warning_limb, 0.21)
    assert(scene._limb_is_visible(warning_limb) and warning_limb.y == -120.0 and not scene._limb_hits_player(warning_limb))
    scene._move_drop(warning_limb, 0.3)
    assert(absf(float(warning_limb.rotation) - scene.ICICLE_BASE_ROTATION) <= scene.ICICLE_WOBBLE_RADIANS + 0.001)
    var branch_limb := {"kind":"limb", "phase":"falling", "base_x":scene.LANE_X[2], "x":scene.LANE_X[2], "y":-120.0,
        "warning":1.35, "age":0.0, "shadow":1.0, "width":1, "speed":500.0, "rotation":0.0, "wobble":0.0, "seed":0.0, "skin":"branch"}
    for step in 8:
        scene._move_drop(branch_limb, 0.18)
        assert(absf(float(branch_limb.rotation) - scene.BRANCH_BASE_ROTATION) <= scene.BRANCH_WOBBLE_RADIANS + 0.001)
        assert(absf(float(branch_limb.x) - float(branch_limb.base_x)) <= scene.BRANCH_LATERAL_SWAY_PIXELS + 0.01)
    assert(scene._map_node_position(1).y > scene._map_node_position(10).y)
    assert(scene._map_node_position(1).x != scene._map_node_position(2).x)
    assert(scene.MAP_NODE_POSITIONS.size() == scene.MAP_PAGE_COUNT)
    assert(scene.MAP_NODE_POSITIONS[0].size() == scene.MAP_PAGE_LEVELS and scene.MAP_NODE_POSITIONS[1].size() == scene.MAP_PAGE_LEVELS)
    assert(scene._map_node_position(10).y >= 380.0)
    assert(scene._map_node_position(10).y > 400.0 and scene._map_node_position(1).y < 1700.0)
    for number in range(1, 21):
        var map_pos: Vector2 = scene._map_node_position(number)
        assert(map_pos.x > scene.MAP_NODE_RADIUS and map_pos.x < scene.W - scene.MAP_NODE_RADIUS)
        assert(map_pos.y > scene.SAFE_TOP + scene.MAP_NODE_RADIUS and map_pos.y < scene.H - scene.MAP_NODE_RADIUS)
        var label_rect: Rect2 = scene._map_label_rect(map_pos)
        assert(label_rect.position.x >= 0.0 and label_rect.end.x <= scene.W)
        assert(label_rect.position.y >= scene.SAFE_TOP and label_rect.end.y <= scene.H)
        if map_pos.x < scene.W * 0.5:
            assert(label_rect.end.x <= map_pos.x - scene.MAP_NODE_RADIUS - scene.MAP_LABEL_GAP + 0.01)
        else:
            assert(label_rect.position.x >= map_pos.x + scene.MAP_NODE_RADIUS + scene.MAP_LABEL_GAP - 0.01)
    scene.screen = "map"
    scene._process(0.0)
    assert(not scene.squirrel.visible)
    assert(scene.map_page == 1)
    scene.save_data.unlocked = 10
    assert(not scene._map_can_navigate(1) and not scene._map_can_navigate(-1))
    scene._map_click(scene.MAP_NEXT_RECT.get_center())
    assert(is_zero_approx(scene.crossing_time))
    scene.save_data.unlocked = 20
    assert(scene._map_can_navigate(1) and not scene._map_can_navigate(-1))
    var forward_path: PackedVector2Array = scene._map_crossing_path(true)
    assert(forward_path.size() == 4 and forward_path[0].x < forward_path[3].x and forward_path[1].y < forward_path[0].y)
    scene._map_click(scene.MAP_NEXT_RECT.get_center())
    assert(scene.crossing_time > 0.0)
    scene._update_map_crossing(0.01)
    assert(scene.squirrel.visible)
    scene._update_map_crossing(0.61)
    assert(scene.map_page == 2 and scene._map_node_position(11).y > scene._map_node_position(20).y)
    assert(scene._map_can_navigate(-1) and not scene._map_can_navigate(1))
    scene._map_click(scene.MAP_PREVIOUS_RECT.get_center())
    assert(scene.crossing_time > 0.0 and scene.crossing_target_page == 1)
    scene._update_map_crossing(0.61)
    assert(scene.map_page == 1)
    scene.screen = "settings"
    scene._process(0.0)
    assert(not scene.squirrel.visible)
    scene._start_level(1)
    scene._process(0.0)
    assert(scene.squirrel.visible)
    scene.logic.progress = 2
    scene._update_carry_stack()
    assert(scene.carry_sprites[0].visible and scene.carry_sprites[1].visible)
    assert(scene.carry_sprites[0].position.y < scene.SQUIRREL_Y - 50.0 and scene.carry_sprites[0].position.x > scene.player_x + 20.0)
    assert(scene.carry_sprites[0].z_index > scene.squirrel.z_index)
    scene._set_lane(4)
    scene.player_x = scene.LANE_X[4]
    scene._update_carry_stack()
    assert(scene.carry_sprites[0].position.x < scene.player_x and scene.carry_sprites[0].position.x < scene.PLAY_RIGHT)
    scene._limb_hit({})
    assert(scene.screen == "recover" and scene.recover_phase == 0)
    assert(is_equal_approx(scene.squirrel.scale.x, scene.SQUIRREL_BASE_SCALE))
    assert(is_equal_approx(scene.squirrel.position.y, scene.SQUIRREL_Y) and is_zero_approx(scene.squirrel.rotation))
    scene.squirrel.frame = scene.squirrel.sprite_frames.get_frame_count("flatten") - 1
    scene._update_recovery(0.0)
    assert(scene.recover_phase == 1 and scene.squirrel.animation == "flatten")
    scene._update_recovery(scene.FLATTEN_HOLD_SECONDS - 0.01)
    assert(scene.recover_phase == 1 and scene.squirrel.animation == "flatten")
    scene._update_recovery(0.02)
    assert(scene.recover_phase == 2 and scene.squirrel.animation == "pop")
    scene.paused = true
    assert(scene.paused)
    scene._pause_click(Vector2(300, 850))
    assert(not scene.paused)
    var original_music: bool = scene.save_data.music
    scene.screen = "settings"
    scene._settings_click(Vector2(300, 650))
    assert(scene.save_data.music != original_music)
    scene._settings_click(Vector2(10, 10))
    assert(scene.screen == "map")
    scene._start_level(1)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    assert(int(scene.save_data.unlocked) >= 2)
    for n in range(1,21):
        scene._start_level(n)
        assert(scene.logic.recipe.size() == (3 if n <= 3 else 4 if n <= 7 else 5))
    scene._start_level(99)
    assert(scene.level_number == 50 and scene.definition.number == 50)
    scene.screen = "title"
    scene._process(0.0)
    assert(scene.title_squirrel.visible and not scene.squirrel.visible)
    assert(absf(scene._title_squirrel_visual_rect().end.y - scene.GROUND_LINE_Y) <= 1.5)
    scene._start_level(8)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    scene._process(0.0)
    assert(scene.screen == "results" and scene.results_squirrel.visible and not scene.squirrel.visible)
    assert(scene.results_squirrel.texture == scene.results_squirrel_texture)
    assert(scene.results_squirrel.texture.resource_path == "res://assets/art/squirrel_idle_full_v2.png")
    assert(scene.results_squirrel.position == scene.RESULTS_SQUIRREL_POSITION)
    assert(is_equal_approx(scene.results_squirrel.scale.x, scene.RESULTS_SQUIRREL_SCALE))
    assert(scene.RESULTS_SQUIRREL_SCALE >= 0.40 and scene.RESULTS_SQUIRREL_SCALE <= 0.45)
    var result_visual: Rect2 = scene._results_squirrel_visual_rect()
    assert(scene.RESULTS_PANEL_RECT.encloses(result_visual))
    var medallion_bounds := Rect2(scene.RESULTS_MEDALLION_CENTER - Vector2.ONE * scene.RESULTS_MEDALLION_RADIUS, Vector2.ONE * scene.RESULTS_MEDALLION_RADIUS * 2.0)
    assert(medallion_bounds.encloses(result_visual))
    assert(result_visual.position.y >= medallion_bounds.position.y + scene.RESULTS_SQUIRREL_HEADROOM)
    assert(result_visual.end.y <= medallion_bounds.end.y - scene.RESULTS_SQUIRREL_HEADROOM)
    assert(result_visual.size.y >= scene.RESULTS_MEDALLION_RADIUS * 1.2)
    assert(absf(result_visual.get_center().y - scene.RESULTS_MEDALLION_CENTER.y) <= 35.0)
    for rect in scene.RESULTS_BUTTON_RECTS:
        assert(rect.size.y >= 76.0 and rect.size.x >= 76.0)
        assert(scene.RESULTS_PANEL_RECT.encloses(rect))
    assert(not scene.RESULTS_BUTTON_RECTS[0].intersects(scene.RESULTS_BUTTON_RECTS[1]))
    assert(not scene.RESULTS_BUTTON_RECTS[1].intersects(scene.RESULTS_BUTTON_RECTS[2]))
    for i in scene.logic.recipe.size():
        assert(scene.carry_sprites[i].visible and scene.carry_sprites[i].z_index > scene.results_squirrel.z_index)
        assert(scene.carry_sprites[i].position.y > scene.SAFE_TOP and scene.carry_sprites[i].position.y < scene.RESULTS_RIBBON_RECT.position.y)
        assert(scene.RESULTS_PANEL_RECT.encloses(Rect2(scene.carry_sprites[i].position - Vector2.ONE * scene.RESULTS_CARRY_SIZE * 0.5, Vector2.ONE * scene.RESULTS_CARRY_SIZE)))
        assert(scene.carry_sprites[i].position.distance_to(scene.RESULTS_MEDALLION_CENTER) <= scene.RESULTS_MEDALLION_RADIUS - scene.RESULTS_CARRY_SIZE * 0.5)
    assert(scene.carry_sprites[0].position.y > result_visual.get_center().y + 65.0)
    scene._results_click(scene.RESULTS_BUTTON_RECTS[0].get_center())
    assert(scene.screen == "play" and scene.level_number == 9)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    scene._results_click(scene.RESULTS_BUTTON_RECTS[1].get_center())
    assert(scene.screen == "play" and scene.level_number == 9)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    scene._results_click(scene.RESULTS_BUTTON_RECTS[2].get_center())
    assert(scene.screen == "map")
    scene._start_level(20)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    scene._results_click(scene.RESULTS_BUTTON_RECTS[0].get_center())
    assert(scene.screen == "play" and scene.level_number == 21)

    # The expanded trail has five exact pages with ten reachable nodes each.
    assert(scene.MAP_PAGE_COUNT == 5 and scene.MAP_NODE_POSITIONS.size() == 5)
    for page_positions in scene.MAP_NODE_POSITIONS:
        assert(page_positions.size() == scene.MAP_PAGE_LEVELS)
    for number in range(1, 51):
        var canopy_map_pos: Vector2 = scene._map_node_position(number)
        assert(canopy_map_pos.x > scene.MAP_NODE_RADIUS and canopy_map_pos.x < scene.W - scene.MAP_NODE_RADIUS)
        assert(canopy_map_pos.y > scene.SAFE_TOP + scene.MAP_NODE_RADIUS and canopy_map_pos.y < scene.H - scene.MAP_NODE_RADIUS)
    scene.map_page = 1; scene.save_data.unlocked = 10
    assert(not scene._map_can_navigate(1))
    scene.save_data.unlocked = 11
    assert(scene._map_can_navigate(1))
    scene.map_page = 2; scene.save_data.unlocked = 20
    assert(not scene._map_can_navigate(1) and scene._map_can_navigate(-1))
    scene.save_data.unlocked = 21
    assert(scene._map_can_navigate(1))
    scene.map_page = 3; scene.save_data.unlocked = 31
    assert(scene._map_can_navigate(1))
    scene.map_page = 4; scene.save_data.unlocked = 41
    assert(scene._map_can_navigate(1))
    scene.map_page = 5; scene.save_data.unlocked = 50
    assert(not scene._map_can_navigate(1) and scene._map_can_navigate(-1))

    for canopy_level in range(21, 51):
        scene._start_level(canopy_level)
        assert(scene.level_number == canopy_level and scene.definition.number == canopy_level)
        assert(scene.logic.recipe.size() == 5)
    scene._start_level(99)
    assert(scene.level_number == 50 and scene.definition.number == 50)

    # A gust resolves once and moves only eligible collectibles one adjacent lane.
    scene._start_level(30)
    var gust_acorn := {"kind":"acorn", "phase":"falling", "lane":2, "base_x":scene.LANE_X[2], "x":scene.LANE_X[2]}
    var gust_leaf := {"kind":"leaf", "phase":"falling", "lane":3, "base_x":scene.LANE_X[3], "x":scene.LANE_X[3]}
    var gust_boundary := {"kind":"acorn", "phase":"falling", "lane":4, "base_x":scene.LANE_X[4], "x":scene.LANE_X[4]}
    var gust_predator := {"kind":"predator", "phase":"falling", "lane":1, "base_x":scene.LANE_X[1], "x":scene.LANE_X[1]}
    var gust_limb := {"kind":"limb", "phase":"falling", "lane":1, "base_x":scene.LANE_X[1], "x":scene.LANE_X[1]}
    assert(scene._gust_eligible(gust_acorn, 1) and scene._gust_eligible(gust_leaf, 1))
    assert(not scene._gust_eligible(gust_boundary, 1) and not scene._gust_eligible(gust_predator, 1) and not scene._gust_eligible(gust_limb, 1))
    scene.drops = [gust_acorn, gust_leaf, gust_boundary, gust_predator, gust_limb]
    scene._resolve_gust(1)
    assert(gust_acorn.lane == 3 and gust_leaf.lane == 4)
    assert(gust_acorn.base_x == scene.LANE_X[3] and gust_leaf.base_x == scene.LANE_X[4])
    assert(gust_boundary.lane == 4 and gust_predator.lane == 1 and gust_limb.lane == 1)
    var warning_gust := {"kind":"gust", "phase":"warning", "warning":0.2, "duration":0.3, "direction":-1, "age":0.0, "y":-120.0}
    scene.drops = [gust_acorn, warning_gust]
    scene._move_drop(warning_gust, 0.21)
    assert(warning_gust.phase == "active" and gust_acorn.lane == 2)
    scene._move_drop(warning_gust, 0.1)
    assert(gust_acorn.lane == 2)

    # Predators approach visibly and swoop one immutable lane, then restart the recipe.
    scene._start_level(35)
    var predator := {"kind":"predator", "phase":"warning", "warning":1.4, "age":0.0, "y":-120.0, "speed":600.0,
        "lane":2, "base_x":scene.LANE_X[2], "x":scene.LANE_X[2], "skin":"hawk"}
    scene._move_drop(predator, 0.7)
    assert(predator.y > -120.0 and predator.y < 220.0 and predator.lane == 2 and predator.x == scene.LANE_X[2])
    scene._move_drop(predator, 0.71)
    assert(predator.phase == "falling" and predator.lane == 2 and predator.x == scene.LANE_X[2])
    scene._move_drop(predator, 0.1)
    assert(predator.lane == 2 and predator.x == scene.LANE_X[2])
    scene.logic.progress = 2
    predator.y = scene._play_surface_y() - 90.0
    assert(scene._limb_hits_player(predator))
    scene._limb_hit(predator)
    assert(scene.screen == "recover" and scene.logic.restarted and scene.logic.progress == 0 and scene.level_number == 35)
    scene.recover_phase = 2; scene.recover_time = scene.POP_RECOVERY_SECONDS
    scene._update_recovery(0.0)
    assert(scene.screen == "play" and not scene.logic.restarted and scene.level_number == 35)

    # Painted-ground levels and the new day limb are stationary; later canopy limbs sway coherently and gently.
    scene._start_level(20)
    assert(not bool(scene.definition.theme.get("play_limb", false)))
    scene._start_level(24)
    scene.elapsed = 1.0
    assert(scene.definition.theme.play_limb and scene.definition.theme.play_limb_skin == "day")
    assert(scene._play_limb_texture_for(scene.definition.theme) == scene.play_limb_day_texture)
    assert(is_equal_approx(scene._play_surface_y(), scene.GROUND_LINE_Y))
    scene._start_level(36)
    scene.elapsed = 0.0
    var surface_start: float = scene._play_surface_y()
    scene.elapsed = PI / (2.0 * 1.65)
    var surface_peak: float = scene._play_surface_y()
    assert(absf(surface_peak - surface_start) > 10.0 and absf(surface_peak - scene.GROUND_LINE_Y) <= 16.1)
    assert(scene.definition.theme.play_limb_skin == "sway")
    assert(scene._play_limb_texture_for(scene.definition.theme) == scene.play_limb_texture)
    scene._reset_squirrel_visual()
    assert(is_equal_approx(scene.squirrel.position.y, surface_peak - scene.SQUIRREL_FOOT_OFFSET))
    assert(scene.play_limb_day_texture != null and scene.play_limb_texture != null and scene.hawk_texture != null and scene.owl_texture != null)
    assert(scene.firefly_swarm_texture != null and scene.lightning_fx_texture != null)

    # Night fireflies occupy five staggered upper-canopy lanes and never follow the squirrel.
    scene._start_level(45)
    assert(scene.definition.theme.night and scene.definition.theme.fireflies)
    scene.elapsed = 0.0
    scene.player_lane = 0; scene.player_x = scene.LANE_X[0]
    var lights_player_left: Array[Vector2] = scene._firefly_centers()
    scene.player_lane = 4; scene.player_x = scene.LANE_X[4]
    var lights_player_right: Array[Vector2] = scene._firefly_centers()
    assert(lights_player_left == lights_player_right)
    var lights_a: Array[Vector2] = lights_player_left
    scene.elapsed = 1.6
    var lights_b: Array[Vector2] = scene._firefly_centers()
    assert(lights_a.size() == scene.LANE_X.size() and lights_a.size() == 5)
    assert(is_equal_approx(scene.FIREFLY_LIGHT_RADIUS, 520.0))
    for lane in lights_a.size():
        var lane_left: float = 70.0 if lane == 0 else (scene.LANE_X[lane - 1] + scene.LANE_X[lane]) * 0.5 + 12.0
        var lane_right: float = scene.PLAY_RIGHT - 70.0 if lane == lights_a.size() - 1 else (scene.LANE_X[lane] + scene.LANE_X[lane + 1]) * 0.5 - 12.0
        assert(lights_a[lane].x >= lane_left and lights_a[lane].x <= lane_right)
        assert(lights_a[lane].y >= scene.SAFE_TOP + 150.0 and lights_a[lane].y <= 900.0)
        assert(lights_a[lane].distance_to(lights_b[lane]) > 20.0)
    assert(lights_a[0].y < lights_a[1].y and lights_a[2].y < lights_a[1].y)
    assert(lights_a[2].y < lights_a[3].y and lights_a[4].y < lights_a[3].y)
    scene.elapsed = 0.0
    var light_center: Vector2 = scene._firefly_centers()[0]
    var cluster_center := Vector2.ZERO
    for index in range(1, 5): cluster_center += scene._firefly_centers()[index]
    cluster_center /= 4.0
    var away_from_cluster: Vector2 = (light_center - cluster_center).normalized()
    var midpoint: Vector2 = light_center + away_from_cluster * scene.FIREFLY_LIGHT_RADIUS * 0.5
    var far_dark_point := Vector2(scene.LANE_X[2], scene._play_surface_y() - 80.0)
    var center_visibility: float = scene._night_visibility_at(light_center)
    var midpoint_visibility: float = scene._night_visibility_at(midpoint)
    assert(center_visibility > 0.99)
    assert(midpoint_visibility < center_visibility and midpoint_visibility > scene.NIGHT_BASE_VISIBILITY + 0.15)
    assert(scene._night_visibility_at(far_dark_point) <= scene.NIGHT_BASE_VISIBILITY + 0.01)
    assert(scene._night_world_modulate(far_dark_point).r < 0.30)
    scene.lightning_flash = LevelData.LIGHTNING_FLASH_DURATION
    assert(is_equal_approx(scene._night_visibility_at(far_dark_point), 1.0))
    scene.lightning_flash = 0.0
    scene._start_level(46)
    assert(scene.definition.theme.lightning and not bool(scene.definition.theme.get("night", false)) and not bool(scene.definition.theme.get("fireflies", false)))
    var storm_dark_point := Vector2(scene.LANE_X[2], 700.0)
    assert(scene._night_visibility_at(storm_dark_point) <= scene.NIGHT_BASE_VISIBILITY + 0.01)
    assert(scene._night_world_modulate(storm_dark_point).r < 0.30)
    scene.lightning_flash = LevelData.LIGHTNING_FLASH_DURATION
    assert(is_equal_approx(scene._night_visibility_at(storm_dark_point), 1.0))
    scene.lightning_flash = 0.0
    scene._start_level(50)
    assert(scene.definition.theme.lightning and scene.definition.theme.finale_stage == 5)
    assert(scene._finale_stage_label() == "FINALE PHASE 1 / 5")
    scene.logic.progress = 2
    assert(scene._finale_stage_label() == "FINALE PHASE 3 / 5")
    var flash_collectible := {"kind":"acorn", "phase":"falling", "lane":2, "base_x":scene.LANE_X[2], "x":scene.LANE_X[2]}
    scene.drops.clear()
    scene._spawn_event({"kind":"lightning", "warning":LevelData.LIGHTNING_WARNING_DURATION, "duration":LevelData.LIGHTNING_FLASH_DURATION, "variant":2})
    var lightning: Dictionary = scene.drops[0]
    scene.drops.append(flash_collectible)
    assert(lightning.variant == 2)
    var layout_two: Array[Rect2] = scene._lightning_bolt_rects()
    lightning.variant = 0
    var layout_zero: Array[Rect2] = scene._lightning_bolt_rects()
    lightning.variant = 1
    var layout_one: Array[Rect2] = scene._lightning_bolt_rects()
    lightning.variant = 2
    assert(layout_zero.size() == 2 and layout_one.size() == 2 and layout_two.size() == 3)
    assert(layout_zero != layout_one and layout_one != layout_two and layout_zero != layout_two)
    var bolt_centers := {}
    for bolt_rect in layout_two: bolt_centers[bolt_rect.get_center()] = true
    assert(bolt_centers.size() == 3)
    scene.lightning_flash = 0.0
    scene._move_drop(lightning, LevelData.LIGHTNING_WARNING_DURATION * 0.5)
    assert(lightning.phase == "warning" and is_zero_approx(scene.lightning_flash) and flash_collectible.lane == 2)
    assert(scene._lightning_warning_strength() >= 0.49 and scene._lightning_warning_strength() <= 0.51)
    scene._move_drop(lightning, LevelData.LIGHTNING_WARNING_DURATION * 0.5 + 0.01)
    assert(lightning.phase == "active" and is_equal_approx(scene.lightning_flash, LevelData.LIGHTNING_FLASH_DURATION) and flash_collectible.lane == 2)
    scene._start_level(50)
    assert(is_zero_approx(scene.lightning_flash) and scene.drops.is_empty())

    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    scene._results_click(scene.RESULTS_BUTTON_RECTS[0].get_center())
    assert(scene.screen == "results" and scene.level_number == 50 and int(scene.save_data.unlocked) == 50)
    scene.free()
    packed = null
    await process_frame
    print("RUNTIME_SMOKE_PASS")
    quit()
