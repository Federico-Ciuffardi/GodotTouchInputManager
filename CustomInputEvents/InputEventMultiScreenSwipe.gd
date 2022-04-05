class_name InputEventMultiScreenSwipe
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var fingers    : int 
var raw_gesture : RawGesture 

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		fingers = raw_gesture.size()
		position = raw_gesture.centroid("presses", "position")
		relative = raw_gesture.centroid("releases", "position") - position
		speed = relative/raw_gesture.elapsed_time

func as_text() -> String:
	return "position=" + str(position) + "|relative=" + str(relative) + "|speed=" + str(speed) + "|fingers=" + str(fingers)
