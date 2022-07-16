extends Area2D
class_name Strands

const PICKUP_SPEED = 5.0

export(int) var value = 1

var _initial_distance = 0.0
var _picking_up = false
var _target: Node2D = null


func _physics_process(delta: float):
	if _picking_up and _target:
		var dir = (_target.global_position - global_position)
		var distance = dir.length()
		if distance <= 8.0:
			if _target.has_method("pickup"):
				_target.pickup(self)
			_picking_up = false
		else:
			var factor = max(0.1, 1.0 - (distance / _initial_distance))
			var speed = factor * PICKUP_SPEED
			position += dir.normalized() * speed


func _pickup(area: Node2D):
	if not area:
		return
	_target = area
	_picking_up = true
	_initial_distance = global_position.distance_to(_target.global_position)


func _on_Strands_area_entered(area):
	_pickup(area)
