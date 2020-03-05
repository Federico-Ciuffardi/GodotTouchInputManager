class_name InputEventSingleScreenTap
extends InputEventAction

var position

func _init(e):
	position = e.position


func as_text():
	return "InputEventSingleScreenTap : position=" + str(position)
