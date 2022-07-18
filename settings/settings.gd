extends Node

const SETTINGS_FILE = "user://settings.dat"

var master_volume = 100
var music_volume = 100
var voice_volume = 100
var sound_volume = 100
var fullscreen = true


func _ready():
	_load_settings()


func apply_settings():
	Audio.set_volumes(master_volume, music_volume, voice_volume, sound_volume)
	if fullscreen:
		Util.enable_fullscreen()
	else:
		Util.disable_fullscreen()


func save_settings():
	var f = File.new()
	if f.open(SETTINGS_FILE, File.WRITE) == OK:
		f.store_var(master_volume)
		f.store_var(music_volume)
		f.store_var(voice_volume)
		f.store_var(sound_volume)
		f.store_var(fullscreen)
		f.close()


func _load_settings():
	var f = File.new()
	if f.open(SETTINGS_FILE, File.READ) == OK:
		master_volume = f.get_var()
		music_volume = f.get_var()
		voice_volume = f.get_var()
		sound_volume = f.get_var()
		fullscreen = f.get_var()
		f.close()
