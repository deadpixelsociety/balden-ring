extends Area2D
class_name ShearProjectile

export(float) var fire_time = 0.5
export(float) var damage = 5.0

var _firing = false
var _velocty = Vector2.ZERO

onready var _collision_shape := $CollisionShape2D
onready var _tween := $Tween


func _ready():
	set_as_toplevel(true)


func _physics_process(delta: float):
	if _velocty != Vector2.ZERO:
		global_position += _velocty * delta


func spawn():
	_collision_shape.set_deferred("disabled", true)
	modulate.a = 0.0
	scale = Vector2.ZERO
	_tween.interpolate_property(
		self,
		"modulate:a",
		0.0,
		1.0,
		0.3
	)
	_tween.interpolate_property(
		self,
		"scale",
		Vector2.ZERO,
		Vector2.ONE,
		0.3
	)
	_tween.start()


func fire(target: Node2D):
	_firing = true
	var dir = (target.global_position - global_position)
	var distance = dir.length()
	dir = dir.normalized()
	_velocty = dir * (distance / fire_time)
	_collision_shape.set_deferred("disabled", false)


func track(target: Node2D):
	if _firing:
		return
	var dir = (target.global_position - global_position).normalized()
	rotation = dir.angle()


func _on_ShearProjectile_body_entered(body):
	var balden = body as TheBalden
	if balden and not balden.is_invulnerable():
		_velocty = Vector2.ZERO
		balden.hit(self, damage, 1.5)
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
