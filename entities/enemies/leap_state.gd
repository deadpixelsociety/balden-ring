extends State
class_name LeapState

var _player

func _init():
	state_name = "leap"


func enter_state():
	_find_player()
	if target and _player:
		target.start_leap(_player)


func _find_player():
	if not _player:
		_player = Util.find_player()
