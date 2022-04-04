class_name InputEventSingleScreenTap
extends InputEventAction

var position   : Vector2
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture = null) -> void:
	rawGesture = _rawGesture
	if rawGesture:
		position = rawGesture.presses[0].position


func as_text() -> String:
	return "InputEventSingleScreenTap : position=" + str(position)
