extends Node

## Bottom banner via Poing AdMob (Android/iOS). Config: res://config/admob.json
## (see admob.example.json). Poing's native bottom view owns banner geometry.

const CONFIG_PATH := "res://config/admob.json"
const EXAMPLE_PATH := "res://config/admob.example.json"
const RELAYOUT_SETTLE_SECONDS := 0.22

# Closed-test / Play policy: serve Google's official test banner, not live ads.
const GOOGLE_TEST_ANDROID_BANNER_UNIT_ID := "ca-app-pub-3940256099942544/6300978111"
# TODO(ads-live): uncomment these and return them from banner_unit_id_for()
# when leaving closed test.
# const PEREGRINE_ANDROID_BANNER_UNIT_ID := "ca-app-pub-2846735043546429/6983531078"
# const PIGEON_ANDROID_BANNER_UNIT_ID := "ca-app-pub-2846735043546429/6675625496"

var _config: Dictionary = {}
var _ad_view: Variant
var _sdk_initialized := false
var _banner_logical_height := 60.0
var _loaded_placement := ""
var _relayout_generation := 0
var _keyboard_open := false


func _ready() -> void:
	_reload_config()
	if _platform_supports_ads() and ads_enabled():
		set_process(true)
		_initialize_mobile_ads()
	else:
		set_process(false)
	_connect_layout_signals()


func _exit_tree() -> void:
	detach()


func _process(_delta: float) -> void:
	if not _should_show_ads():
		return
	var keyboard_open := _keyboard_is_open()
	if keyboard_open and not _keyboard_open:
		_keyboard_open = true
		_hide_native_banner()
		return
	if _keyboard_open and not keyboard_open:
		_keyboard_open = false
		_schedule_relayout()
		return
	if keyboard_open:
		return
	if _placement_signature() != _loaded_placement:
		_schedule_relayout()


func _reload_config() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		_config = _parse_json_file(CONFIG_PATH)
	elif FileAccess.file_exists(EXAMPLE_PATH):
		_config = _parse_json_file(EXAMPLE_PATH)
	else:
		_config = {}
	_banner_logical_height = maxf(1.0, float(_config.get("banner_height_dp", 60.0)))


func _parse_json_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed if parsed is Dictionary else {}


func config() -> Dictionary:
	return _config


func ads_enabled() -> bool:
	if not bool(_config.get("ads_enabled", false)):
		return false
	match OS.get_name():
		"Android":
			return bool(_config.get("android_ads_enabled", true))
		"iOS":
			# iOS native binaries and privacy configuration are still explicit
			# release work; do not reserve a blank bar until that integration lands.
			return bool(_config.get("ios_ads_enabled", false))
		_:
			return true


func native_banner_height() -> float:
	# Diagnostics only: Poing owns this native creative outside Godot's content surface.
	return _banner_logical_height if _should_show_ads() else 0.0


func game_content_reserve_height() -> float:
	# AdPosition.BOTTOM already accounts for the native creative and Android safe inset.
	return 0.0


func banner_height() -> float:
	# Deprecated compatibility alias. New callers must name the contract explicitly.
	return game_content_reserve_height()


func attach_to(_host: Node = null) -> void:
	sync_banner()


func sync_banner() -> void:
	if not _should_show_ads():
		detach()
		return
	if _keyboard_is_open():
		_hide_native_banner()
		return

	if _sdk_initialized:
		_show_banner()
	else:
		_initialize_mobile_ads(_show_banner)


func detach() -> void:
	_loaded_placement = ""
	_relayout_generation += 1
	_destroy_banner()


func _connect_layout_signals() -> void:
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_on_viewport_size_changed):
		viewport.size_changed.connect(_on_viewport_size_changed)
	var window := get_window()
	if window != null and not window.size_changed.is_connected(_on_window_size_changed):
		window.size_changed.connect(_on_window_size_changed)
	if window != null and not window.focus_entered.is_connected(_on_window_focus_entered):
		window.focus_entered.connect(_on_window_focus_entered)


