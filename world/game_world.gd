extends Node2D
class_name GameWorld

var _player = null

onready var _camera := $Camera2D


func _process(delta: float):
	_find_player()
	if _player:
		_camera.position = _player.global_position


func _find_player():
	if not _player:
		_player = Util.find_player()
