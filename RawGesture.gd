#warning-ignore:unused_result

class_name RawGesture 

#########
# Const #
#########

var Util : Object = preload("Util.gd")

const SEC_IN_USEC : int = 1000000

###########
# Classes #
###########

class Event:
	var time : float = -1 # (secs)

class Touch:
	extends Event
	var position : Vector2 = Vector2.ZERO

class Drag:
	extends Event
	var position  : Vector2 = Vector2.ZERO
	var relative  : Vector2 = Vector2.ZERO
	var speed     : Vector2 = Vector2.ZERO


#############
# Variables #
#############

var presses  : Dictionary # Touch
var releases : Dictionary # Touch
var drags    : Dictionary # Drag

var active_touches : int   = 0

var start_time     : float = -1 # (secs)
var elapsed_time   : float = -1 # (secs)

#############
# Functions #
#############

func updateScreenDrag(event : InputEventScreenDrag, time : float = -1) -> void:
	time = _now() if time < 0 else time
	var drag : Drag = Drag.new()
	drag.position  = event.position
	drag.relative  = event.relative
	drag.speed     = event.speed
	drag.time      = time
	drags[event.index] = drag
	elapsed_time = time - start_time
	

func updateScreenTouch(event : InputEventScreenTouch, time : float = -1) -> void:
	time = _now() if time < 0 else time
	var touch : Touch = Touch.new()
	touch.position = event.position
	touch.time     = time
	if event.pressed:
		presses[event.index] = touch
		active_touches += 1
		if active_touches == 1:
			start_time = touch.time
	else:
		releases[event.index] = touch
		active_touches -= 1
		drags.erase(event.index)
	elapsed_time = time - start_time

func size() -> int:
	return presses.size()

func clear() -> void:
	presses.clear()
	releases.clear()       
	drags.clear()
	active_touches = 0

# Check for gesture consistency
func isConsistent(diff_limit : float, length_limit : float = -1) -> bool:
	if length_limit == -1: length_limit = length_limit
	var valid : bool = true
	var i : int = 0
	var presses_centroid  : Vector2 = centroid("presses", "position")
	var releases_centroid : Vector2 = centroid("releases", "position")
	while i < size() and valid:
		var press_relative_position   : Vector2 = presses[i].position   - presses_centroid
		var release_relative_position : Vector2 = releases[i].position - releases_centroid
		
		valid = press_relative_position.length()   < length_limit and \
						release_relative_position.length() < length_limit and \
						(release_relative_position - press_relative_position).length() < diff_limit
		i+=1

	return valid

func centroid(events_id : String , property_id : String):
	var arr : Array = get(events_id).values()
	arr = Util.map_callv(arr , "get", [property_id])
	return Util.centroid(arr)

func _now() -> float:
	return float(OS.get_ticks_usec())/SEC_IN_USEC
