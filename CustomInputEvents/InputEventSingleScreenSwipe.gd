class_name InputEventSingleScreenSwipe
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		position = raw_gesture.presses[0].position
		relative = raw_gesture.releases[0].position - position
		speed = relative/raw_gesture.elapsed_time


func as_text() -> String:
	return "position=" + str(position) + "|relative=" + str(relative) + "|speed=" + str(speed)
