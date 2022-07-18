extends UseableItem
class_name WhiskeyFlask

export(float) var hp_restored = 1.0


func _on_use_item(user):
	user._play_animation("chug")
	user.heal(hp_restored * (user.get_level() * 0.5))

