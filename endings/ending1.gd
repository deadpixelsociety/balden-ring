extends Control
class_name Ending1

onready var _music := $Music
onready var _vo := $VO
onready var _tween := $Tween


func _ready():
	_tween.interpolate_property(
		self,
		"modulate:a",
		0.0,
		1.0,
		5.0
	)
	_tween.start()
	_music.play()
	_vo.play()
	yield(_vo, "finished")
	_tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		5.0
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	get_tree().change_scene("res://endings/credits.tscn")
	queue_free()
