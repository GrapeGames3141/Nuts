extends SceneTree


func _init() -> void:
	var config := ConfigFile.new()
	assert(config.load("res://export_presets.cfg") == OK)
	assert(config.get_value("preset.0", "exclude_filter", "") == "build/**")
	assert(config.get_value("preset.0.options", "version/code", 0) == 11)
	assert(config.get_value("preset.0.options", "version/name", "") == "1.0.10")
	assert(config.get_value("preset.0.options", "launcher_icons/main_192x192", "") == "res://assets/art/game_icon.png")
	var project := ConfigFile.new()
	assert(project.load("res://project.godot") == OK)
	assert(project.get_value("application", "config/icon", "") == "res://assets/art/game_icon.png")
	assert(ResourceLoader.exists("res://assets/art/seasonal/tree_trail_real_v1.png"))
	assert(ResourceLoader.exists("res://assets/art/seasonal/tree_trail_real_v2.png"))
	print("EXPORT_CONFIG_TEST_PASS")
	quit()
