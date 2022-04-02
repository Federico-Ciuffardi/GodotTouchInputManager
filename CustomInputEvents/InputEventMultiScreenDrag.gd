class_name InputEventMultiScreenDrag
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture) -> void:
	rawGesture = _rawGesture
	fingers  = rawGesture.size()
	position = rawGesture.centroid("drags", "position")
	relative = rawGesture.centroid("drags", "relative")/fingers
	speed    = rawGesture.centroid("drags", "speed")

func as_text() -> String:
	return "InputEventMultiScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
