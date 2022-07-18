extends KinematicBody2D
class_name TheBalden

const AFTER_IMAGE_DELAY = 0.025
const ATTACK_TIME = 0.1
const COLLISION_MASK_FULL = 14
const COLLISION_MASK_ROLL = 12
const MAX_LEVELS = 20
const LEVEL_INTERVALS = 1.0 / MAX_LEVELS
const MAX_STRANDS_NEEDED_TO_LEVEL = 1200
const ROLL_COST = 12.0
const LIFE_REGEN_RATE = 1.0 / 0.5
const LIFE_REGEN_AMOUNT = 0.2
const STAMINA_REGEN_RATE = 1.0 / 3.0
const STAMINA_REGEN_AMOUNT = 3.0
const HIT_STUN_TIME = 0.3
const KNOCKBACK_POWER = 400.0

const AFTER_IMAGE = preload("res://entities/after_image.tscn")
const LEVEL_CURVE = preload("res://entities/the_balden/level_curve.tres")
const WEAPON = preload("res://entities/weapons/weapon.tscn")

export(float) var move_speed = 50.0
export(float) var roll_speed = 500.0
export(float) var roll_time = 0.3
export(float) var max_hp = 40.0
export(float) var max_stamina = 40.0
export(Resource) var weapon_def = null
export(Resource) var active_item = null

var _first_update = false

var _after_image_timer = 0.0
var _attack_dir = Vector2.DOWN
var _attack_timer = 0.0
var _heading = Vector2.DOWN
var _hp = 0.0
var _hit_stun_timer = 0.0
var _item_timer = 0.0
var _items = [
	preload("res://entities/items/whiskey_flask.tres")
]
var _life_regen_timer = 0.0
var _level = 1
var _rolling = false
var _roll_timer = 0.0
var _stamina = 0.0
var _stamina_regen_timer = 0.0
var _strands = 0
var _using_item = false
var _velocity = Vector2.ZERO
var _weapon: Weapon = WEAPON.instance()
var _strength = 10
var _vitality = 10
var _endurance = 10
var _hair = 0
var _damage_bonus = 0

onready var _animation_tree := $AnimationTree
onready var _animation_player := $AnimationPlayer
onready var _roll_sprite := $RollSprite
onready var _sprite := $Sprite
onready var _weapon_pivot := $WeaponPivot
onready var _level_up_label := $LevelUp
onready var _level_up_party := $LevelUpParty
onready var _tween := $Tween


func _ready():
	EventBus.connect("strands_collected", self, "_on_strands_collected")
	_calc_stats()
	_hp = max_hp
	_stamina = max_stamina
	_update_condition()
	_setup_weapon()
	active_item = _items[0]
	if active_item:
		active_item.refresh_uses()


func _process(delta: float):
	if not _first_update:
		_first_update = true
		_update_condition()
		
	if Input.is_action_just_pressed("interact"):
		_interact()


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			_attack_dir = (get_global_mouse_position() - global_position).normalized()


func _physics_process(delta: float):
	var movement = Vector2.ZERO
	
	if can_move():
		if Input.is_action_pressed("walk_down"):
			movement.y += 1
		if Input.is_action_pressed("walk_up"):
			movement.y -= 1
		if Input.is_action_pressed("walk_right"):
			movement.x += 1
		if Input.is_action_pressed("walk_left"):
			movement.x -= 1
		
		if movement != Vector2.ZERO:
			var next_heading = movement.normalized()
			if next_heading != _heading:
				_heading = next_heading
				if not is_attacking():
					_attack_dir = _heading
			_velocity = _heading * move_speed
			_set_animation_values(_heading)
			_play_animation("walk")
		else:
			_velocity = Vector2.ZERO
			if _attack_timer == 0.0:
				_play_animation("idle")
	
	_velocity = move_and_slide(_velocity, Vector2.ZERO, false, 4, 0.785398, false)
	
	if Input.is_action_just_pressed("attack"):
		_set_animation_values(_heading)
		_attack()
		
	if Input.is_action_just_pressed("roll") and can_roll():
		exert(ROLL_COST)
		_set_animation_values(_heading)
		_roll()
	
	if Input.is_action_just_pressed("use_item") and can_use_item():
		_use_item()
	
	if _attack_timer <= 0.0:
		_attack_timer = 0.0
	if _attack_timer > 0.0:
		_attack_timer -= delta
	
	if _after_image_timer <= 0.0:
		_after_image_timer = 0.0
	if _after_image_timer > 0.0:
		_after_image_timer -= delta
	
	if _roll_timer <= 0.0 and is_rolling():
		_end_roll()
	if _roll_timer > 0.0:
		_roll_timer -= delta
		if _after_image_timer == 0.0:
			_after_image_timer = AFTER_IMAGE_DELAY
			_spawn_after_image(_roll_sprite)
	
	if _item_timer <= 0.0 and is_using_item():
		_end_use_item()
	if _item_timer > 0.0:
		_item_timer -= delta
	
	if _stamina_regen_timer <= 0.0:
		rejuvenate(STAMINA_REGEN_AMOUNT)
		_stamina_regen_timer = STAMINA_REGEN_RATE
	if _stamina_regen_timer > 0.0:
		_stamina_regen_timer -= delta
		
	if _life_regen_timer <= 0.0:
		heal(LIFE_REGEN_AMOUNT)
		_life_regen_timer = LIFE_REGEN_RATE
	if _life_regen_timer > 0.0:
		_life_regen_timer -= delta
	
	if _hit_stun_timer <= 0.0:
		_hit_stun_timer = 0.0
	if _hit_stun_timer > 0.0:
		_hit_stun_timer -= delta
	_sprite.material.set_shader_param("amount", (_hit_stun_timer / HIT_STUN_TIME))


