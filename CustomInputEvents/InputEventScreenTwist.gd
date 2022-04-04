class_name InputEventScreenTwist
extends InputEventAction

var position   : Vector2
var relative   : float
var speed      : float
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture, last_time) -> void:
	rawGesture = _rawGesture
	fingers  = rawGesture.drags.size()
	position = rawGesture.centroid("drags", "position")
		
	speed    = 0
	relative = 0
	var last_events : Array = rawGesture.rollback_absolute(last_time)[1]
	for event in last_events:
		if event is RawGesture.Drag:
			speed += event.speed.length()
			var centroid_relative_position = event.position - position
			relative += centroid_relative_position.angle_to(centroid_relative_position + event.relative)
	relative /= fingers
	speed    /= fingers


func as_text() -> String:
	return "InputEventScreenTwist : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) +", fingers=" + str(fingers)