func _on_viewport_size_changed() -> void:
	_schedule_relayout()


func _on_window_size_changed() -> void:
	_schedule_relayout()


func _on_window_focus_entered() -> void:
	_schedule_relayout()


func _schedule_relayout() -> void:
	if not _should_show_ads():
		return
	_relayout_generation += 1
	var generation := _relayout_generation
	var tree := get_tree()
	if tree == null:
		return
	tree.create_timer(RELAYOUT_SETTLE_SECONDS).timeout.connect(
		func() -> void:
			if generation != _relayout_generation:
				return
			_relayout_banner()
	)


func _relayout_banner() -> void:
	if not _should_show_ads():
		return
	if _keyboard_is_open():
		_keyboard_open = true
		_hide_native_banner()
		return
	_keyboard_open = false
	if _ad_view != null and _placement_signature() == _loaded_placement:
		_anchor_banner()
		return
	sync_banner()


func _keyboard_is_open() -> bool:
	return DisplayServer.virtual_keyboard_get_height() > 0


func _placement_signature() -> String:
	var window_size := DisplayServer.window_get_size()
	var visible := Vector2.ZERO
	var viewport := get_viewport()
	if viewport != null:
		visible = viewport.get_visible_rect().size
	return "%d,%d|%.0f,%.0f|%d|%d" % [
		window_size.x,
		window_size.y,
		visible.x,
		visible.y,
		DisplayServer.screen_get_orientation(),
		DisplayServer.virtual_keyboard_get_height(),
	]


func _banner_ad_size() -> Variant:
	var ad_size_api: Variant = load("res://addons/admob/gdscript/src/api/core/AdSize.gd")
	return ad_size_api.get_current_orientation_anchored_adaptive_banner_ad_size(ad_size_api.FULL_WIDTH)

func _should_show_ads() -> bool:
	return ads_enabled() and _platform_supports_ads()


func _platform_supports_ads() -> bool:
	var os_name := OS.get_name()
	return os_name == "Android" or os_name == "iOS"


func active_product_key() -> String:
	return "nuts"

func banner_unit_id_for(product_key: String, platform_name: String) -> String:
	var platform_key := "ios" if platform_name == "iOS" else "android"
	if platform_key == "android":
		# TODO(ads-live): restore production units instead of Google's test banner.
		return GOOGLE_TEST_ANDROID_BANNER_UNIT_ID
		# if product_key == "pigeon":
		# 	return PIGEON_ANDROID_BANNER_UNIT_ID
		# return PEREGRINE_ANDROID_BANNER_UNIT_ID
	var products: Dictionary = _config.get("products", {})
	var product: Dictionary = products.get(product_key, {})
	var configured := str(product.get("%s_banner_unit_id" % platform_key, "")).strip_edges()
	if not configured.is_empty():
		return configured
	# Preserve compatibility with the original single-product config while the
	# production apps migrate to separate ad units.
	return str(_config.get("%s_banner_unit_id" % platform_key, "")).strip_edges()


func _banner_unit_id() -> String:
	return banner_unit_id_for(active_product_key(), OS.get_name())


