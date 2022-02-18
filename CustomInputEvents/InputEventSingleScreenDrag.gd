class_name InputEventSingleScreenDrag
extends InputEventAction

var position
var relative
var speed
var rawGesture

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	var dragEvent = rawGesture.drags.values()[0]
	position = dragEvent.position
	relative = dragEvent.relative
	speed    = dragEvent.speed


func as_text():
	return "InputEventSingleScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)
