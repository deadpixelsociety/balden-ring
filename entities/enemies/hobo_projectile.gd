extends Area2D
class_name BottleProjectile

const TEXTURES = [
	preload("res://assets/gfx/bottle.png"),
	preload("res://assets/gfx/rock.png")
]

export(float) var damage = 2.0
export(float) var speed = 100.0

var _firing = false
var _velocty = Vector2.ZERO

onready var _collision_shape := $CollisionShape2D
onready var _sprite := $Sprite
onready var _tween := $Tween


func _ready():
	set_as_toplevel(true)
	_sprite.texture = TEXTURES[randi() % TEXTURES.size()]


func _physics_process(delta: float):
	if _velocty != Vector2.ZERO:
		global_position += _velocty * delta


func spawn():
	_collision_shape.set_deferred("disabled", true)
	modulate.a = 0.0
	_tween.interpolate_property(
		self,
		"modulate:a",
		0.0,
		1.0,
		0.3
	)
	_tween.start()


func fire(target: Node2D):
	_firing = true
	var dir = (target.global_position - global_position)
	var distance = dir.length()
	dir = dir.normalized()
	_velocty = dir * speed
	_collision_shape.set_deferred("disabled", false)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_BottleProjectile_body_entered(body):
	var balden = body as TheBalden
	if balden and not balden.is_invulnerable():
		_velocty = Vector2.ZERO
		balden.hit(self, damage, 1.5)
		queue_free()
