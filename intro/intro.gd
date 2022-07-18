extends Control
class_name Intro

const INTRO_LENGTH = 133.5

var _current_line = 0
var _finishing = false
var _intro_timer = 0.0
var _num_lines = 0

onready var _rich_text := $RichTextLabel
onready var _tween := $Tween


func _ready():
	_num_lines = _rich_text.get_line_count()
	_tween.interpolate_property(
		self, 
		"modulate:a",
		0.0, 
		1.0,
		10.0
	)
	_tween.start()


func _process(delta: float):
	if _intro_timer > INTRO_LENGTH and not _finishing:
		_finish()
	if _intro_timer <= INTRO_LENGTH:
		_intro_timer += delta
		var pos = min(_intro_timer / INTRO_LENGTH, 1.0)
		var scrollbar = _rich_text.get_v_scroll()
		scrollbar.set_value(scrollbar.max_value * pos)


func _finish():
	_finishing = true
	_tween.interpolate_property(
		self, 
		"modulate:a",
		1.0,
		0.0,
		5.0
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	print("finished")
