extends Control
class_name Credits

const COMMENTARY_TIME = 66.0

var _ending = false
var _time = 0.0

onready var _commentary := $Commentary
onready var _text := $RichTextLabel
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
	_commentary.play()


func _process(delta: float):
	if _time <= COMMENTARY_TIME:
		var pos = _time / COMMENTARY_TIME
		var scroll = _text.get_v_scroll()
		scroll.value = pos * 500.0

	_time += delta
	
	if _time > COMMENTARY_TIME and not _ending:
		_end()


func _end():
	_ending = true
	_tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		5.0
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	get_tree().change_scene("res://title/title.tscn")
	queue_free()