func rest():
	var idx = 0
	for item in _items:
		if item.refreshable:
			item.refresh_uses()
			EventBus.emit_signal("item_uses_updated", idx, item.get_uses_available())
		idx += 1
	heal(max_hp)
	rejuvenate(max_stamina)


func get_level() -> int:
	return _level


func can_move() -> bool:
	return not is_rolling() and not is_using_item() and not is_hit_stun()


func can_use_item() -> bool:
	return active_item != null and _item_timer == 0.0 and not is_hit_stun()


func is_invulnerable() -> bool:
	return _roll_timer > 0.0


func can_roll() -> bool:
	return not is_rolling() and not is_hit_stun() and _stamina >= ROLL_COST


func is_rolling() -> bool:
	return _rolling


func is_using_item() -> bool:
	return _using_item


func is_attacking() -> bool:
	return _attack_timer > 0.0


func is_hit_stun() -> bool:
	return _hit_stun_timer > 0.0


func hit(damager: Node2D, damage: float, knockback: float = 1.0):
	if is_invulnerable():
		return
	_hit_stun_timer = HIT_STUN_TIME
	hurt(damage)
	var dir = (global_position - damager.global_position).normalized()
	_velocity = dir * KNOCKBACK_POWER * knockback


func heal(amount: float):
	_hp = max(0.0, min(_hp + amount, max_hp))
	_update_condition()
	if _hp <= 0.0:
		_kill()


func hurt(amount: float):
	heal(-amount)


func rejuvenate(amount: float):
	_stamina = max(0.0, min(_stamina + amount, max_stamina))
	_update_condition()


func exert(amount: float):
	rejuvenate(-amount)


func clear_strands():
	EventBus.emit_signal("strands_collected", -_strands)


func _kill():
	if Util.last_trashfire:
		set_deferred("global_position", Util.last_trashfire.global_position)
	else:
		var spawn = get_tree().root.find_node("PlayerSpawn", true, false) as Node2D
		if spawn:
			set_deferred("global_position", spawn.global_position)
	
	_velocity = Vector2.ZERO
	_heading = Vector2.DOWN
	_hit_stun_timer = 0.0
	_rolling = false
	_roll_timer = 0.0
	_using_item = false
	_attack_timer = 0.0
	_after_image_timer = 0.0
	_set_animation_values(_heading)
	_play_animation("idle")
	clear_strands()
	rest()
	
	EventBus.emit_signal("you_died")
	EventBus.emit_signal("large_text_display", "YOU ARE BALD")
	yield(get_tree().create_timer(2.5), "timeout")
	EventBus.emit_signal("large_text_hide")



func _interact():
	var world = get_world_2d()
	if not world:
		return
	var state = world.direct_space_state
	if not state:
		return
	var query = Physics2DShapeQueryParameters.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_layer = 256
	query.shape_rid = $InteractionRadius/CollisionShape2D.shape
	query.transform = global_transform
	var result = state.intersect_shape(query, 1)
	if result.size() == 0:
		return
	for data in result:
		if data["collider"] and data["collider"].has_method("interact"):
			data["collider"].interact(self)
			return


