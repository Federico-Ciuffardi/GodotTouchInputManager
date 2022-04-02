class_name InputEventMultiScreenSwipe
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var fingers    : int 
var rawGesture : RawGesture 

func _init(_rawGesture : RawGesture) -> void:
	rawGesture = _rawGesture
	fingers = rawGesture.size()
	position = rawGesture.centroid("presses", "position")
	relative = rawGesture.centroid("releases", "position") - position
	speed = relative/rawGesture.elapsed_time

func as_text() -> String:
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
