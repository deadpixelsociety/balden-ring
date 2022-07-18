extends State
class_name VargasState

export(float) var seek_range = 200.0
export(float) var leap_chance = 0.3
export(float) var fire_chance = 0.1
export(float) var ability_cooldown = 3.0

var _ability_cooldown_timer = ability_cooldown
var _player = null


func _init():
	state_name = "vargas"


func execute(delta: float):
	_find_player()
	
	if _ability_cooldown_timer <= 0.0:
		_ability_cooldown_timer = 0.0
	if _ability_cooldown_timer > 0.0:
		_ability_cooldown_timer -= delta
	
	if _can_seek():
		_on_change_state("seek")
	elif randf() <= leap_chance and _ability_cooldown_timer == 0.0:
		_ability_cooldown_timer = ability_cooldown
		_on_change_state("leap")
	elif _ability_cooldown_timer == 0.0:
		_ability_cooldown_timer = ability_cooldown
		_on_change_state("fire_projectile")


func enter_state():
	_ability_cooldown_timer = ability_cooldown
	if target:
		target.stop()


func _can_seek() -> bool:
	if not _player:
		return false
	return target.global_position.distance_to(_player.global_position) <= seek_range


func _find_player():
	if not _player:
		_player = Util.find_player()
