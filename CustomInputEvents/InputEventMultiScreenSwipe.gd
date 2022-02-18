class_name InputEventMultiScreenSwipe
extends InputEventAction

var position
var relative 
var speed 
var fingers 

func _init(p1, p2, dt, f):
	position = p1
	relative = p2 - p1
	speed = relative/dt
	fingers = f


func as_text():
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed) + ", fingers=" + str(fingers)
