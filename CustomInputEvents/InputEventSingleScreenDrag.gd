class_name InputEventSingleScreenDrag
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		var dragEvent = raw_gesture.drags.values()[0]
		position = dragEvent.position
		relative = dragEvent.relative
		speed    = dragEvent.speed


func as_text():
	return "position=" + str(position) + "|relative=" + str(relative) + "|speed=" + str(speed)
