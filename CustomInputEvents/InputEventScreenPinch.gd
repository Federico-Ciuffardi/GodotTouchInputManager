class_name InputEventScreenPinch
extends InputEventAction

var position   : Vector2
var relative   : float
var distance   : float
var fingers    : int
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		fingers  = raw_gesture.drags.size()
		position = raw_gesture.centroid("drags", "position")

		distance = 0
		for drag in raw_gesture.drags.values():
			var centroid_relative_position = drag.position - position
			distance += centroid_relative_position.length()

		var centroid_relative_position = event.position - position
		relative = ((centroid_relative_position + event.relative).length() - centroid_relative_position.length())


func as_string() -> String:
	return "position=" + str(position) + "|relative=" + str(relative) +"|distance ="+str(distance) + "|fingers=" + str(fingers)
