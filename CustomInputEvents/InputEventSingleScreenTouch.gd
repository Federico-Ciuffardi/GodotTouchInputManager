class_name InputEventSingleScreenTouch
extends InputEventAction

var position   : Vector2
var cancelled  : bool
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		position = raw_gesture.presses[0].position
		pressed = 0 in raw_gesture.releases
		cancelled = raw_gesture.size() > 1

func as_text() -> String:
	return "position=" + str(position) + "|pressed=" + str(pressed) + "|cancelled=" + str(cancelled)
