extends Interactable
class_name Writing

export(String) var message

var _interacting = false


func interact(user):
	if not message or _interacting:
		return
	_interacting = true
	var dialogic = Dialogic.start(message)
	get_tree().root.call_deferred("add_child", dialogic)
	yield(dialogic, "timeline_end")
	_interacting = false
