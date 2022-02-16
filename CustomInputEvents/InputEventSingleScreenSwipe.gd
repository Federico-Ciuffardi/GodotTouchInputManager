class_name InputEventSingleScreenSwipe
extends InputEventAction

var position
var relative 
var speed 

func _init(p1, p2, dt):
	position = p1
	relative = p2 - p1
	speed = relative/dt


func as_text():
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)
