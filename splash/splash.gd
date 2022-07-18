extends Node2D
class_name Splash


func _on_Timer_timeout():
	$Tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		1.0
	)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	get_tree().change_scene("res://title/title.tscn")
	queue_free()
