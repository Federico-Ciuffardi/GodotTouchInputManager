class_name InputEventScreenTwist
extends InputEventAction

var position   : Vector2
var relative   : float
var speed      : float
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture = null, event : InputEventScreenDrag = null) -> void:
	rawGesture = _rawGesture
	if rawGesture:
		fingers  = rawGesture.drags.size()
		position = rawGesture.centroid("drags", "position")
			
		var centroid_relative_position = event.position - position
		speed = event.speed.length()
		relative = centroid_relative_position.angle_to(centroid_relative_position + event.relative)/fingers

func as_text() -> String:
	return "InputEventScreenTwist : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) +", fingers=" + str(fingers)
