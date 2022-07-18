extends Node


const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SOUND = "Sound"

var _audio_levels = {}
var _tween: Tween


func _ready():
	_tween = Tween.new()
	add_child(_tween)


func set_volumes(master_volume: int, music_volume: int, voice_volume: int, sound_volume: int):
	set_bus_volume(BUS_MASTER, master_volume)
	set_bus_volume(BUS_MUSIC, music_volume)
	set_bus_volume(BUS_SOUND, sound_volume)


func set_bus_volume(bus: String, linear_volume: int):
	var db = linear2db(min(100, max(0, linear_volume)) / 100.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), db)


func get_bus_volume(bus: String) -> int:
	return int(db2linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))) * 100.0)


func dampen_audio(bus: String):
	var idx = AudioServer.get_bus_index(bus)
	var db = AudioServer.get_bus_volume_db(idx)
	_audio_levels[bus] = db
	var linear = db2linear(db)
	var dampened = linear * 0.1
	var method = null
	match bus:
		BUS_MASTER:
			method = "set_master_volume"
		BUS_MUSIC:
			method = "set_music_volume"
		BUS_SOUND:
			method = "set_sound_volume"
	
	if method:
		_tween.interpolate_method(
			self,
			method,
			linear,
			dampened,
			0.5
		)
		_tween.start()


func restore_audio(bus: String):
	if not _audio_levels.has(bus):
		return
	var idx = AudioServer.get_bus_index(bus)
	var dampened = db2linear(AudioServer.get_bus_volume_db(idx))
	var db = _audio_levels[bus]
	var linear = db2linear(db)
	var method = null
	match bus:
		BUS_MASTER:
			method = "set_master_volume"
		BUS_MUSIC:
			method = "set_music_volume"
		BUS_SOUND:
			method = "set_sound_volume"
	
	if method:
		_tween.interpolate_method(
			self,
			method,
			dampened,
			linear,
			0.5
		)
		_tween.start()


func set_master_volume(linear: float):
	var idx = AudioServer.get_bus_index(BUS_MASTER)
	_set_bus_volume(idx, linear)


func set_music_volume(linear: float):
	var idx = AudioServer.get_bus_index(BUS_MUSIC)
	_set_bus_volume(idx, linear)


func set_sound_volume(linear: float):
	var idx = AudioServer.get_bus_index(BUS_SOUND)
	_set_bus_volume(idx, linear)


func _set_bus_volume(idx: int, linear: float):
	linear = max(0.0, min(1.0, linear))
	AudioServer.set_bus_volume_db(idx, linear2db(linear))
