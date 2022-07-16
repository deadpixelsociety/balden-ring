extends State
class_name SeekState

export(float) var attack_range = 32.0
export(float) var seek_speed = 60.0
export(float) var sight_radius = 250.0

var _player = null


func _init():
	state_name = "seek"


func _physics_process(delta: float):
	_find_player()
	if target and _player:
		var dir = (_player.global_position - target.global_position)
		var distance = dir.length()
		if distance <= attack_range:
			_on_change_state("attack")
		elif distance <= sight_radius:
			target.move(dir.normalized() * seek_speed)
		else:
			_on_change_state("idle")


func _find_player():
	if not _player:
		_player = Util.find_player()
