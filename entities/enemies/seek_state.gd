extends State
class_name SeekState

export(float) var attack_range = 32.0
export(float) var seek_speed = 40.0
export(float) var sight_radius = 250.0
export(String) var idle_state = "idle"
export(String) var attack_state = "attack"
export(bool) var can_fire = false
export(String) var fire_state = "fire_projectile"

var _player = null


func _init():
	state_name = "seek"


func execute_physics(delta: float):
	_find_player()
	if target and _player:
		var dir = (_player.global_position - target.global_position)
		var distance = dir.length()
		if distance <= attack_range:
			if can_fire and randf() <= 0.5:
				_on_change_state(fire_state)
			else:
				_on_change_state(attack_state)
		elif distance <= sight_radius:
			target.move(dir.normalized() * seek_speed)
		else:
			_on_change_state(idle_state)


func enter_state():
	if target:
		target.resume()


func _find_player():
	if not _player:
		_player = Util.find_player()
