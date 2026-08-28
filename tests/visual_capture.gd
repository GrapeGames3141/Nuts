extends SceneTree

# Deterministic screenshot harness.  Run with an E:-redirected --user-data-dir;
# captures land in user://qa and exercise every presentation state at each size.
const SIZES := [Vector2i(576, 1024), Vector2i(1080, 1920), Vector2i(720, 1600)]

func capture(scene: Node, label: String, size: Vector2i) -> void:
    root.size = size
    scene.queue_redraw()
    await process_frame
    await process_frame
    var image := root.get_texture().get_image()
    if image != null:
        image.save_png("user://qa/%s_%dx%d.png" % [label, size.x, size.y])
    else:
        print("CAPTURE_UNAVAILABLE ", label, " ", size)

func _init() -> void:
    DirAccess.make_dir_absolute("user://qa")
    var packed: PackedScene = load("res://scenes/main.tscn")
    var scene: Node = packed.instantiate()
    root.add_child(scene)
    await process_frame
    scene.save_data.unlocked = 50
    for size in SIZES:
        scene.screen = "title"; await capture(scene, "title", size)
        scene.screen = "map"; scene.map_page = 1; await capture(scene, "tree1", size)
        scene._begin_tree_crossing(2); scene._update_map_crossing(0.25); await capture(scene, "crossing", size)
        scene._update_map_crossing(1.0); await capture(scene, "tree2", size)
        scene.screen = "map"; scene.map_page = 3; await capture(scene, "tree3", size)
        scene.map_page = 4; await capture(scene, "tree4", size)
        scene.map_page = 5; await capture(scene, "tree5", size)
        scene.validation_ad_reserve = 140.0
        scene.screen = "title"; scene._apply_screen_squirrel(); await capture(scene, "title_ad_reserve", size)
        scene.screen = "map"; scene.map_page = 5; await capture(scene, "tree5_ad_reserve", size)
        scene._start_level(24); await capture(scene, "play24_ad_reserve", size)
        scene.logic.progress = scene.logic.recipe.size(); scene._finish_level(); await capture(scene, "results_ad_reserve", size)
        scene.validation_ad_reserve = 0.0
        scene.screen = "settings"; await capture(scene, "settings", size)
        scene._start_level(1); await capture(scene, "play01", size)
        scene._start_level(6)
        scene.drops = [{"kind":"leaf", "skin":"needle", "variant":0, "x":scene.LANE_X[2], "base_x":scene.LANE_X[2], "y":710.0,
            "speed":0.0, "rotation":0.34, "scale":1.0, "wobble":0.0, "seed":0.0, "age":0.0}]
        await capture(scene, "level06_needles", size)
        scene.drops = [{"kind":"leaf", "skin":"leaf", "variant":3, "x":scene.LANE_X[2], "base_x":scene.LANE_X[2], "y":710.0, "speed":0.0, "rotation":0.18, "scale":1.0, "wobble":0.0, "seed":0.0, "age":0.0}]
        await capture(scene, "leaf_yellow_clean", size)
        scene.drops.clear()
        scene.logic.progress = 1; scene._update_carry_stack(); await capture(scene, "carry1", size)
        scene._start_level(11); await capture(scene, "play11", size)
        scene.logic.progress = 5; scene._update_carry_stack(); await capture(scene, "carry5", size)
        scene._start_level(20); await capture(scene, "play20", size)
        scene._start_level(24); await capture(scene, "play24_stationary_limb", size)
        scene._start_level(25)
        scene._spawn_event({"kind":"acorn", "family":"acorn", "variant":0, "lane":1, "speed":420.0})
        scene._spawn_event({"kind":"acorn", "family":"acorn", "variant":2, "lane":3, "speed":860.0})
        scene.drops[0].y = 520.0; scene.drops[1].y = 850.0
        await capture(scene, "play25_mixed_speeds", size)
        scene._start_level(30)
        scene._spawn_event({"kind":"acorn", "family":"pinecone", "variant":scene.logic.current_variant(), "lane":2, "speed":620.0})
        scene.drops[0].y = 690.0
        scene._spawn_event({"kind":"gust", "warning":1.05, "duration":0.38, "direction":1})
        scene.drops[1].age = 0.55
        await capture(scene, "play30_gust_warning", size)
        scene._move_drop(scene.drops[1], 0.51)
        await capture(scene, "play30_gust_resolved", size)
        scene._start_level(35)
        scene._spawn_event({"kind":"predator", "skin":"hawk", "lane":2, "speed":650.0, "warning":1.45})
        scene.drops[0].age = 0.72; scene._move_drop(scene.drops[0], 0.0)
        await capture(scene, "play35_predator_approach", size)
        scene.drops[0].phase = "falling"; scene.drops[0].y = 520.0
        await capture(scene, "play35_predator_swoop", size)
        scene._start_level(40); scene.elapsed = PI / (2.0 * 1.65)
        await capture(scene, "play40_swaying_limb", size)
        scene._start_level(45)
        scene.elapsed = 0.0
        scene._spawn_event({"kind":"acorn", "family":"acorn", "variant":scene.logic.current_variant(), "lane":4, "speed":620.0})
        scene.drops[0].y = scene._firefly_centers()[4].y + 120.0
        scene._spawn_event({"kind":"acorn", "family":"acorn", "variant":(scene.logic.current_variant() + 1) % 4, "lane":0, "speed":560.0})
        scene.drops[1].y = scene._play_surface_y() - 100.0
        await capture(scene, "play45_firefly_night", size)
        scene._start_level(46)
        scene._spawn_event({"kind":"lightning", "warning":LevelData.LIGHTNING_WARNING_DURATION, "duration":LevelData.LIGHTNING_FLASH_DURATION, "variant":2})
        scene.drops[0].age = 0.42
        scene._spawn_event({"kind":"acorn", "family":"pinecone", "variant":scene.logic.current_variant(), "lane":2, "speed":620.0})
        scene.drops[1].y = 700.0
        await capture(scene, "play46_lightning_warning_dark", size)
        scene._move_drop(scene.drops[0], 0.44)
        await capture(scene, "play46_lightning_flash", size)
        scene._start_level(50)
        scene.logic.progress = 3
        await capture(scene, "play50_finale_phase4", size)
        scene.paused = true; await capture(scene, "pause", size)
        scene.paused = false
        scene._start_level(4); scene.logic.progress = scene.logic.recipe.size(); scene._finish_level(); await capture(scene, "results_acorn", size)
        await capture(scene, "results_full_ears", size)
        await capture(scene, "results_ring_focus", size)
        scene._start_level(19); scene.logic.progress = scene.logic.recipe.size(); scene._finish_level(); await capture(scene, "results_winter_pinecone", size)
        scene._start_level(8)
        # Keep the full-strength warning safely below its phase threshold during
        # the two awaited frames, and place it away from the player for QA.
        scene.drops = [{"kind":"limb", "phase":"warning", "base_x":scene.LANE_X[0], "x":scene.LANE_X[0], "y":-120.0,
            "warning":1.35, "age":1.0, "shadow":1.0, "width":1, "speed":500.0, "rotation":0.0, "wobble":0.0, "seed":0.0, "skin":"branch", "variant":-1}]
        await capture(scene, "limb_warning", size)
        scene.drops[0].phase = "falling"; scene.drops[0].y = 320.0; await capture(scene, "limb_active", size)
        scene._start_level(9)
        scene.drops = [{"kind":"limb", "phase":"falling", "base_x":scene.LANE_X[2], "x":scene.LANE_X[2], "y":360.0,
            "warning":1.35, "age":0.45, "shadow":1.0, "width":1, "speed":500.0, "rotation":0.02, "wobble":0.0, "seed":0.0, "skin":"icicle", "variant":-1}]
        await capture(scene, "icicle_fall", size)
        scene._start_level(8); scene._limb_hit({}); await capture(scene, "flatten", size)
        scene.squirrel.frame = 1; scene._update_recovery(0.0); await capture(scene, "recovery", size)
    scene.free()
    await process_frame
    print("VISUAL_CAPTURE_PASS user://qa")
    quit()
