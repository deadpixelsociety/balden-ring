extends Sprite
class_name AfterImage

export(float) var duration = 1.0

var _timer = 0.0


func _ready():
	set_as_toplevel(true)


func _process(delta: float):
	if _timer <= 0.0:
		_timer = 0.0
		queue_free()
	if _timer > 0.0:
		_timer -= delta
		if duration == 0.0:
			modulate.a = 0.0
		else:
			var factor = min(0.8, _timer / duration)
			modulate.a = factor


func spawn(other: Sprite):
	texture = other.texture
	hframes = other.hframes
	vframes = other.vframes
	frame = other.frame
	flip_h = other.flip_h
	global_scale = other.global_scale
	global_rotation = other.global_rotation
	global_position = other.global_position
	_timer = duration
	modulate.a = 1.0
