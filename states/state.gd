extends Node
class_name State

signal change_state(new_state)

var state_name: String = ""
var blackboard: Blackboard = null
var target = null


func execute(delta: float):
	pass


func execute_physics(delta: float):
	pass


func enter_state():
	pass


func exit_state():
	pass


func _on_change_state(new_state: String):
	call_deferred("emit_signal", "change_state", new_state)
