extends Area2D
class_name ItemPickup


func pickup(item):
	item.call_deferred("queue_free")
