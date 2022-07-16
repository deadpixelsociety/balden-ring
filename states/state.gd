extends Node
class_name State

signal change_state(new_state)

var state_name: String = ""
var blackboard: Blackboard = null
var target = null


func _ready():
	disable_state()


func enable_state():
	set_process(true)
	set_physics_process(true)


func disable_state():
	set_process(false)
	set_physics_process(false)


func enter_state():
	pass


func exit_state():
	pass


func _on_change_state(new_state: String):
	print("change state to ", new_state)
	call_deferred("emit_signal", "change_state", new_state)
