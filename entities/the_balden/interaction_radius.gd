extends Area2D
class_name InteractionRadius


func pickup(item):
	var strands = item as Strands
	if strands:
		EventBus.emit_signal("strands_collected", strands.value)
	item.call_deferred("queue_free")
