class_name InputEventSingleScreenDrag
extends InputEventAction

var position
var relative
var speed

func _init(e):
	position = e.position
	relative = e.relative
	speed = e.speed

