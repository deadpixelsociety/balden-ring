extends RigidBody2D
class_name Enemy

const KNOCKBACK_SPEED = 1000.0

export(float) var move_speed = 60.0
export(float) var hp = 100.0
export(float) var seek_range = 300.0
export(float) var knockback_time = 0.1

var _heading = Vector2.RIGHT
var _knockback_timer = 0.0
var _player = null
var _velocity = Vector2.ZERO

onready var _animation_tree := $AnimationTree
onready var _sprite := $Sprite
onready var _state_machine := $StateMachine


func _ready():
	_state_machine.set_default_state()


func _process(delta: float):
	if _knockback_timer > 0.0:
		_knockback_timer -= delta


func _integrate_forces(state: Physics2DDirectBodyState):
	if _knockback_timer <= 0.0:
		linear_velocity = _velocity


func move(velocity: Vector2):
	if _knockback_timer > 0.0:
		return
	_velocity = velocity
	if velocity == Vector2.ZERO:
		_play_animation("idle")
	else:
		_set_animation_values(velocity.normalized())
		_play_animation("walk")


func stop():
	move(Vector2.ZERO)


func hit(from: Vector2, damage: WeaponDamage):
	hp -= damage.amount
	if hp <= 0.0:
		kill()
	else:
		knockback(from, damage.knockback_power)


func kill():
	queue_free()


func knockback(from: Vector2, knockback_power: float):
	_knockback_timer = knockback_time
	apply_central_impulse((global_position - from).normalized() * knockback_power * KNOCKBACK_SPEED)


func _set_animation_values(direction: Vector2):
	_animation_tree.set("parameters/idle/blend_position", direction)
	_animation_tree.set("parameters/walk/blend_position", direction)
	

func _play_animation(animation: String):
	_animation_tree.get("parameters/playback").travel(animation)
