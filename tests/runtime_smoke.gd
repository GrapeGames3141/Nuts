extends SceneTree
func _init() -> void:
    var packed: PackedScene = load("res://scenes/main.tscn")
    var scene: Variant = packed.instantiate()
    root.add_child(scene)
    await process_frame
    scene._start_level(1)
    assert(scene.screen == "play")
    scene._set_lane(4)
    assert(scene.player_lane == 4)
    assert(scene.squirrel.sprite_frames.has_animation("idle"))
    assert(scene.squirrel.sprite_frames.has_animation("run_left"))
    assert(scene.squirrel.sprite_frames.has_animation("run_right"))
    assert(scene.squirrel.sprite_frames.has_animation("flatten"))
    assert(scene.squirrel.sprite_frames.has_animation("pop"))
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
    for n in range(1,11):
        scene._start_level(n)
        assert(scene.logic.recipe.size() == (3 if n <= 3 else 4 if n <= 7 else 5))
    print("RUNTIME_SMOKE_PASS")
    quit()
