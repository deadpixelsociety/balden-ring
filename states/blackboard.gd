extends Node
class_name Blackboard

var _properties = {}


func add_property(key: String, value):
	_properties[key] = value


func get_property(key: String):
	if has_property(key):
		return _properties[key]
	return null


func has_property(key: String) -> bool:
	return _properties.has(key)


func clear_properties():
	_properties.clear()
