extends RigidBody2D
class_name Vargas

const HIT_FLASH_TIME = 0.2

const PROJECTILE = preload("res://entities/enemies/hobo_projectile.tscn")
const STRANDS = preload("res://entities/pickups/strands/strands.tscn")

export(float) var attack_damage = 5.0
export(float) var leap_time = 1.5
export(float) var leap_damage = 25.0
export(float) var move_speed = 60.0
export(float) var max_hp = 1500.0
export(float) var seek_range = 300.0

var _leaping = false
var _leap_timer = 0.0
var _heading = Vector2.RIGHT
var _hit_flash_timer = 0.0
var _hp = 0.0
var _knockback_timer = 0.0
var _player = null
var _velocity = Vector2.ZERO
var _last_velocity = Vector2.ZERO
var _fire_target: Node2D = null
var _encountered = false
var _dead = false
var _leap_hit = false

onready var _animation_tree := $AnimationTree
onready var _collision_shape := $CollisionShape2D
onready var _sprite := $Sprite
onready var _state_machine := $StateMachine
onready var _leap_delay_timer := $LeapDelayTimer
onready var _fire_delay_timer := $FireDelayTimer
onready var _rock_spawn := $RockSpawn
onready var _intro_fx := $INTRO
onready var _death_fx := $DEATH
onready var _player_death_fx := $PLAYER_DEATH
onready var _tween := $Tween


func _ready():
	_hp = max_hp
	EventBus.connect("you_died", self, "_on_balden_died")


func _process(delta: float):
	if _hit_flash_timer <= 0.0:
		_hit_flash_timer = 0.0
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
	if _leap_timer <= 0.0 and is_leaping():
		end_leap()
		_state_machine.change_state("vargas")
	if _leap_timer > 0.0:
		_leap_timer -= delta
	_sprite.material.set_shader_param("amount", _hit_flash_timer / HIT_FLASH_TIME)


func _integrate_forces(state: Physics2DDirectBodyState):
	if _dead:
		linear_velocity = Vector2.ZERO
	else:
		linear_velocity = _velocity


func move(velocity: Vector2):
	_velocity = velocity
	if velocity != Vector2.ZERO:
		_set_animation_values(velocity.normalized())
		_play_animation("walk")
	else:
		_play_animation("idle")


func stop():
	_last_velocity = _velocity
	move(Vector2.ZERO)
	end_leap()


func resume():
	move(_last_velocity)


func hit(from: Vector2, damage: WeaponDamage):
	_hp -= damage.amount
	_hit_flash_timer = HIT_FLASH_TIME
	play_random_hurt()
	EventBus.emit_signal("boss_health_changed", _hp / max_hp)
	if _hp <= 0.0:
		kill()


func play_random_hurt():
	var idx = randi() % $HurtFX.get_child_count()
	var child = $HurtFX.get_child(idx)
	if child and child.stream:
		child.pitch_scale = Util.rand_pitch()
		child.play()


func kill():
	_dead = true
	_state_machine.change_state("vargas")
	_state_machine.active = false
	end_leap()
	_velocity = Vector2.ZERO
	_collision_shape.set_deferred("disabled", true)
	_animation_tree.active = false
	$AnimationPlayer.play("death")
	Audio.dampen_audio(Audio.BUS_MUSIC)
	_death_fx.play()
	yield(_death_fx, "finished")
	$ThudFX.play()
	$Tween.interpolate_property(
		_sprite,
		"modulate",
		Color.white,
		Color.transparent,
		2.0
	)
	$Tween.start()
	Audio.restore_audio(Audio.BUS_MUSIC)
	yield($Tween, "tween_all_completed")
	var parent = get_parent()
	for i in 20:
		var strand = STRANDS.instance()
		strand.set_dark()
		strand.global_position = global_position + Util.rand_point_in_circle(128.0)
		parent.add_child(strand)
	EventBus.emit_signal("boss_ended", true)
	queue_free()


func is_leaping() -> bool:
	return _leaping


func start_leap(target: Node2D):
	_leap_hit = false
	stop()
	_leaping = true
	_leap_timer = leap_time
	_set_animation_values((target.global_position - global_position).normalized())
	_play_animation("leap")
	_leap_delay_timer.start()
	yield(_leap_delay_timer, "timeout")
	$AttackFX.pitch_scale = Util.rand_pitch()
	$AttackFX.play()
	var dir = (target.global_position - global_position)
	var distance = dir.length()
	dir = dir.normalized()
	_velocity = dir * distance * leap_time


func end_leap():
	_leaping = false
	_leap_timer = 0.0


func start_firing(target: Node2D):
	stop()
	_fire_target = target
	_set_animation_values((target.global_position - global_position).normalized())
	_play_animation("throw")
	_fire_delay_timer.start()
	yield(_fire_delay_timer, "timeout")
	var projectile = PROJECTILE.instance()
	projectile.position = _rock_spawn.global_position
	projectile.scale = Vector2(4.0, 4.0)
	_rock_spawn.add_child(projectile)
	projectile.damage = 15
	projectile.speed = 400
	projectile.spawn()
	projectile.fire(target)
	$AttackFX.pitch_scale = Util.rand_pitch()
	$AttackFX.play()
	end_firing()


func end_firing():
	_state_machine.change_state("vargas")


func _set_animation_values(direction: Vector2):
	_animation_tree.set("parameters/idle/blend_position", direction)
	_animation_tree.set("parameters/leap/blend_position", direction)
	_animation_tree.set("parameters/walk/blend_position", direction)
	_animation_tree.set("parameters/throw/blend_position", direction)
	

func _play_animation(animation: String):
	if not _animation_tree:
		return
	_animation_tree.get("parameters/playback").travel(animation)


func start_fight():
	if not _encountered:
		Audio.dampen_audio(Audio.BUS_MUSIC)
		_collision_shape.set_deferred("disabled", true)
		_intro_fx.play()
		yield(_intro_fx, "finished")
		Audio.restore_audio(Audio.BUS_MUSIC)
	EventBus.emit_signal("boss_started", "Vargas, the Vagrant Mane")
	yield(get_tree().create_timer(2.5), "timeout")
	_collision_shape.set_deferred("disabled", false)
	_state_machine.change_state("vargas")
	_state_machine.active = true
	_encountered = true


func end_fight():
	_state_machine.change_state("vargas")
	EventBus.emit_signal("boss_ended", false)


func reset():
	stop()
	end_fight()
	_hp = max_hp
	_state_machine.active = false
	set_deferred("global_position", get_parent().global_position)
	_heading = Vector2.DOWN
	_set_animation_values(_heading)
	_play_animation("idle")


func _on_Vargas_body_entered(body):
	var balden = body as TheBalden
	if not balden:
		return
	if is_leaping() and not _leap_hit:
		_leap_hit = true
		balden.hit(self, leap_damage, 2.0)


func _on_balden_died():
	Audio.dampen_audio(Audio.BUS_MUSIC)
	_player_death_fx.play()
	yield(_player_death_fx, "finished")
	Audio.restore_audio(Audio.BUS_MUSIC)
