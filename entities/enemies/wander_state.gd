extends State
class_name WanderState

export(float) var wander_time_min = 0.5
export(float) var wander_time_max = 1.5
export(float) var wander_speed = 40.0

var _wander_timer = 0.0


func _init():
	state_name = "wander"


func _process(delta: float):
	if _wander_timer <= 0.0:
		_wander_timer = 0.0
		if target:
			target.stop()
		_on_change_state("idle")
	if _wander_timer > 0.0:
		_wander_timer -= delta


func enter_state():
	_wander_timer = rand_range(wander_time_min, wander_time_max)
	if target:
		target.move(_random_direction() * wander_speed)


func _random_direction() -> Vector2:
	var dir = Vector2.ZERO
	if Util.rand_bool():
		dir.x = 1.0 if Util.rand_bool() else -1.0
	if Util.rand_bool() or dir.x == 0.0:
		dir.y = 1.0 if Util.rand_bool() else -1.0
	return dir.normalized()
