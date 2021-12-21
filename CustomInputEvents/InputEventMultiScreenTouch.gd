class_name InputEventMultiScreenTouch
extends InputEventAction

var position

func _init(e):
	position = e.position
	pressed = e.pressed


func as_text():
	return "InputEventMultiScreenTouch : position=" + str(position) + ", pressed=" + str(pressed)
