extends SceneTree

const NutsProceduralAudio = preload("res://scripts/procedural_audio.gd")
const MUSIC_SOURCE_FRAMES := 8 * int(0.5 * 22050)
const MUSIC_SOURCE_BYTES := MUSIC_SOURCE_FRAMES * 2
const CATCH_SOURCE_FRAMES := 2646


func _init() -> void:
	var audio := NutsProceduralAudio.new()
	var music: AudioStreamWAV = audio.music_loop()
	assert(music.loop_mode == AudioStreamWAV.LOOP_FORWARD)
	assert(music.loop_begin == 0)
	assert(music.loop_end == MUSIC_SOURCE_FRAMES)
	# Regression for Godot 4.7.1 loop_end's inclusive read: one guard PCM16
	# frame keeps the mixer on valid data without changing the intended loop.
	assert(music.data.size() == MUSIC_SOURCE_BYTES + 2)
	assert(music.data.decode_s16(MUSIC_SOURCE_BYTES) == music.data.decode_s16(0))

	var catch_cue: AudioStreamWAV = audio.cue("catch")
	assert(catch_cue.loop_mode == AudioStreamWAV.LOOP_DISABLED)
	assert(catch_cue.data.size() == CATCH_SOURCE_FRAMES * 2)
	print("AUDIO_TEST_PASS")
	quit()
