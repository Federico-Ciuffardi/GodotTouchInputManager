class_name InputEventScreenTwist
extends InputEventAction

var position
var relative
var speed
var fingers 
var rawGesture 

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	fingers  = rawGesture.drags.size()
	position = rawGesture.centroid("drags", "position")
		
	speed    = 0
	relative = 0
	for drag in rawGesture.drags.values():
		speed += drag.speed.length()
		var centroid_relative_position = drag.position - position
		relative += centroid_relative_position.angle_to(centroid_relative_position + (drag.relative / fingers))
	relative /= fingers
	speed    /= fingers


func as_text():
	return "InputEventScreenTwist : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) +", fingers=" + str(fingers)
