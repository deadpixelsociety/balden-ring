extends KinematicBody2D
class_name TheBalden

const ATTACK_TIME = 0.1
const WEAPON = preload("res://entities/weapons/weapon.tscn")

export(float) var move_speed = 50.0
export(float) var hp = 1.0
export(Resource) var weapon_def = null

var _attack_timer = 0.0
var _heading = Vector2.RIGHT
var _weapon: Weapon = WEAPON.instance()
var _velocity = Vector2.ZERO

onready var _animation_tree := $AnimationTree
onready var _animation_player := $AnimationPlayer
onready var _sprite := $Sprite
onready var _weapon_pivot_down := $Pivots/WeaponPivotDown
onready var _weapon_pivot_up := $Pivots/WeaponPivotUp
onready var _weapon_pivot_left := $Pivots/WeaponPivotLeft
onready var _weapon_pivot_right := $Pivots/WeaponPivotRight


func _ready():
	_setup_weapon()


func _physics_process(delta: float):
	var movement = Vector2.ZERO
	
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
			_attach_weapon()
		_velocity = _heading * move_speed
		_set_animation_values(_heading)
		_play_animation("walk")
	else:
		_velocity = Vector2.ZERO
		if _attack_timer == 0.0:
			_play_animation("idle")
	
	_velocity = move_and_slide(_velocity)
	
	if Input.is_action_just_pressed("attack"):
		_attack()
	
	if _attack_timer <= 0.0:
		_attack_timer = 0.0
	if _attack_timer > 0.0:
		_attack_timer -= delta


func _attack():
	if _weapon and _weapon.can_attack():
		_weapon.attack()
		_attack_timer = ATTACK_TIME
		_play_animation("attack")


func _set_animation_values(direction: Vector2):
	_animation_tree.set("parameters/idle/blend_position", direction)
	_animation_tree.set("parameters/walk/blend_position", direction)
	_animation_tree.set("parameters/attack/blend_position", direction)
	

func _play_animation(animation: String):
	_animation_tree.get("parameters/playback").travel(animation)


func _setup_weapon():
	if not weapon_def:
		return
	_weapon.weapon_def = weapon_def
	_weapon.player_weapon = true
	_attach_weapon()


func _attach_weapon():
	if not _weapon:
		return
	var pivot: Node2D = null
	if abs(_heading.x) > abs(_heading.y):
		if _heading.x > 0:
			pivot = _weapon_pivot_right
			_weapon.set_base_angle(0.0)
		else:
			pivot = _weapon_pivot_left
			_weapon.set_base_angle(180.0)
	else:
		if _heading.y > 0:
			pivot = _weapon_pivot_down
			_weapon.set_base_angle(90.0)
		else:
			pivot = _weapon_pivot_up
			_weapon.set_base_angle(-90.0)
	if pivot:
		var parent = _weapon.get_parent()
		if parent:
			parent.remove_child(_weapon)
		pivot.add_child(_weapon)
