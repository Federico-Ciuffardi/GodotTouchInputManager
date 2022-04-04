class_name InputEventScreenPinch
extends InputEventAction

var position   : Vector2
var relative   : float
var distance   : float
var speed      : float
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	rawGesture = _rawGesture
	if rawGesture:
		fingers  = rawGesture.drags.size()
		position = rawGesture.centroid("drags", "position")

		speed = event.speed.length()

		var centroid_relative_position = event.position - position
		speed    = event.speed.length()
		distance = (centroid_relative_position).length()
		relative = ((centroid_relative_position + event.relative).length() - distance)/fingers

func as_text() -> String:
	return "InputEventScreenPinch : position=" + str(position) + ", relative=" + str(relative) +", distance ="+str(distance) +", speed=" + str(speed) +", fingers=" + str(fingers)
