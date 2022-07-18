extends State
class_name AttackState


export(float) var attack_time = 1.0

var _attack_timer = 0.0
var _player


func _init():
	state_name = "attack"


func execute(delta: float):
	if _attack_timer <= 0.0:
		_attack_timer = 0.0
		_on_change_state("seek")
	if _attack_timer > 0.0:
		_attack_timer -= delta


func enter_state():
	_find_player()
	if target and _player:
		_attack_timer = attack_time
		if target.has_method("attack"):
			target.attack(_player)


func _find_player():
	if not _player:
		_player = Util.find_player()
