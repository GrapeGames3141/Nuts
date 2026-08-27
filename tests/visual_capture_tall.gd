extends SceneTree

# Offscreen tall-device capture. The desktop window compositor clips 720x1600
# windows to 1280 px high, so render this one target in an exact SubViewport.
const TARGET := Vector2i(720, 1600)
const REFERENCE := Vector2(1080.0, 1920.0)

func _capture(scene: Node, label: String) -> void:
    await process_frame
    await process_frame
    var viewport := scene.get_parent() as SubViewport
    var image := viewport.get_texture().get_image()
    assert(image.get_size() == TARGET)
    image.save_png("user://qa/%s_720x1600.png" % label)

func _init() -> void:
    DirAccess.make_dir_absolute("user://qa")
    var viewport := SubViewport.new()
    viewport.size = TARGET
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    viewport.transparent_bg = false
    root.add_child(viewport)
    var packed: PackedScene = load("res://scenes/main.tscn")
    var scene: Node2D = packed.instantiate()
    # This intentionally follows the project's responsive-fill tradeoff for
    # a tall notched device, while retaining the 1080x1920 reference layout.
    scene.scale = Vector2(TARGET.x / REFERENCE.x, TARGET.y / REFERENCE.y)
    viewport.add_child(scene)
    await process_frame
    scene.save_data.unlocked = 20
    scene.screen = "title"; await _capture(scene, "title")
    scene.screen = "map"; scene.map_page = 1; await _capture(scene, "tree1")
    scene._begin_tree_crossing(2)
    scene._update_map_crossing(0.25); await _capture(scene, "crossing")
    scene._update_map_crossing(1.0); await _capture(scene, "tree2")
    scene.screen = "settings"; await _capture(scene, "settings")
    scene._start_level(1); await _capture(scene, "play01")
    scene._start_level(6)
    scene.drops = [{"kind":"leaf", "skin":"needle", "variant":0, "x":scene.LANE_X[2], "base_x":scene.LANE_X[2], "y":710.0,
        "speed":0.0, "rotation":0.34, "scale":1.0, "wobble":0.0, "seed":0.0, "age":0.0}]
    await _capture(scene, "level06_needles")
    scene.drops = [{"kind":"leaf", "skin":"leaf", "variant":3, "x":scene.LANE_X[2], "base_x":scene.LANE_X[2], "y":710.0, "speed":0.0, "rotation":0.18, "scale":1.0, "wobble":0.0, "seed":0.0, "age":0.0}]
    await _capture(scene, "leaf_yellow_clean")
    scene.drops.clear()
    scene.paused = true; await _capture(scene, "pause")
    scene.paused = false
    scene._start_level(4)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    await _capture(scene, "results_acorn")
    scene._start_level(19)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    await _capture(scene, "results_winter_pinecone")
    scene._start_level(8)
    scene.drops = [{"kind":"limb", "phase":"warning", "base_x":scene.LANE_X[0], "x":scene.LANE_X[0], "y":-120.0,
        "warning":1.35, "age":1.0, "shadow":1.0, "width":1, "speed":500.0, "rotation":0.0, "wobble":0.0, "seed":0.0, "skin":"branch", "variant":-1}]
    await _capture(scene, "limb_warning")
    scene.drops[0].phase = "falling"; scene.drops[0].y = 320.0; await _capture(scene, "limb_active")
    scene._start_level(9)
    scene.drops = [{"kind":"limb", "phase":"falling", "base_x":scene.LANE_X[2], "x":scene.LANE_X[2], "y":360.0,
        "warning":1.35, "age":0.45, "shadow":1.0, "width":1, "speed":500.0, "rotation":0.02, "wobble":0.0, "seed":0.0, "skin":"icicle", "variant":-1}]
    await _capture(scene, "icicle_fall")
    scene._start_level(8); scene._limb_hit({}); await _capture(scene, "flatten")
    scene.squirrel.frame = 1; scene._update_recovery(0.0); await _capture(scene, "recovery")
    print("VISUAL_CAPTURE_TALL_PASS user://qa")
    quit()
