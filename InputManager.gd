extends Node

# Signals.
# warning-ignore-all:unused_signal
signal single_tap
signal single_touch
signal single_drag
signal multi_drag
signal pinch
signal twist
signal any_gesture

# Enum.
enum Gestures {PINCH, MULTI_DRAG, TWIST}

# Constants.
const debug = false
const DRAG_STARTUP_TIME = 0.02
const TOUCH_DELAY_TIME = 0.2

# Control.
var last_mouse_press = null  # Last mouse button pressed.
var touches = {} # Keeps track of all the touches.
var drags = {}   # Keeps track of all the drags.

var tap_delay_timer = Timer.new()
var only_touch = null # Last touch if there wasn't another touch at the same time.

var drag_startup_timer = Timer.new()
var drag_enabled = false 


## Creates the required timers and connects their timeouts.
func _ready():
	_add_timer(tap_delay_timer, "on_tap_delay_timer_timeout")
	_add_timer(drag_startup_timer, "on_drag_startup_timeout")


## Handles all unhandled inputs emiting the corresponding signals.
func _unhandled_input(event):
	# Mouse to gesture.
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == BUTTON_WHEEL_DOWN:
				emit("pinch", InputEventScreenPinch.new({
					"position": event.position,
					"distance": 200.0,
					"relative": -40.0,
					"speed"   : 25.0
				}))
			elif event.button_index == BUTTON_WHEEL_UP:
				emit("pinch", InputEventScreenPinch.new({
					"position": event.position,
					"distance": 200.0,
					"relative": 40.0,
					"speed"   : 25.0
				}))
			last_mouse_press = event
		else:
			last_mouse_press = null
		
	elif event is InputEventMouseMotion:
		if last_mouse_press:
			if last_mouse_press.button_index == BUTTON_MIDDLE:
				emit("multi_drag", InputEventMultiScreenDrag.new({"position": event.position,
																  "relative": event.relative,
																  "speed": event.speed}))
			elif last_mouse_press.button_index == BUTTON_RIGHT:
				var rel1 = event.position - last_mouse_press.position
				var rel2 = rel1 + event.relative
				emit("twist", InputEventScreenTwist.new({"position": last_mouse_press.position,
															 "relative": rel1.angle_to(rel2),
															 "speed": event.speed}))
	
	# Touch.
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.get_index()] = event 
			if (event.get_index() == 0): # First and only touch.
				emit("single_touch", InputEventSingleScreenTouch.new(event))
				only_touch = event
				if tap_delay_timer.is_stopped(): tap_delay_timer.start(TOUCH_DELAY_TIME)
			else:
				only_touch = null
				cancel_single_drag()
		else:
			if event.get_index() == 0 and only_touch:
				emit("single_touch", InputEventSingleScreenTouch.new(event))
			touches.erase(event.get_index())
			drags.erase(event.get_index())
			cancel_single_drag()
		
	elif event is InputEventScreenDrag:
		drags[event.index] = event
		if !complex_gesture_in_progress():
			if(drag_enabled):
				emit("single_drag", InputEventSingleScreenDrag.new(event))
			else:
				if drag_startup_timer.is_stopped(): drag_startup_timer.start(DRAG_STARTUP_TIME)
		else:
			cancel_single_drag()
			var gesture = identify_gesture(drags)
			if gesture == Gestures.PINCH:
				emit("pinch", InputEventScreenPinch.new(drags))
			elif gesture == Gestures.MULTI_DRAG:
				emit("multi_drag", InputEventMultiScreenDrag.new(drags))
			elif gesture == Gestures.TWIST:
				emit("twist",InputEventScreenTwist.new(drags))


# Emits signal sig with the specified args.
func emit(sig, val):
	if debug: print(val.as_text())
	emit_signal("any_gesture", sig, val)
	emit_signal(sig, val)
	Input.parse_input_event(val)


# Disables drag and stops the drag enabling timer.
func cancel_single_drag():
	drag_enabled = false
	drag_startup_timer.stop()


# Checks if complex gesture (more than one finger) is in progress.
func complex_gesture_in_progress():
	return touches.size() > 1


# Checks if the gesture is pinch.
func identify_gesture(gesture_drags):
	var center = Vector2()
	for e in gesture_drags.values():
		center += e.position
	center /= gesture_drags.size()
	
	var sector = null
	for e in gesture_drags.values():
		var adjusted_position = center - e.position
		var raw_angle = fmod(adjusted_position.angle_to(e.relative) + (PI/4), TAU) 
		var adjusted_angle = raw_angle if raw_angle >= 0 else raw_angle + TAU
		var e_sector = floor(adjusted_angle / (PI/2))
		if sector == null: 
			sector = e_sector
		elif sector != e_sector:
			sector = -1
	
	if sector == -1:               return Gestures.MULTI_DRAG
	if sector == 0 or sector == 2: return Gestures.PINCH
	if sector == 1 or sector == 3: return Gestures.TWIST


func on_tap_delay_timer_timeout():
	if only_touch and touches.size() == 0:
		emit("single_tap", InputEventSingleScreenTap.new(only_touch))


func on_drag_startup_timeout():
	drag_enabled = !complex_gesture_in_progress() and drags.size() > 0


# Macro to add a timer and connect it's timeout to func_name.
func _add_timer(timer, func_name):
	timer.one_shot = true
	timer.connect("timeout", self, func_name)
	self.add_child(timer)
