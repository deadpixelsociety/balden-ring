extends MeleeEnemy
class_name Hobo

const PROJECTILE = preload("res://entities/enemies/hobo_projectile.tscn")

export(float) var attack_range = 36.0

onready var _attack_ray := $AttackRay
onready var _attack_delay_timer := $AttackDelayTimer
onready var _left_spawn := $ProjectileSpawnLeft
onready var _right_spawn := $ProjectileSpawnRight
onready var _attack_fx := $AttackFX
onready var _los_ray := $LOSRay


func start_firing(target: Node2D):
	var dir = (target.global_position - global_position)
	var distance = dir.length()
	_los_ray.cast_to = Vector2(distance, 0.0)
	_los_ray.cast_to = _los_ray.cast_to.rotated(dir.angle())
	_los_ray.force_raycast_update()
	if _los_ray.is_colliding():
		end_firing()
		return
	dir = dir.normalized()
	stop()
	_play_animation("idle")
	var projectile = PROJECTILE.instance()
	var spawn: Node2D = null
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			spawn = _left_spawn
		else:
			spawn = _right_spawn
	else:
		if dir.y > 0:
			spawn = _right_spawn
		else:
			spawn = _left_spawn
	if not spawn:
		return
	projectile.position = spawn.global_position
	spawn.add_child(projectile)
	projectile.spawn()
	projectile.fire(target)
	_attack_fx.pitch_scale = Util.rand_pitch()
	_attack_fx.play()
	end_firing()


func end_firing():
	_state_machine.change_state("idle")


func attack(target: Node2D):
	stop()
	var dir = (target.global_position - global_position).normalized()
	_set_animation_values(dir)
	_play_animation("attack")
	_attack_delay_timer.start()
	yield(_attack_delay_timer, "timeout")
	_attack_fx.pitch_scale = Util.rand_pitch()
	_attack_fx.play()
	var angle_to = rad2deg(dir.angle())
	_attack_ray.rotation = dir.angle()
	_attack_ray.force_raycast_update()
	if _attack_ray.is_colliding():
		if target.has_method("hit"):
			target.hit(self, attack_damage)


func _on_strands_spawned(strands: Strands):
	strands.set_brown()