func _roll():
	_roll_timer = roll_time
	_velocity = _attack_dir * roll_speed
	_play_animation("roll")
	_rolling = true
	collision_mask = COLLISION_MASK_ROLL


func _end_roll():
	_rolling = false
	_roll_timer = 0.0
	collision_mask = COLLISION_MASK_FULL
	_play_animation("idle")


func _use_item():
	if not active_item or not active_item.can_use():
		return
	_velocity = Vector2.ZERO
	_item_timer = active_item.use_time
	_using_item = true
	active_item.use_item(self)
	EventBus.emit_signal("item_uses_updated", 0, active_item.get_uses_available())


func _end_use_item():
	_using_item = false
	_item_timer = 0.0
	_play_animation("idle")


func _spawn_after_image(sprite: Sprite):
	var after_image = AFTER_IMAGE.instance()
	after_image.spawn(sprite)
	call_deferred("add_child", after_image)


func _attack():
	if _weapon and _weapon.can_attack() and _stamina >= _weapon.get_stamina_cost():
		exert(_weapon.get_stamina_cost())
		_set_weapon_angle()
		_weapon.attack(_damage_bonus)
		_attack_timer = ATTACK_TIME
		_play_animation("attack")


func _set_animation_values(direction: Vector2):
	_animation_tree.set("parameters/idle/blend_position", direction)
	_animation_tree.set("parameters/walk/blend_position", direction)
	_animation_tree.set("parameters/attack/blend_position", direction)
	_animation_tree.set("parameters/roll/blend_position", direction)
	_animation_tree.set("parameters/chug/blend_position", direction)
	

func _play_animation(animation: String):
	_animation_tree.get("parameters/playback").travel(animation)


func _setup_weapon():
	if not weapon_def:
		return
	_weapon.weapon_def = weapon_def
	_weapon.player_weapon = true
	_weapon.visible = false
	_weapon_pivot.add_child(_weapon)


func _set_weapon_angle():
	if not _weapon:
		return
	_weapon.z_index = 1
	if abs(_attack_dir.x) > abs(_attack_dir.y):
		if _attack_dir.x > 0:
			_weapon.set_base_angle(0.0)
		else:
			_weapon.set_base_angle(180.0)
	else:
		if _attack_dir.y > 0:
			_weapon.set_base_angle(90.0)
		else:
			_weapon.set_base_angle(-90.0)
			_weapon.z_index = -1


func _on_strands_collected(amount: int):
	_strands += amount * max(1.0, _level / 3.0)
	EventBus.emit_signal("strands_updated", _strands)
	_check_level()


func _check_level():
	var next_level = _level + 1
	var next_interval = next_level * LEVEL_INTERVALS
	var y = LEVEL_CURVE.interpolate(next_interval)
	var strands_needed = floor(MAX_STRANDS_NEEDED_TO_LEVEL * y)
	if _strands >= strands_needed:
		_strands = max(0.0, _strands - strands_needed)
		EventBus.emit_signal("strands_updated", _strands)
		_level_up()


func _level_up():
	_level += 1
	_strength += 1
	_endurance += 1
	_vitality += 1
	_hair = 0
	_calc_stats()
	_level_up_label.modulate.a = 0
	_level_up_label.rect_position.y = 0.0
	_level_up_label.visible = true
	_tween.interpolate_property(
		_level_up_label,
		"modulate:a",
		0.0,
		1.0,
		0.6
	)
	_tween.interpolate_property(
		_level_up_label,
		"rect_position:y",
		0.0,
		-70.0,
		0.6
	)
	_tween.start()
	_level_up_party.emitting = true
	yield(_tween, "tween_all_completed")
	_tween.interpolate_property(
		_level_up_label,
		"modulate:a",
		1.0,
		0.0,
		0.3
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	_level_up_label.visible = false


func _calc_stats():
	max_hp = 10 + ceil(_vitality / 2) * 10
	max_stamina = 10 + ceil(_endurance * 2.5)
	_damage_bonus = floor(_strength / 4)
	_hair = 0
	_update_condition()


func _update_condition():
	EventBus.emit_signal("life_max_value_changed", max_hp)
	EventBus.emit_signal("stamina_max_value_changed", max_stamina)
	EventBus.emit_signal("life_changed", _hp)
	EventBus.emit_signal("stamina_changed", _stamina)
