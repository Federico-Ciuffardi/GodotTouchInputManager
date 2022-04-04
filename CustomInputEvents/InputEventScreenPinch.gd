class_name InputEventScreenPinch
extends InputEventAction

var position   : Vector2
var relative   : float
var distance   : float
var speed      : float
var fingers    : int
var rawGesture : RawGesture

func _init(_rawGesture : RawGesture, last_time) -> void:
	rawGesture = _rawGesture
	fingers  = rawGesture.drags.size()
	position = rawGesture.centroid("drags", "position")

	speed = 0
	distance = 0
	relative = 0 
	var last_events : Array = rawGesture.rollback_absolute(last_time)[1]
	for event in last_events:
		if event is RawGesture.Drag:
			speed += event.speed.length()
			var centroid_relative_position = event.position - position
			distance += (centroid_relative_position).length()
			relative += (centroid_relative_position + event.relative).length()
	relative -= distance
	speed    /= fingers


func as_text() -> String:
	return "InputEventScreenPinch : position=" + str(position) + ", relative=" + str(relative) +", distance ="+str(distance) +", speed=" + str(speed) +", fingers=" + str(fingers)
