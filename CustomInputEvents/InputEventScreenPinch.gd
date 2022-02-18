class_name InputEventScreenPinch
extends InputEventAction

var position
var relative
var distance 
var speed
var fingers 
var rawGesture 

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	fingers  = rawGesture.drags.size()
	position = rawGesture.centroid("drags", "position")

	speed = 0
	distance = 0
	relative = 0 
	for drag in rawGesture.drags.values():
		speed += drag.speed.length()
		var centroid_relative_position = drag.position - position
		distance += (centroid_relative_position).length()
		relative += (centroid_relative_position + (drag.relative / fingers)).length()
	relative -= distance
	speed    /= fingers


func as_text():
	return "InputEventScreenPinch : position=" + str(position) + ", relative=" + str(relative) +", distance ="+str(distance) +", speed=" + str(speed) +", fingers=" + str(fingers)
