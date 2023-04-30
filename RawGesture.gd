# warning-ignore-all:return_value_discarded

extends InputEventAction
class_name RawGesture 

#########
# Const #
#########

const Util : GDScript = preload("Util.gd")

###########
# Classes #
###########

class Event:
	var time  : float = -1 # (secs)
	var index : int   = -1
	func as_string() -> String:
		return "ind: " + str(index) + " | time: " + str(time)

class Touch:
	extends Event
	var position : Vector2 = Vector2.ZERO
	var pressed  : bool 
	func as_string() -> String:
		return super.as_string() + " | pos: " + str(position) + " | pressed: " + str(pressed)


class Drag:
	extends Event
	var position  : Vector2 = Vector2.ZERO
	var relative  : Vector2 = Vector2.ZERO
	var velocity     : Vector2 = Vector2.ZERO

	func as_string() -> String:
		return super.as_string() + " | pos: " + str(position) + " | relative: " + str(relative)


#############
# Variables #
#############

var presses  : Dictionary # Touch
var releases : Dictionary # Touch
var drags    : Dictionary # Drag
var history  : Dictionary # Array of events

var active_touches : int   = 0

var start_time     : float = -1 # (secs)
var elapsed_time   : float = -1 # (secs)

#############
# Functions #
#############

func size() -> int:
	return presses.size()

func centroid(events_name : String , property_name : String):
	var arr : Array = get(events_name).values()
	arr = Util.map_callv(arr , "get", [property_name])
	return Util.centroid(arr)

func get_ends() -> Dictionary:
	var ends : Dictionary = {}

	for i in presses:
		ends[i] = presses[i].position

	for i in drags:
		ends[i] = drags[i].position

	for i in releases:
		ends[i] = releases[i].position

	return ends

# Check for gesture consistency
func is_consistent(diff_limit : float, length_limit : float = -1) -> bool:
	if length_limit == -1: length_limit = length_limit

	var ends : Dictionary = get_ends()

	var ends_centroid   : Vector2 = Util.centroid(ends.values())
	var starts_centroid : Vector2 = centroid("presses", "position")

	var valid : bool = true
	for i in ends:
		var start_relative_position : Vector2 = presses[i].position  - starts_centroid
		var end_relative_position   : Vector2 = ends[i] - ends_centroid 
		
		valid = start_relative_position.length() < length_limit and \
						end_relative_position.length()   < length_limit and \
						(end_relative_position - start_relative_position).length() < diff_limit

		if !valid:
			break

	return valid

func rollback_relative(time : float) -> Array:
	return rollback_absolute(start_time+elapsed_time - time)

func rollback_absolute(time : float) -> Array:
	var discarded_events : Array = []
	var rg : RawGesture = copy()

	var latest_event_id : Array = rg.latest_event_id(time)
	while !latest_event_id.is_empty():
		var latest_index  : int    = latest_event_id[0]
		var latest_type   : String = latest_event_id[1]
		var latest_event = rg.history[latest_index][latest_type].pop_back()
		discarded_events.append(latest_event)
		if latest_type == "presses":
			rg.active_touches -= 1
		elif latest_type == "releases":
			rg.active_touches += 1
		if rg.history[latest_index][latest_type].is_empty():
			rg.history[latest_index].erase(latest_type)
			if rg.history[latest_index].is_empty():
				rg.history.erase(latest_index)
		latest_event_id = rg.latest_event_id(time)

	for index in rg.presses.keys():
		if rg.history.has(index):
			if rg.history[index].has("presses"):
				var presses_history: Array = rg.history[index]["presses"]
				rg.presses[index] = presses_history.back()
			else:
				rg.presses.erase(index)

			if rg.history[index].has("releases"):
				var releases_history : Array = rg.history[index]["releases"]
				# !releases_history.empty() -> rg.presses.has(index) (touch precedes a release)
				if releases_history.back().time < rg.presses[index].time: 
					rg.releases.erase(index)
				else:
					rg.releases[index] = releases_history.back()
			else:
				rg.releases.erase(index)

			if rg.history[index].has("drags"):
				var drags_history : Array = rg.history[index]["drags"]
				# rg.releases.has(index) -> rg.releases[index].time >= rg.presses[index].time ->
				# rg.releases[index] >= drags_history.back().time (drag should needs a new touch after the release)
				if rg.releases.has(index):
					rg.drags.erase(index)
				else:
					rg.drags[index] = drags_history.back()
			else:
				rg.drags.erase(index)
		else:
			rg.presses.erase(index)
			rg.releases.erase(index)
			rg.drags.erase(index)

	return [rg, discarded_events]

func get_linear_event_history():
	return rollback_absolute(0)[1]

func copy() -> RawGesture:
	var rg : RawGesture = get_script().new()
	rg.presses           = presses.duplicate(true)        
	rg.releases          = releases.duplicate(true)
	rg.drags             = drags.duplicate(true)   
	rg.history           = history.duplicate(true)
	rg.active_touches    = active_touches
	rg.start_time        = start_time    
	rg.elapsed_time      = elapsed_time 
	return rg 

func latest_event_id(latest_time : float = -1) -> Array:
	var res : Array = []
	for index in history:
		for type in history[index]:
			var event_time = history[index][type].back().time
			if event_time >= latest_time:
				res = [index, type]
				latest_time = event_time
	return res

func as_string() -> String:
	var txt = "presses: "
	for e in presses.values():
		txt += "\n" + e.as_string()
	txt += "\ndrags: "
	for e in drags.values():
		txt += "\n" + e.as_string()
	txt += "\nreleases: "
	for e in releases.values():
		txt += "\n" + e.as_string()
	return txt

func _update_screen_drag(event : InputEventScreenDrag, time : float = -1) -> void:
	if time < 0:
		time = Util.now()
	var drag : Drag = Drag.new()
	drag.position  = event.position
	drag.relative  = event.relative
	drag.velocity  = event.velocity
	drag.index     = event.index 
	drag.time      = time
	_add_history(event.index, "drags", drag)
	drags[event.index] = drag
	elapsed_time = time - start_time
	
func _update_screen_touch(event : InputEventScreenTouch, time : float = -1) -> void:
	if time < 0:
		time = Util.now()
	var touch : Touch = Touch.new()
	touch.position = event.position
	touch.pressed  = event.pressed
	touch.index    = event.index 
	touch.time     = time
	if event.pressed:
		_add_history(event.index, "presses", touch)
		presses[event.index] = touch
		active_touches += 1
		releases.erase(event.index)
		drags.erase(event.index)
		if active_touches == 1:
			start_time = time
	else:
		_add_history(event.index, "releases", touch)
		releases[event.index] = touch
		active_touches -= 1
		drags.erase(event.index)
	elapsed_time = time - start_time

func _add_history(index : int, type : String, value) -> void:
	if !history.has(index): 
		history[index] = {}
	if !history[index].has(type): 
		history[index][type] = []
	history[index][type].append(value)
