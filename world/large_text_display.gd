extends Control
class_name LargeTextDisplay

onready var _label := $Label
onready var _tween := $Tween


func _ready():
	EventBus.connect("large_text_display", self, "_on_large_text_display")
	EventBus.connect("large_text_hide", self, "_on_large_text_hide")


func _on_large_text_display(message: String):
	modulate.a = 0.0
	_label.text = message
	visible = true
	_tween.interpolate_property(
		self,
		"modulate:a",
		0.0,
		1.0,
		0.5
	)
	_tween.start()


func _on_large_text_hide():
	_tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		0.3
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	visible = false
