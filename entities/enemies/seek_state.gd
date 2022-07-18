extends State
class_name SeekState

export(float) var attack_range = 32.0
export(float) var seek_speed = 40.0
export(float) var sight_radius = 250.0
export(String) var idle_state = "idle"
export(String) var attack_state = "attack"
export(bool) var can_attack = true
export(bool) var can_fire = false
export(String) var fire_state = "fire_projectile"
export(float) var fire_range_min = 100.0
export(float) var fire_range_max = 200.0
export(float) var fire_delay = 3.0
export(float) var melee_fire_chance = 0.5

var _fire_timer = 0.0
var _player = null


func _init():
	state_name = "seek"


func execute(delta: float):
	if _fire_timer <= 0.0:
		_fire_timer = 0.0
	if _fire_timer > 0.0:
		_fire_timer -= delta


func execute_physics(delta: float):
	_find_player()
	if target and _player:
		var dir = (_player.global_position - target.global_position)
		var distance = dir.length()
		if distance <= attack_range:
			if can_fire and randf() <= melee_fire_chance and _fire_timer == 0.0:
				_on_change_state(fire_state)
			elif can_attack:
				_on_change_state(attack_state)
		elif can_fire and _fire_timer == 0.0 and distance >= fire_range_min and distance <= fire_range_max:
			_on_change_state(fire_state)
		elif distance <= sight_radius:
			target.move(dir.normalized() * seek_speed)
		else:
			_on_change_state(idle_state)


func enter_state():
	_fire_timer = fire_delay + (randf() * fire_delay * 0.5)
	if target:
		target.resume()


func _find_player():
	if not _player:
		_player = Util.find_player()
