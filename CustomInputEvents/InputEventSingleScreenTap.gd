class_name InputEventSingleScreenTap
extends InputEventAction

var position   : Vector2
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	position = rawGesture.presses[0].position


func as_text():
	return "InputEventSingleScreenTap : position=" + str(position)
