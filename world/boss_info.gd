extends Control
class_name BossInfo

onready var _health_bar := $BossHealthBar
onready var _boss_name := $BossName
onready var _tween := $Tween


func _ready():
	EventBus.connect("boss_started", self, "_on_boss_started")
	EventBus.connect("boss_ended", self, "_on_boss_ended")
	EventBus.connect("boss_health_changed", self, "_on_boss_health_changed")


func update_health(value: float):
	var new_value = _health_bar.max_value * max(0.0, min(1.0, value))
	_tween.interpolate_property(
		_health_bar,
		"value",
		_health_bar.value,
		new_value,
		1.0
	)
	_tween.start()


func _on_boss_started(boss_name: String):
	_health_bar.value = 0.0
	_boss_name.text = boss_name
	modulate.a = 0.0
	visible = true
	_tween.interpolate_property(
		self,
		"modulate:a",
		0.0,
		1.0,
		1.0
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	update_health(1.0)


func _on_boss_ended(dead: bool):
	_tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		1.0
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	visible = false


func _on_boss_health_changed(value: float):
	update_health(value)
