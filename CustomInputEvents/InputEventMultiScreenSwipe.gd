class_name InputEventMultiScreenSwipe
extends InputEventAction

var position
var relative 
var speed 
var fingers 
var rawGesture 

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	fingers = rawGesture.size()
	position = rawGesture.centroid("presses", "position")
	relative = rawGesture.centroid("releases", "position") - position
	speed = relative/rawGesture.elapsed_time

func as_text():
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
