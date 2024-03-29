class_name InputEventMultiScreenTap
extends InputEventAction

var position   : Vector2
var positions  : Array
var fingers    : int
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture: 
		fingers = raw_gesture.size()
		position = raw_gesture.centroid("presses", "position")
		positions = raw_gesture.get_property_array("presses", "position")

func as_string() -> String:
	return "position=" + str(position) + "|fingers=" + str(fingers)
