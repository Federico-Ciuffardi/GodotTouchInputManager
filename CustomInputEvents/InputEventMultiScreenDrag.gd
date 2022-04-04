class_name InputEventMultiScreenDrag
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture, last_time : float) -> void:
	rawGesture = _rawGesture
	fingers  = rawGesture.size()
	position = rawGesture.centroid("drags", "position")
	speed    = rawGesture.centroid("drags", "speed")
	relative = Vector2.ZERO
	var last_events : Array = rawGesture.rollback_absolute(last_time)[1]
	for event in last_events:
		if event is RawGesture.Drag:
			relative += event.relative
	relative /= fingers

func as_text() -> String:
	return "InputEventMultiScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
