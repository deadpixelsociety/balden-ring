extends Interactable
class_name Door

export(PackedScene) var next_level


func interact(user):
	if next_level:
		var level = next_level.instance()
		EventBus.emit_signal("change_level", level, user)
