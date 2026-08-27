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
    scene._start_level(4)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    await _capture(scene, "results_acorn")
    scene._start_level(19)
    scene.logic.progress = scene.logic.recipe.size()
    scene._finish_level()
    await _capture(scene, "results_winter_pinecone")
    print("VISUAL_CAPTURE_TALL_PASS user://qa")
    quit()
