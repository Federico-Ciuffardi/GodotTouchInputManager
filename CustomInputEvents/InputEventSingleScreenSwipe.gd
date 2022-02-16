class_name InputEventSingleScreenSwipe
extends InputEventAction

var position
var relative 
var speed 

func _init(e1, e2, dt):
	position = e1.position
	relative = e2.position - e1.position
	speed = relative/dt


func as_text():
	return "InputEventSingleScreenSwipe : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)
