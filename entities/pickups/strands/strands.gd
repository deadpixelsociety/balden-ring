extends Area2D
class_name Strands

const PICKUP_SPEED = 5.0

export(int) var value = 1
export(int) var value_min = 5
export(int) var value_max = 10

var _initial_distance = 0.0
var _picking_up = false
var _target: Node2D = null

onready var _animation_player := $AnimationPlayer
onready var _collision_shape := $CollisionShape2D


func _ready():
	set_as_toplevel(true)
	value = int(floor(rand_range(value_min, value_max)))
	_animation_player.play("drop")
	yield(get_tree().create_timer(1.0), "timeout")
	_collision_shape.set_deferred("disabled", false)


func _physics_process(delta: float):
	if _picking_up and _target:
		var dir = (_target.global_position - global_position)
		var distance = dir.length()
		if distance <= 16.0:
			if _target.has_method("pickup"):
				_target.pickup(self)
			_picking_up = false
		else:
			var factor = max(0.1, distance / _initial_distance)
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
