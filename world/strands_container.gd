extends HBoxContainer
class_name StrandsContainer

onready var _strands_count := $StandsCount


func _ready():
	EventBus.connect("strands_updated", self, "_on_strands_updated")


func _on_strands_updated(amount: int):
	_strands_count.text = "%d" % amount
