class_name InputEventMultiScreenDrag
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var fingers    : int
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		fingers  = raw_gesture.size()
		position = raw_gesture.centroid("drags", "position")
		relative = event.relative/fingers 

func as_string() -> String:
	return "position=" + str(position) + "|relative=" + str(relative) + "|fingers=" + str(fingers)
