class_name InputEventMultiScreenTap
extends InputEventAction

var position
var fingers 
var rawGesture 

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	fingers = rawGesture.size()
	position = rawGesture.centroid("presses", "position")

func as_text():
	return "InputEventSingleScreenTap : position=" + str(position) + ", fingers=" + str(fingers)
