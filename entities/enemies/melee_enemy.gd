extends RigidBody2D
class_name MeleeEnemy

const HIT_FLASH_TIME = 0.2
const KNOCKBACK_SPEED = 1000.0

const STRANDS = preload("res://entities/pickups/strands/strands.tscn")

export(float) var attack_damage = 5.0
export(float) var move_speed = 60.0
export(float) var hp = 100.0
export(float) var seek_range = 300.0
export(float) var knockback_time = 0.1

var _heading = Vector2.RIGHT
var _hit_flash_timer = 0.0
var _knockback_timer = 0.0
var _player = null
var _velocity = Vector2.ZERO
var _last_velocity = Vector2.ZERO
var _dead = false

onready var _animation_tree := $AnimationTree
onready var _collision_shape := $CollisionShape2D
onready var _sprite := $Sprite
onready var _state_machine := $StateMachine
onready var _tween := $Tween
onready var _hurt_fx := $HurtFX


func _ready():
	_state_machine.set_default_state()
	modulate.a = 0.0
	_tween.interpolate_property(
		self, 
		"modulate",
		Color(1.0, 0.0, 0.0, 0.0),
		Color.white,
		0.5
	)
	_tween.start()


func _process(delta: float):
	if _knockback_timer > 0.0:
		_knockback_timer -= delta
	if _hit_flash_timer <= 0.0:
		_hit_flash_timer = 0.0
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
	_sprite.material.set_shader_param("amount", _hit_flash_timer / HIT_FLASH_TIME)


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
	_last_velocity = _velocity
	move(Vector2.ZERO)


func resume():
	move(_last_velocity)


func hit(from: Vector2, damage: WeaponDamage):
	hp -= damage.amount
	_hit_flash_timer = HIT_FLASH_TIME
	play_random_hurt()
	if hp <= 0.0:
		kill()
	else:
		knockback(from, damage.knockback_power)


func play_random_hurt():
	var idx = randi() % _hurt_fx.get_child_count()
	var child = _hurt_fx.get_child(idx)
	if child and child.stream:
		child.pitch_scale = Util.rand_pitch()
		child.play()


func kill():
	if _dead:
		return
	_dead = true
	var strands = STRANDS.instance()
	_on_strands_spawned(strands)
	strands.global_position = global_position
	get_parent().call_deferred("add_child", strands)
	_state_machine.active = false
	_collision_shape.set_deferred("disabled", true)
	_tween.interpolate_property(
		self, 
		"modulate",
		Color.white,
		Color(1.0, 0.0, 0.0, 0.0),
		0.5
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	queue_free()


func _on_strands_spawned(strands: Strands):
	pass


func knockback(from: Vector2, knockback_power: float):
	_knockback_timer = knockback_time
	apply_central_impulse((global_position - from).normalized() * knockback_power * KNOCKBACK_SPEED)


func _set_animation_values(direction: Vector2):
	if not _animation_tree:
		return
	_animation_tree.set("parameters/idle/blend_position", direction)
	_animation_tree.set("parameters/walk/blend_position", direction)
	_animation_tree.set("parameters/attack/blend_position", direction)
	

func _play_animation(animation: String):
	if not _animation_tree:
		return
	_animation_tree.get("parameters/playback").travel(animation)
