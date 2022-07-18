extends State
class_name IdleState

export(float) var seek_range = 200.0
export(float) var wander_chance = 0.005

var _player = null


func _init():
	state_name = "idle"


func execute(delta: float):
	_find_player()
	if _can_seek():
		_on_change_state("seek")
	else:
		if randf() <= wander_chance:
			_on_change_state("wander")


func enter_state():
	if target:
		target.stop()


func _can_seek() -> bool:
	if not _player or not _player.is_inside_tree():
		return false
	if not target or not target.is_inside_tree():
		return false
	return target.global_position.distance_to(_player.global_position) <= seek_range


func _find_player():
	if not _player:
		_player = Util.find_player()
