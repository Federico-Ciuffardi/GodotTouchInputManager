class_name InputEventMultiScreenTap
extends InputEventAction

var position
var fingers 

func _init(e, f):
	position = e.position
	fingers = f

func as_text():
	return "InputEventSingleScreenTap : position=" + str(position) + ", fingers=" + str(fingers)
