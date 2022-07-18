extends State
class_name FireProjectileState

var _player

func _init():
	state_name = "fire_projectile"


func enter_state():
	_find_player()
	if target and _player:
		target.start_firing(_player)


func _find_player():
	if not _player:
		_player = Util.find_player()
