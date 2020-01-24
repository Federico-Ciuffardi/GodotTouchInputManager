extends Object

var position
var relative
var speed

func _init(dict):
	if dict.has("position"):
		self.position = dict["position"] 
		self.relative = dict["relative"] 
	else:
		self.position = get_events_property_avg(dict,"position")
		self.relative = pinch_relative_distance(dict)
# aux
func get_events_property_avg(events,property):
	var sum = Vector2()
	for e in events.values():
		sum += e.get(property)
	return sum/events.size()
	
func pinch_relative_distance(events):
	var pos0_i = events[0].position
	var pos0_f = pos0_i + events[0].relative
	
	var pos1_i = events[1].position
	var pos1_f = pos1_i + events[1].relative
	
	return pos0_i.distance_to(pos1_i) - pos0_f.distance_to(pos1_f)