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
    scene.save_data.unlocked = 20
    for size in SIZES:
        scene.screen = "title"; await capture(scene, "title", size)
        scene.screen = "map"; scene.map_page = 1; await capture(scene, "tree1", size)
        scene._begin_tree_crossing(2); scene._update_map_crossing(0.25); await capture(scene, "crossing", size)
        scene._update_map_crossing(1.0); await capture(scene, "tree2", size)
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
        scene.paused = true; await capture(scene, "pause", size)
        scene.paused = false
        scene._start_level(4); scene.logic.progress = scene.logic.recipe.size(); scene._finish_level(); await capture(scene, "results_acorn", size)
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
    print("VISUAL_CAPTURE_PASS user://qa")
    quit()
