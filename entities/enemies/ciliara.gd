extends RigidBody2D
class_name Ciliara

const HIT_FLASH_TIME = 0.2

const PROJECTILE = preload("res://entities/enemies/shear_projectile.tscn")
const STRANDS = preload("res://entities/pickups/strands/strands.tscn")

export(float) var attack_damage = 5.0
export(float) var charge_time = 0.5
export(float) var charge_damage = 20.0
export(float) var move_speed = 60.0
export(float) var max_hp = 800.0
export(float) var seek_range = 300.0

var _charging = false
var _charge_timer = 0.0
var _heading = Vector2.RIGHT
var _hit_flash_timer = 0.0
var _hp = 0.0
var _knockback_timer = 0.0
var _player = null
var _velocity = Vector2.ZERO
var _last_velocity = Vector2.ZERO
var _projectiles = []
var _fire_target: Node2D = null
var _encountered = false
var _dead = false

onready var _animation_tree := $AnimationTree
onready var _collision_shape := $CollisionShape2D
onready var _sprite := $Sprite
onready var _state_machine := $StateMachine
onready var _attack_ray := $AttackRay
onready var _attack_delay_timer := $AttackDelayTimer
onready var _fire_delay_timer := $FireDelayTimer
onready var _projectile_spawns = [
	$ShearSpawns/Spawn1,
	$ShearSpawns/Spawn2,
	$ShearSpawns/Spawn3,
	$ShearSpawns/Spawn4,
]
onready var _intro_fx := $INTRO
onready var _death_fx := $DEATH
onready var _player_death_fx := $PLAYER_DEATH
onready var _attack_fx := $AttackFX
onready var _hurt_fx := $HurtFX


func _ready():
	_hp = max_hp
	EventBus.connect("you_died", self, "_on_balden_died")


func _process(delta: float):
	if _hit_flash_timer <= 0.0:
		_hit_flash_timer = 0.0
	if _hit_flash_timer > 0.0:
		_hit_flash_timer -= delta
	if _charge_timer <= 0.0 and is_charging():
		end_charge()
		_state_machine.change_state("float")
	if _charge_timer > 0.0:
		_charge_timer -= delta
	if _fire_target and _projectiles.size() > 0:
		for projectile in _projectiles:
			if projectile and is_instance_valid(projectile):
				projectile.track(_fire_target)
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
	_play_animation("float")


func stop():
	_last_velocity = _velocity
	move(Vector2.ZERO)
	end_charge()


func resume():
	move(_last_velocity)


func attack(target: Node2D):
	stop()
	var dir = (target.global_position - global_position).normalized()
	_set_animation_values(dir)
	_play_animation("attack")
	var angle_to = rad2deg(dir.angle())
	_attack_ray.rotation = dir.angle()
	_attack_ray.force_raycast_update()
	_attack_delay_timer.start()
	yield(_attack_delay_timer, "timeout")
	_attack_fx.pitch_scale = Util.rand_pitch()
	_attack_fx.play()
	if _attack_ray.is_colliding():
		if target.has_method("hit"):
			target.hit(self, attack_damage)


func hit(from: Vector2, damage: WeaponDamage):
	_hp -= damage.amount
	_hit_flash_timer = HIT_FLASH_TIME
	play_random_hurt()
	EventBus.emit_signal("boss_health_changed", _hp / max_hp)
	if _hp <= 0.0:
		kill()


func play_random_hurt():
	var idx = randi() % _hurt_fx.get_child_count()
	var child = _hurt_fx.get_child(idx)
	if child and child.stream:
		child.pitch_scale = Util.rand_pitch()
		child.play()


func kill():
	_dead = true
	_state_machine.change_state("float")
	_state_machine.active = false
	end_charge()
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
		strand.global_position = global_position + Util.rand_point_in_circle(128.0)
		parent.add_child(strand)
	EventBus.emit_signal("boss_ended", true)
	queue_free()


func is_charging() -> bool:
	return _charging


func start_charge(target: Node2D):
	_charging = true
	_charge_timer = charge_time
	var dir = (target.global_position - global_position)
	var distance = dir.length()
	dir = dir.normalized()
	_velocity = dir * (distance / charge_time)


func end_charge():
	_charging = false
	_charge_timer = 0.0


func start_firing(target: Node2D):
	stop()
	_fire_target = target
	_play_animation("float")
	_projectiles.clear()
	_attack_fx.pitch_scale = Util.rand_pitch()
	_attack_fx.play()
	for spawn in _projectile_spawns:
		_spawn_projectile(spawn)
	for projectile in _projectiles:
		_fire_delay_timer.start()
		yield(_fire_delay_timer, "timeout")
		if projectile and is_instance_valid(projectile):
			projectile.fire(target)
	end_firing()


func _spawn_projectile(spawn: Node2D):
	var projectile = PROJECTILE.instance()
	projectile.position = spawn.global_position
	_projectiles.append(projectile)
	spawn.add_child(projectile)
	projectile.spawn()


func _clear_projectiles():
	for proj in _projectiles:
		if proj and is_instance_valid(proj):
			proj.queue_free()
	_projectiles.clear()


func end_firing():
	_projectiles.clear()
	_state_machine._on_change_state("float")


func _set_animation_values(direction: Vector2):
	_animation_tree.set("parameters/float/blend_position", direction)
	_animation_tree.set("parameters/attack/blend_position", direction)
	_animation_tree.set("parameters/charge/blend_position", direction)
	

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
	EventBus.emit_signal("boss_started", "Ciliara, the Silken Lock")
	yield(get_tree().create_timer(2.5), "timeout")
	_collision_shape.set_deferred("disabled", false)
	_state_machine.change_state("float")
	_state_machine.active = true
	_encountered = true


func end_fight():
	_state_machine.change_state("float")
	EventBus.emit_signal("boss_ended", false)


func reset():
	stop()
	end_fight()
	_hp = max_hp
	_clear_projectiles()
	_state_machine.active = false
	set_deferred("global_position", get_parent().global_position)
	_heading = Vector2.DOWN
	_set_animation_values(_heading)
	_play_animation("float")


func _on_Ciliara_body_entered(body):
	var balden = body as TheBalden
	if not balden:
		return
	if is_charging():
		balden.hit(self, charge_damage, 2.0)


func _on_balden_died():
	Audio.dampen_audio(Audio.BUS_MUSIC)
	_player_death_fx.play()
	yield(_player_death_fx, "finished")
	Audio.restore_audio(Audio.BUS_MUSIC)
