extends Node


func _ready():
	randomize()


func find_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes and nodes.size() > 0:
		return nodes.front()
	return null


func rand_bool() -> bool:
	return randf() > 0.5
