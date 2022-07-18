extends Node2D
class_name GameWorld

var _player = null

onready var _camera := $Camera2D
onready var _canvas_modulate := $CanvasModulate
onready var _level_container := $Level
onready var _tween := $Tween
onready var _player_storage := $PlayerStorage


func _ready():
	EventBus.connect("large_text_display", self, "_on_large_text_display")
	EventBus.connect("large_text_hidden", self, "_on_large_text_hidden")
	EventBus.connect("change_level", self, "_on_change_level")
	_setup_camera()


func _process(delta: float):
	_find_player()
	if _player and _player.is_inside_tree():
		_camera.position = _player.global_position


func _setup_camera():
	var level = get_level()
	if not level:
		return
	_camera.limit_left = level.level_size.position.x
	_camera.limit_top = level.level_size.position.y
	_camera.limit_right = level.level_size.end.x
	_camera.limit_bottom = level.level_size.end.y


func get_level() -> Level:
	if _level_container and _level_container.get_child_count() > 0:
		return _level_container.get_child(0) as Level
	return null


func _find_player():
	if not _player:
		_player = Util.find_player()


func _on_large_text_display(message: String, delay: float = 0.0):
	_tween.interpolate_property(
		_canvas_modulate, 
		"color",
		Color.white,
		Color(0.3, 0.3, 0.3, 1.0),
		0.5
	)
	_tween.start()


func _on_large_text_hidden():
	_tween.interpolate_property(
		_canvas_modulate, 
		"color",
		Color(0.3, 0.3, 0.3, 1.0),
		Color.white,
		0.4
	)
	_tween.start()


func _on_change_level(next_level, player):
	player.get_parent().remove_child(player)
	var current_level = get_level()
	if current_level:
		_tween.interpolate_property(
			current_level,
			"modulate",
			Color.white,
			Color.black,
			0.5
		)
		_tween.start()
		yield(_tween, "tween_all_completed")
		_level_container.remove_child(current_level)
	next_level.modulate = Color.black
	_level_container.add_child(next_level)
	_setup_camera()
	_tween.interpolate_property(
		next_level,
		"modulate",
		Color.black,
		Color.white,
		0.5
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	var entities = next_level.find_node("Entities", true, false) as Node2D
	if entities:
		entities.add_child(player)
		var spawn = next_level.find_node("PlayerSpawn", true, false) as Node2D
		if spawn:
			player.set_deferred("global_position", spawn.global_position)
		else:
			player.set_deferred("global_position", Vector2.ZERO)
	if current_level:
		current_level.queue_free()
