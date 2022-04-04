class_name InputEventMultiScreenDrag
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	rawGesture = _rawGesture
	if rawGesture:
		fingers  = rawGesture.size()
		position = rawGesture.centroid("drags", "position")
		speed    = rawGesture.centroid("drags", "speed")
		relative = event.relative/fingers 

func as_text() -> String:
	return "InputEventMultiScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
