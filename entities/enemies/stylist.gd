extends MeleeEnemy
class_name Stylist

export(float) var attack_range = 36.0

onready var _attack_ray := $AttackRay
onready var _attack_delay_timer := $AttackDelayTimer
onready var _attack_fx := $AttackFX


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
