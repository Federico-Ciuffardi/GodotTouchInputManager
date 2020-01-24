extends Node

# Custom InputEvents
var InputEventMultiScreenDrag = preload("CustomInputEvents/InputEventMultiScreenDrag.gd")
var InputEventScreenPinch = preload("CustomInputEvents/InputEventScreenPinch.gd")

#properties
var debug = false
var android = false
var DRAG_STARTUP_TIME = 0.02
var TOUCH_DELAY_TIME = 0.2

#signals
signal single_tap
signal single_touch
signal single_drag
signal multi_drag
signal pinch
signal any_gesture

#control
var last_mb = 0  # last mouse button pressed
var touches = {} # keeps track of all the touches
var drags = {}   # keeps track of all the drags

var touch_delay_timer = Timer.new()
var only_touch = null # last touch if there wasn't another touch at the same time

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
			if event.button_index == BUTTON_WHEEL_DOWN:
				emit("pinch",InputEventScreenPinch.new({"position":event.position,
														"relative":40.0}))
			elif event.button_index == BUTTON_WHEEL_UP:
				emit("pinch",InputEventScreenPinch.new({"position":event.position,
														"relative":-40.0}))
			last_mb = event.button_index
		else:
			last_mb = 0
			
	elif event is InputEventMouseMotion:
		if last_mb == BUTTON_MIDDLE:
			emit("multi_drag", InputEventMultiScreenDrag.new({"position":event.position,
															  "relative":event.relative,
															  "speed":event.speed}))
	
	# touch
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.get_index()] = event 
			if (event.get_index() == 0): # first and only touch
				emit("single_touch", event)
				only_touch = event
				if touch_delay_timer.is_stopped(): touch_delay_timer.start(TOUCH_DELAY_TIME)
			else:
				only_touch = null
				cancel_single_drag()
		else:
			if event.get_index() == 0 and only_touch:
				emit("single_touch", event)
			touches.erase(event.get_index())
			drags.erase(event.get_index())
			cancel_single_drag()
				
				
	elif event is InputEventScreenDrag:
		drags[event.index] = event
		if !complex_gesture_in_progress():
			if(drag_enabled):
				emit("single_drag", event)
			else:
				if drag_startup_timer.is_stopped(): drag_startup_timer.start(DRAG_STARTUP_TIME)
		else:
			cancel_single_drag()
			if is_pinch(drags):
				emit("pinch", InputEventScreenPinch.new(drags))
			else:
				emit("multi_drag", InputEventMultiScreenDrag.new(drags))

# emits_signal sig with the specified args
func emit(sig,val):
	if debug: print(sig,": ", val)
	emit_signal("any_gesture",sig,val)
	emit_signal(sig,val)

# disables drag and stops the drag enabling timer
func cancel_single_drag():
	drag_enabled = false
	drag_startup_timer.stop()
	
# checks if complex gesture (more than one finger) is in progress
func complex_gesture_in_progress():
	return touches.size() > 1

# checks if the gesture is pinch 
func is_pinch(drags):
	var sum = Vector2()
	for e in drags.values():
		sum += e.relative.normalized()
	return sum.length() < 1

func on_touch_delay_timer_timeout():
	if only_touch:
		emit("single_tap", only_touch)

func on_drag_startup_timeout():
	drag_enabled = !complex_gesture_in_progress() and drags.size() > 0
