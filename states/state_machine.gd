extends Node
class_name StateMachine

export(bool) var active = true
export(NodePath) var default_state_path = null
export(NodePath) var target_path = null

var _blackboard: Blackboard = Blackboard.new()
var _current_state: State = null

onready var _default_state := get_node_or_null(default_state_path) as State
onready var _target := get_node_or_null(target_path)


func _ready():
	_connect_children()
	set_default_state()


func _process(delta: float):
	if _current_state and active:
		_current_state.execute(delta)


func _physics_process(delta: float):
	if _current_state and active:
		_current_state.execute_physics(delta)


func set_default_state():
	if _default_state:
		_change_state(_default_state)


func change_state(new_state: String):
	_on_change_state(new_state)


func _connect_children():
	for i in get_child_count():
		var child = get_child(i) as State
		if child:
			if not child.is_connected("change_state", self, "_on_change_state"):
				child.connect("change_state", self, "_on_change_state")
			child.blackboard = _blackboard
			child.target = _target


func _change_state(state: State):
	if _current_state:
		_current_state.exit_state()
	if state:
		_current_state = state
		_current_state.enter_state()
	else:
		_current_state = null


func _find_state(state_name: String) -> State:
	for i in get_child_count():
		var child = get_child(i) as State
		if child and child.state_name == state_name:
			return child
	return null


func _on_change_state(new_state: String):
	if not new_state:
		_change_state(_default_state)
	var state = _find_state(new_state)
	if not state:
		_change_state(_default_state)
	_change_state(state)
