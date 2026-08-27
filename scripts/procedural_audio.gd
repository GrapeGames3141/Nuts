class_name NutsProceduralAudio
extends RefCounted

# Small original PCM cues keep this build self-contained and Android-safe.
const RATE := 22050

func music_loop() -> AudioStreamWAV:
	var samples := PackedFloat32Array()
	var notes := [261.63, 329.63, 392.0, 329.63, 293.66, 349.23, 440.0, 349.23]
	for step in notes.size():
		for i in int(0.5 * RATE):
			var t := float(i) / RATE
			var tone := sin(TAU * notes[step] * t) * 0.13 + sin(TAU * notes[step] * 0.5 * t) * 0.05
			samples.append(tone * (0.75 + 0.25 * sin(PI * t / 0.5)))
	return _stream(samples, true)

func cue(kind: String) -> AudioStreamWAV:
	var spec := {"catch": [740.0, 0.12], "wrong": [175.0, 0.22], "limb": [72.0, 0.42], "button": [440.0, 0.08]}
	var pair: Array = spec.get(kind, spec.button)
	var count := int(pair[1] * RATE)
	var samples := PackedFloat32Array()
	for i in count:
		var t := float(i) / RATE
		var env := exp(-7.0 * t / pair[1])
		var wave := sin(TAU * pair[0] * t)
		if kind == "limb": wave = sin(TAU * pair[0] * t) + sin(TAU * pair[0] * 0.51 * t) * 0.7
		samples.append(wave * env * 0.28)
	return _stream(samples, false)

func _stream(samples: PackedFloat32Array, looped: bool) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	# Godot 4.7.1's WAV forward-loop mixer can read the exclusive loop_end
	# frame inclusively. Keep one source-frame guard for looped PCM only.
	var has_loop_guard := looped and not samples.is_empty()
	bytes.resize(samples.size() * 2 + (2 if has_loop_guard else 0))
	for i in samples.size():
		var value := int(clampf(samples[i], -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, value)
	if has_loop_guard:
		bytes.encode_s16(samples.size() * 2, bytes.decode_s16(0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = bytes
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream
