extends State
class_name ChargeState

var _player

func _init():
	state_name = "charge"


func enter_state():
	_find_player()
	if target and _player:
		target.start_charge(_player)


func _find_player():
	if not _player:
		_player = Util.find_player()
