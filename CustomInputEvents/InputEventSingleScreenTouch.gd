class_name InputEventSingleScreenTouch
extends InputEventAction

var position : Vector2
var cancelled : bool

func _init(e : InputEventScreenTouch, cancel : bool):
	position = e.position
	pressed = e.pressed
	cancelled = cancel


func as_text():
	return "InputEventSingleScreenTouch : position=" + str(position) + ", pressed=" + str(pressed) + ", cancelled=" + str(cancelled)
