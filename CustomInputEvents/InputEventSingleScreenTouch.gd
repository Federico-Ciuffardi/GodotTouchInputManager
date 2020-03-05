class_name InputEventSingleScreenTouch
extends InputEventAction

var position

func _init(e):
	position = e.position
	pressed = e.pressed


func as_text():
	return "InputEventSingleScreenTouch : position=" + str(position) + ", pressed=" + str(pressed)
