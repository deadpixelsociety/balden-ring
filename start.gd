extends Control
class_name Start

var _time = 0.0

onready var _label := $Label


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			get_tree().change_scene("res://splash/splash.tscn")
			#get_tree().change_scene("res://world/game_world.tscn")
			queue_free()


func _process(delta):
	_label.modulate.a = 1.0 + sin(_time * 4.0)
	_time += delta
