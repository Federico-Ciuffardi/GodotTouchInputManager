class_name InputEventScreenPinch
extends InputEventAction

var position   : Vector2
var relative   : float
var distance   : float
var speed      : float
var fingers    : int
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		fingers  = raw_gesture.drags.size()
		position = raw_gesture.centroid("drags", "position")

		speed = event.speed.length()

		var centroid_relative_position = event.position - position
		speed    = event.speed.length()
		distance = (centroid_relative_position).length()
		relative = ((centroid_relative_position + event.relative).length() - distance)/fingers

func as_text() -> String:
	return "position=" + str(position) + "|relative=" + str(relative) +"|distance ="+str(distance) +"|speed=" + str(speed) +"|fingers=" + str(fingers)
