tool
extends Area2D
class_name EnemySpawner

export(NodePath) var entities_path
export(PackedScene) var enemy = null
export(int) var num_enemies = 1
export(float) var radius = 10.0 setget _set_radius, _get_radius

var _enemies = []

onready var _collision_shape := $CollisionShape2D
onready var _entities := get_node_or_null(entities_path) as Node2D


func _ready():
	EventBus.connect("trashfire_rest", self, "_on_trashfire_rest")
	if not Engine.editor_hint:
		respawn()


func respawn():
	if not enemy:
		return
	remove_enemies()
	for i in num_enemies:
		var e = enemy.instance() as Node
		if _entities:
			e.position = global_position + Util.rand_point_in_circle(radius)
			e.connect("tree_exiting", self, "_on_enemy_exiting", [ e ])
			_enemies.append(e)
			_entities.call_deferred("add_child", e)


func remove_enemies():
	for e in _enemies:
		if e and is_instance_valid(e):
			e.queue_free()
	_enemies.clear()


func _on_enemy_exiting(enemy):
	if _enemies.has(enemy):
		print("enemy ", enemy, " removed")
		_enemies.erase(enemy)


func _set_radius(value: float):
	if $CollisionShape2D:
		var shape = CircleShape2D.new()
		shape.radius = value
		$CollisionShape2D.shape = shape
	radius = value


func _get_radius() -> float:
	return radius


func _on_trashfire_rest():
	respawn()
