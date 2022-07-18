extends Node

var last_trashfire: Trashfire = null


func _ready():
	randomize()
	EventBus.connect("trashfire_lit", self, "_on_trashfire_lit")


func find_player():
	var nodes = get_tree().get_nodes_in_group("player")
	if nodes and nodes.size() > 0:
		return nodes.front()
	return null


func rand_bool() -> bool:
	return randf() > 0.5


func rand_point_in_circle(radius: float) -> Vector2:
	var r = radius * sqrt(randf())
	var theta = randf() * 2.0 * PI
	return Vector2(r * cos(theta), r * sin(theta))
	

func _on_trashfire_lit(trashfire: Trashfire):
	last_trashfire = trashfire
