class_name InputEventScreenTwist
extends InputEventAction

var position   : Vector2
var relative   : float
var fingers    : int
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		fingers  = raw_gesture.drags.size()
		position = raw_gesture.centroid("drags", "position")
			
		var centroid_relative_position = event.position - position
		relative = centroid_relative_position.angle_to(centroid_relative_position + event.relative)/fingers

func as_string() -> String:
	return "position=" + str(position) + "|relative=" + str(relative) + "|fingers=" + str(fingers)
