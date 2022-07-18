extends Resource
class_name UseableItem

signal destroyed()

export(String) var display_name
export(String) var flavor_text
export(Texture) var texture = null
export(Material) var material = null
export(int) var uses = 1
export(bool) var destroy_after_use = false
export(float) var use_time = 0.8
export(bool) var refreshable = false


var _uses_available = 0


func _init():
	refresh_uses()


func refresh_uses():
	_uses_available = uses


func get_uses_available() -> int:
	return _uses_available


func use_item(user):
	if not can_use():
		return
	_on_use_item(user)
	add_use(-1)
	if _uses_available <= 0 and destroy_after_use:
		_on_destroyed()


func can_use() -> bool:
	return _uses_available > 0


func add_use(amount: int):
	_uses_available = max(0, min(_uses_available + amount, uses))


func _on_use_item(user):
	pass


func _on_destroyed():
	call_deferred("emit_signal", "destroyed")
