extends Area2D
class_name Interactable

export(String) var display_name = ""

onready var _label := $Label


func _ready():
	_set_name()


func interact(user):
	pass


func _set_name():
	_label.text = "%s - E to Interact" % display_name


func _on_Interactable_area_entered(area):
	_label.visible = true


func _on_Interactable_area_exited(area):
	_label.visible = false
