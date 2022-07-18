extends HBoxContainer
class_name LifeContainer


const MAX_VALUE_SCALE = 2.0

onready var _life_bar := $LifeBar
onready var _life_bar_fg := $LifeBar/FG
onready var _tween := $Tween


func _ready():
	EventBus.connect("life_changed", self, "_on_life_changed")
	EventBus.connect("life_max_value_changed", self, "_on_life_max_value_changed")


func _on_life_changed(value: float):
	var from = _life_bar_fg.rect_min_size.x
	var max_size = _life_bar.rect_size.x
	var to_value = max(0.0, min(max_size * MAX_VALUE_SCALE, value * MAX_VALUE_SCALE))
	_tween.interpolate_property(
		_life_bar_fg,
		"rect_min_size:x",
		from,
		to_value,
		0.25
	)
	_tween.start()


func _on_life_max_value_changed(value: float):
	_life_bar.rect_min_size.x = value * MAX_VALUE_SCALE
	_life_bar.rect_size.x = value * MAX_VALUE_SCALE

