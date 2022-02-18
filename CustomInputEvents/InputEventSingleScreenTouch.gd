class_name InputEventSingleScreenTouch
extends InputEventAction

var position   : Vector2
var cancelled  : bool
var rawGesture : RawGesture


func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	position = rawGesture.presses[0].position
	pressed = 0 in rawGesture.releases
	cancelled = rawGesture.size() > 1

func as_text():
	return "InputEventSingleScreenTouch : position=" + str(position) + ", pressed=" + str(pressed) + ", cancelled=" + str(cancelled)
