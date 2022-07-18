extends Control
class_name Title

onready var _beep := $Beep
onready var _tween := $Tween


func _on_button_mouse_entered():
	_beep.pitch_scale = Util.rand_pitch()
	_beep.play()


func _on_Quit_pressed():
	get_tree().quit()


func _on_Start_pressed():
	_tween.interpolate_property(
		self,
		"modulate:a",
		1.0,
		0.0,
		1.0
	)
	_tween.start()
	yield(_tween, "tween_all_completed")
	get_tree().change_scene("res://intro/intro.tscn")
	queue_free()


func _on_Options_pressed():
	get_tree().change_scene("res://settings/settings_screen.tscn")
	queue_free()
