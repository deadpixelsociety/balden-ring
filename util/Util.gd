extends Node

var last_trashfire: Trashfire = null
var ending = -1


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


func rand_pitch(base: float = 1.25) -> float:
	return base - (randf() * 0.5)


func rand_point_in_circle(radius: float) -> Vector2:
	var r = radius * sqrt(randf())
	var theta = randf() * 2.0 * PI
	return Vector2(r * cos(theta), r * sin(theta))


func enable_fullscreen():
	OS.window_fullscreen = true
	OS.window_borderless = true


func disable_fullscreen():
	OS.window_fullscreen = false
	OS.window_borderless = false
	OS.window_size = Vector2(1280.0, 720.0)
	OS.center_window()


func _on_trashfire_lit(trashfire: Trashfire):
	last_trashfire = trashfire


func choose_ending(ending: String):
	self.ending = int(ending)
