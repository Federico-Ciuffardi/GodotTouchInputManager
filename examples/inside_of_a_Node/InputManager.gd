extends Node

#properties
var debug = false
var android = false
var DRAG_STARTUP_TIME = 0.01
var TOUCH_DELAY_TIME = 0.2

#signals
signal single_touch #pos
signal single_drag  #pos, relpos
signal multi_drag   #relpos
signal pinch        #pos, intensity

#control
var last_mb = 0  # last mouse button pressed
var touches = {} # keeps track of all the touches
var drags = {}   # keeps track of all the drags

var touch_delay_timer = Timer.new()
var only_touch = null # last touch if it isn't part of a geture

var drag_startup_timer = Timer.new()
var drag_enabled = false 

## creates the required timers and connects their timeouts
func _ready():
	add_timer(touch_delay_timer,"on_touch_delay_timer_timeout")
	add_timer(drag_startup_timer,"on_drag_startup_timeout")

# macro to add a timer and connect it's timeout to func_name
func add_timer(timer,func_name):
	timer.one_shot = true
	timer.connect("timeout",self,func_name)
	self.add_child(timer)

## Handles all unhandled inputs emiting the corresponding signals
func _unhandled_input(event):
	# mouse to gesture
	if event is InputEventMouseButton:
		if event.pressed:
			if(event.button_index == BUTTON_WHEEL_DOWN):
				emit("pinch", [event.position,0.2])
			elif(event.button_index == BUTTON_WHEEL_UP):
				emit("pinch",[event.position,-0.2])
			last_mb = event.button_index
		else:
			last_mb = 0
			
	elif event is InputEventMouseMotion:
		if last_mb == BUTTON_MIDDLE:
			emit("multi_drag", [event.position, event.relative])
	
	# Touch
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.get_index()] = event 
			if (event.get_index() == 0): # first and only touch
				only_touch = event
				if touch_delay_timer.is_stopped(): touch_delay_timer.start(TOUCH_DELAY_TIME)
			else:
				start_complex_gesture()
				drag_enabled = false
		else:
			touches.erase(event.get_index())
			drags.erase(event.get_index())
			if(touches.size()==0):
				drag_enabled = false
				
	elif event is InputEventScreenDrag:
		drags[event.index] = event
		if !complex_gesture_in_progress():
			if(drag_enabled):
				emit("single_drag", [event.position,event.relative])
			else:
				if drag_startup_timer.is_stopped(): drag_startup_timer.start(DRAG_STARTUP_TIME)
		if complex_gesture_in_progress():
				if is_pinch(drags):
					emit("pinch",[gesture_center(drags),pinch_intensity(drags)])
				else:
					emit("multi_drag", [gesture_center(drags),gesture_displacement(drags)])

# emits_signal sig with the specified args
func emit(sig,args):
	if debug: print(sig,": ", args)
	args.push_front(sig)
	callv("emit_signal",args)

# starts complex gesture (more than one finger) is in progress
func start_complex_gesture():
	only_touch = null

# checks if complex gesture (more than one finger) is in progress
func complex_gesture_in_progress():
	return only_touch == null

# checks if the gesture is pinch 
func is_pinch(drags):
	var dvals = drags.values()
	return (dvals[0].relative.normalized() + dvals[1].relative.normalized()).length() < 1

func pinch_intensity(events):
	var pos0_i = events[0].position
	var pos0_f = pos0_i + events[0].relative
	
	var pos1_i = events[1].position
	var pos1_f = pos1_i + events[1].relative
	
	var raw_pinch = pos0_i.distance_to(pos1_i) - pos0_f.distance_to(pos1_f)
	
	return (raw_pinch)/200

func gesture_center(events):
	var sum = Vector2()
	for e in events.values():
		sum += e.position
	return sum/events.size()

func gesture_displacement(events):
	var sum = Vector2()
	for e in events.values():
		sum += e.relative
	return (sum)/events.size()

func on_touch_delay_timer_timeout():
	if !complex_gesture_in_progress():
		emit("single_touch", [only_touch.position])

func on_drag_startup_timeout():
	drag_enabled = !complex_gesture_in_progress()
