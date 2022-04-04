class_name InputEventSingleScreenSwipe
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture = null) -> void:
	rawGesture = _rawGesture
	if rawGesture:
		position = rawGesture.presses[0].position
		relative = rawGesture.releases[0].position - position
		speed = relative/rawGesture.elapsed_time


func as_text() -> String:
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)
