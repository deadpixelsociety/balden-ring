tool
extends Interactable
class_name Trashfire

export(bool) var has_ciliana = false setget _set_has_ciliana, _get_has_ciliana
export(String) var dialogue

var _ciliana_interacted = false
var _lit = false

onready var _animation_player := $AnimationPlayer
onready var _sparks := $Sparks
onready var _ciliana := $Ciliana
onready var _tween := $Tween


func interact(user):
	if not _lit:
		_light()
	if user.has_method("rest"):
		user.rest()
		EventBus.emit_signal("trashfire_rest")


func _light():
	_lit = true
	_animation_player.play("burn")
	_sparks.visible = true
	_sparks.emitting = true
	EventBus.emit_signal("trashfire_lit", self)
	EventBus.emit_signal("large_text_display", "THE TRASHFIRE IS LIT")
	yield(get_tree().create_timer(2.5), "timeout")
	EventBus.emit_signal("large_text_hide")
	if has_ciliana and not _ciliana_interacted:
		_ciliana_interacted = true
		_ciliana.modulate.a = 0.0
		_ciliana.visible = true
		_tween.interpolate_property(
			_ciliana,
			"modulate",
			Color(1.0, 1.0, 0.0, 0.0), 
			Color.white,
			1.0
		)
		_tween.start()
		yield(_tween, "tween_all_completed")
		if dialogue:
			var dialogic = Dialogic.start(dialogue)
			get_tree().root.call_deferred("add_child", dialogic)
			yield(dialogic, "timeline_end")
			_tween.interpolate_property(
				_ciliana,
				"modulate",
				Color.white,
				Color(1.0, 1.0, 0.0, 0.0), 
				1.0
			)
			_tween.start()
			yield(_tween, "tween_all_completed")
			_ciliana.visible = true



func _set_has_ciliana(value: bool):
	has_ciliana = value


func _get_has_ciliana() -> bool:
	return has_ciliana
