class_name InputEventMultiScreenDrag
extends InputEventAction

var position
var relative
var speed
var fingers 
var rawGesture 

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	fingers  = rawGesture.size()
	position = rawGesture.centroid("drags", "position")
	relative = rawGesture.centroid("drags", "relative")/fingers
	speed    = rawGesture.centroid("drags", "speed")

func as_text():
	return "InputEventMultiScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
