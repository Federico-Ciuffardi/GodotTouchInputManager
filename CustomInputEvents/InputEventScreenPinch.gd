class_name InputEventScreenPinch
extends InputEventAction

var position
var relative
var distance 
var speed

func _init(dict):
	if dict.has("position"):
		position = dict["position"] 
		relative = dict["relative"] 
		distance = dict["distance"] 
		speed    = dict["speed"] 
	else:
		position = get_events_property_avg(dict, "position")
		speed    = get_events_property_avg_length(dict, "speed")
		
		distance = 0
		relative = 0
		for e in dict.values():
			distance += (e.position - position).length()
			relative += (e.position + (e.relative / dict.size()) - position).length()
		relative -= distance


func as_text():
	return "InputEventScreenPinch : position=" + str(position) + ", relative=" + str(relative) +", distance ="+str(distance) +", speed=" + str(speed)


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
