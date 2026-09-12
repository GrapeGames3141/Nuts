extends SceneTree

# Play Store phone screenshot harness. Renders marketing-facing game states at
# Play's 9:16 phone size into user://store. Needs a real display (not headless).
const SIZE := Vector2i(1080, 1920)

var _scene: Node


func _capture(label: String) -> void:
    _scene.queue_redraw()
    await process_frame
    await process_frame
    var image := root.get_texture().get_image()
    if image == null:
        print("CAPTURE_UNAVAILABLE ", label)
        return
    image.save_png("user://store/%s.png" % label)
    print("captured ", label)


func _init() -> void:
    DirAccess.make_dir_absolute("user://store")
    root.size = SIZE
    var packed: PackedScene = load("res://scenes/main.tscn")
    _scene = packed.instantiate()
    root.add_child(_scene)
    await process_frame
    _scene.save_data.unlocked = 50

    _scene.screen = "title"
    await _capture("01_title")

    _scene._start_level(11)
    _scene.logic.progress = 3
    _scene._update_carry_stack()
    _scene._spawn_event({"kind": "acorn", "family": "acorn", "variant": _scene.logic.current_variant(), "lane": 3, "speed": 620.0})
    _scene.drops[0].y = 720.0
    await _capture("02_stack_the_acorns")

    _scene.screen = "map"
    _scene.map_page = 3
    await _capture("03_fifty_levels")

    _scene._start_level(30)
    _scene._spawn_event({"kind": "acorn", "family": "pinecone", "variant": _scene.logic.current_variant(), "lane": 2, "speed": 620.0})
    _scene.drops[0].y = 690.0
    _scene._spawn_event({"kind": "gust", "warning": 1.05, "duration": 0.38, "direction": 1})
    _scene.drops[1].age = 0.55
    await _capture("04_dodge_the_gusts")

    _scene._start_level(35)
    _scene._spawn_event({"kind": "predator", "skin": "hawk", "lane": 2, "speed": 650.0, "warning": 1.45})
    _scene.drops[0].phase = "falling"
    _scene.drops[0].y = 520.0
    await _capture("05_watch_the_hawk")

    _scene._start_level(45)
    _scene.elapsed = 0.0
    _scene._spawn_event({"kind": "acorn", "family": "acorn", "variant": _scene.logic.current_variant(), "lane": 4, "speed": 620.0})
    _scene.drops[0].y = _scene._firefly_centers()[4].y + 120.0
    await _capture("06_firefly_nights")

    _scene._start_level(9)
    _scene.drops = [{"kind": "limb", "phase": "falling", "base_x": _scene.LANE_X[3], "x": _scene.LANE_X[3], "y": 420.0,
        "warning": 1.35, "age": 0.45, "shadow": 1.0, "width": 1, "speed": 500.0, "rotation": 0.02,
        "wobble": 0.0, "seed": 0.0, "skin": "icicle", "variant": -1}]
    await _capture("07_winter_hazards")

    _scene._start_level(19)
    _scene.logic.progress = _scene.logic.recipe.size()
    _scene._finish_level()
    await _capture("08_perfect_run")

    _scene.free()
    await process_frame
    print("STORE_CAPTURE_PASS user://store")
    quit()
