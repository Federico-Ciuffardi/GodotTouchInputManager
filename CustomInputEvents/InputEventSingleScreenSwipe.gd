class_name InputEventSingleScreenSwipe
extends InputEventAction

var position
var relative 
var speed 
var rawGesture

func _init(_rawGesture : RawGesture):
	rawGesture = _rawGesture
	position = rawGesture.presses[0].position
	relative = rawGesture.releases[0].position - position
	speed = relative/rawGesture.elapsed_time


func as_text():
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)
