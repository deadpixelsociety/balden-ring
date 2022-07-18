extends HBoxContainer
class_name ItemsContainer

onready var _item_textures = [
	$Item1/TextureRect
]
onready var _item_uses = [
	$Item1/Uses
]


func _ready():
	EventBus.connect("item_uses_updated", self, "_on_item_uses_updated")
	EventBus.connect("item_texture_updated", self, "_on_item_texture_updated")


func _on_item_uses_updated(item_idx: int, uses: int):
	if item_idx <= _item_uses.size():
		_item_uses[item_idx].text = "%d" % uses


func _on_item_texture_updated(item_idx: int, texture: Texture = null):
	if item_idx <= _item_textures.size():
		_item_textures[item_idx].texture = texture
