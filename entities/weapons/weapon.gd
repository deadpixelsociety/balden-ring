extends Area2D
class_name Weapon

const AFTER_IMAGE = preload("res://entities/after_image.tscn")

export(bool) var player_weapon = false
export(Resource) var weapon_def = null setget _set_weapon_def, _get_weapon_def

var _after_image_timer = 0.0
var _attack_delay = 0.0
var _attack_timer = 0.0
var _base_angle = 0.0
var _swing_time = 0.0
var _swing_timer = 0.0
var _bonus_damage = 0.0

onready var _sprite := $Sprite
onready var _collision_shape := $CollisionShape2D


func _ready():
	if weapon_def:
		_init_weapon()


func _process(delta: float):
	if _after_image_timer <= 0.0:
		_after_image_timer = 0.0
	if _after_image_timer > 0.0:
		_after_image_timer -= delta
	if _attack_timer < 0.0:
		_attack_timer = 0.0
	if _swing_timer < 0.0:
		_finish_attack()
	if _attack_timer > 0.0:
		_attack_timer -= delta
	if _swing_timer > 0.0:
		_swing_timer -= delta
		#_spawn_after_image()


func _physics_process(delta: float):
	if _swing_timer > 0.0:
		rotation_degrees = _base_angle + (weapon_def.attack_angle - (weapon_def.attack_angle * 2.0) * (1.0 - attack_position()))


func attack(bonus_damage: float):
	_bonus_damage = bonus_damage
	_attack_timer = _attack_delay
	_swing_timer = _swing_time
	_collision_shape.disabled = false
	# TODO: Tween this slowly at first for a wind up?
	rotation_degrees = _base_angle - weapon_def.attack_angle
	visible = true


func _finish_attack():
	_swing_timer = 0.0
	_collision_shape.disabled = true
	rotation_degrees = _base_angle
	visible = false


func _spawn_after_image():
	var after_image = AFTER_IMAGE.instance()
	after_image.spawn(_sprite)
	after_image.duration = 0.1
	call_deferred("add_child", after_image)


func can_attack() -> bool:
	return weapon_def != null and _attack_timer == 0.0


func get_stamina_cost() -> float:
	return weapon_def.stamina_cost


func attack_position() -> float:
	if _swing_timer == 0.0:
		return 0.0
	var val = 1.0 - (_swing_timer / _swing_time)
	return val


func set_base_angle(angle: float):
	_base_angle = angle
	rotation_degrees = angle


func _init_weapon():
	if _sprite:
		_sprite.texture = weapon_def.texture
		_sprite.material = weapon_def.material
		_sprite.position = weapon_def.pivot_point
	if _collision_shape:
		_collision_shape.shape = weapon_def.hitbox
		_collision_shape.position = weapon_def.hitbox_offset
		_collision_shape.rotation_degrees = weapon_def.hitbox_angle
	if player_weapon:
		collision_mask = 2
	else:
		collision_mask = 1
	_attack_delay = (1.0 / weapon_def.attack_speed) if weapon_def.attack_speed > 0.0 else 0.0
	_swing_time = weapon_def.swing_time
	scale = weapon_def.weapon_scale


func _set_weapon_def(def: Resource):
	weapon_def = def
	_init_weapon()


func _get_weapon_def() -> Resource:
	return weapon_def


func _calc_damage() -> WeaponDamage:
	var weapon_damage = WeaponDamage.new()
	var damage = rand_range(weapon_def.damage_min, weapon_def.damage_max) + _bonus_damage
	if randf() <= weapon_def.crit_chance:
		weapon_damage.is_crit = true
		damage *= weapon_def.crit_multi
	weapon_damage.amount = damage
	weapon_damage.knockback_power = weapon_def.knockback_power
	return weapon_damage


func _on_Weapon_body_entered(body):
	if body.has_method("hit"):
		body.hit(global_position, _calc_damage())
