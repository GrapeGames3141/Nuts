extends SceneTree


func _init() -> void:
	var config := ConfigFile.new()
	assert(config.load("res://export_presets.cfg") == OK)
	assert(config.get_value("preset.0", "exclude_filter", "") == "build/**")
	print("EXPORT_CONFIG_TEST_PASS")
	quit()
