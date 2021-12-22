class_name InputEventMultiScreenTouch
extends InputEventAction

var position
var index

func _init(e):
	position = e.position
	pressed = e.pressed
	index = e.index


func as_text():
	return "InputEventMultiScreenTouch : position=" + str(position) + ", pressed=" + str(pressed) + ", index=" + str(index)
