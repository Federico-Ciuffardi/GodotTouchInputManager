class_name InputEventSingleScreenDrag
extends InputEventAction

var position   : Vector2
var relative   : Vector2
var speed      : Vector2
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	var dragEvent = rawGesture.drags.values()[0]
	position = dragEvent.position
	relative = dragEvent.relative
	speed    = dragEvent.speed


func as_text():
	return "InputEventSingleScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)
