extends HBoxContainer
class_name StaminaContainer

const MAX_VALUE_SCALE = 2.0

onready var _stamina_bar := $StaminaBar
onready var _stamina_bar_fg := $StaminaBar/FG
onready var _tween := $Tween


func _ready():
	EventBus.connect("stamina_changed", self, "_on_stamina_changed")
	EventBus.connect("stamina_max_value_changed", self, "_on_stamina_max_value_changed")


func _on_stamina_changed(value: float):
	var from = _stamina_bar_fg.rect_min_size.x
	var max_size = _stamina_bar.rect_size.x
	var to_value = max(0.0, min(max_size * MAX_VALUE_SCALE, value * MAX_VALUE_SCALE))
	_tween.interpolate_property(
		_stamina_bar_fg,
		"rect_min_size:x",
		from,
		to_value,
		0.25
	)
	_tween.start()


func _on_stamina_max_value_changed(value: float):
	_stamina_bar.rect_min_size.x = value * MAX_VALUE_SCALE
	_stamina_bar.rect_size.x = value * MAX_VALUE_SCALE
