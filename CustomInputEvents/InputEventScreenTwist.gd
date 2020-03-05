class_name InputEventScreenTwist
extends InputEventAction

var position
var relative
var speed

func _init(dict):
	if dict.has("position"):
		position = dict["position"] 
		relative = dict["relative"] 
		speed    = dict["speed"] 
	else:
		position = get_events_property_avg(dict, "position")
		speed    = get_events_property_avg_length(dict, "speed")
		
		relative = 0
		for e in dict.values():
			relative += (e.position - position).angle_to(e.position + (e.relative / dict.size()) - position)
		relative = (relative / dict.size())


func as_text():
	return "InputEventScreenTwist : position=" + str(position) + ", relative=" + str(relative) + ", speed=" + str(speed)


# Aux.
func get_events_property_avg(events, property):
	var sum = Vector2()
	for e in events.values():
		sum += e.get(property)
	return sum / events.size()


func get_events_property_avg_length(events, property):
	var sum = 0
	for e in events.values():
		sum += e.get(property).length()
	return sum / events.size()
