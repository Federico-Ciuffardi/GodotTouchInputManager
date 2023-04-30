class_name InputEventScreenCancel
extends InputEventAction

var raw_gesture : RawGesture
var event       : InputEvent

func _init(_raw_gesture : RawGesture, _event : InputEvent) -> void:
	raw_gesture = _raw_gesture
	event       = _event

func as_string() -> String:
	return "gesture canceled"
