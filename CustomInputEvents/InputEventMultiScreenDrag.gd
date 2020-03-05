class_name InputEventMultiScreenDrag
extends InputEventAction

var position
var relative
var speed

func _init(dict):
	if dict.has("position"):
		self.position = dict["position"] 
		self.relative = dict["relative"] 
		self.speed    = dict["speed"] 
	else:
		self.position = get_events_property_avg(dict,"position")
		self.relative = get_events_property_avg(dict,"relative") / dict.size()
		self.speed    = get_events_property_avg(dict,"speed")


func as_text():
	return "InputEventMultiScreenDrag : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)


# Aux.
func get_events_property_avg(events, property):
	var sum = Vector2()
	for e in events.values():
		sum += e.get(property)
	return sum / events.size()