func _initialize_mobile_ads(on_ready: Callable = Callable()) -> void:
	if _sdk_initialized:
		if on_ready.is_valid():
			on_ready.call()
		return

	if not Engine.has_singleton("PoingGodotAdMob"):
		push_warning(
			"AdBarService: PoingGodotAdMob singleton missing — AdMob Android binaries were not packaged"
		)

	var request_configuration_api: Variant = load("res://addons/admob/gdscript/src/api/core/RequestConfiguration.gd")
	var request_config: Variant = request_configuration_api.new()
	if bool(_config.get("child_directed", false)):
		request_config.tag_for_child_directed_treatment = (
			request_configuration_api.TagForChildDirectedTreatment.TRUE
		)
	if bool(_config.get("tag_for_under_age_of_consent", false)):
		request_config.tag_for_under_age_of_consent = (
			request_configuration_api.TagForUnderAgeOfConsent.TRUE
		)
	var rating := str(_config.get("max_ad_content_rating", "PG"))
	match rating:
		"PG":
			request_config.max_ad_content_rating = request_configuration_api.MAX_AD_CONTENT_RATING_PG
		"T":
			request_config.max_ad_content_rating = request_configuration_api.MAX_AD_CONTENT_RATING_T
		"MA":
			request_config.max_ad_content_rating = request_configuration_api.MAX_AD_CONTENT_RATING_MA
		_:
			request_config.max_ad_content_rating = request_configuration_api.MAX_AD_CONTENT_RATING_G

	var mobile_ads_api: Variant = load("res://addons/admob/gdscript/src/api/MobileAds.gd")
	mobile_ads_api.set_request_configuration(request_config)

	var listener_api: Variant = load("res://addons/admob/gdscript/src/api/listeners/OnInitializationCompleteListener.gd")
	var listener: Variant = listener_api.new()
	listener.on_initialization_complete = func(_status: Variant) -> void:
		_sdk_initialized = true
		print("AdBarService: MobileAds initialized")
		if on_ready.is_valid():
			on_ready.call()

	mobile_ads_api.initialize(listener)

func _show_banner() -> void:
	var unit_id := _banner_unit_id()
	if unit_id.is_empty():
		push_warning("AdBarService: banner unit ID is missing for the active product/platform")
		return

	if not Engine.has_singleton("PoingGodotAdMobAdView"):
		push_warning(
			"AdBarService: PoingGodotAdMobAdView missing — cannot show banner on this build"
		)
		return

	if _keyboard_is_open():
		_hide_native_banner()
		return

	_destroy_banner()
	_loaded_placement = _placement_signature()

	var ad_view_api: Variant = load("res://addons/admob/gdscript/src/api/AdView.gd")
	var ad_position_api: Variant = load("res://addons/admob/gdscript/src/api/core/AdPosition.gd")
	_ad_view = ad_view_api.new(unit_id, _banner_ad_size(), ad_position_api.BOTTOM)

	var ad_listener_api: Variant = load("res://addons/admob/gdscript/src/api/listeners/AdListener.gd")
	var ad_listener: Variant = ad_listener_api.new()
	ad_listener.on_ad_loaded = _on_banner_loaded
	ad_listener.on_ad_failed_to_load = func(error: Variant) -> void:
		_loaded_placement = ""
		push_warning("AdBarService: banner failed: %s" % error.message)

	_ad_view.ad_listener = ad_listener
	print("AdBarService: loading banner unit %s" % unit_id)
	var ad_request_api: Variant = load("res://addons/admob/gdscript/src/api/core/AdRequest.gd")
	_ad_view.load_ad(ad_request_api.new())

func _on_banner_loaded() -> void:
	if _ad_view == null:
		return
	if _keyboard_is_open():
		_hide_native_banner()
		return
	_anchor_banner()
	_ad_view.show()
	var px := float(_ad_view.get_height_in_pixels())
	if px > 0.0:
		_banner_logical_height = _pixels_to_viewport_y(px)
	var tree := get_tree()
	if tree != null and is_instance_valid(tree.current_scene):
		tree.current_scene.queue_redraw()
	print("AdBarService: banner loaded (height_px=%.0f)" % px)


func _anchor_banner() -> void:
	if _ad_view == null:
		return
	var ad_position_api: Variant = load("res://addons/admob/gdscript/src/api/core/AdPosition.gd")
	_ad_view.set_position(ad_position_api.BOTTOM)


func _hide_native_banner() -> void:
	if _ad_view != null:
		_ad_view.hide()


func _destroy_banner() -> void:
	if _ad_view != null:
		_ad_view.destroy()
	_ad_view = null


func _pixels_to_viewport_y(pixels: float) -> float:
	var window_h := float(DisplayServer.window_get_size().y)
	if window_h <= 0.0:
		return pixels
	var viewport_h := float(get_viewport().get_visible_rect().size.y)
	return pixels * (viewport_h / window_h)
