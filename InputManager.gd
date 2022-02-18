extends Node

# Const.
const SEC_IN_USEC = 1000000

## Config.
const debug = false

const DRAG_STARTUP_TIME = 0.02

const TAP_TIME_THRESHOLD     = 0.2 * SEC_IN_USEC
const TAP_DISTANCE_THRESHOLD = 25

const SWIPE_TIME_THRESHOLD     = 0.5 * SEC_IN_USEC
const SWIPE_DISTANCE_THRESHOLD = 200

# Signals.
# warning-ignore-all:unused_signal
signal single_tap
signal single_touch
signal single_drag
signal single_swipe
signal multi_drag
signal multi_tap
signal multi_swipe
signal pinch
signal twist
signal any_gesture

# Enum.
enum Gestures {PINCH, MULTI_DRAG, TWIST}

# Control.
var last_mouse_press = null  # Last mouse button pressed.
var touches = {} # Keeps track of all the touches.
var drags = {}   # Keeps track of all the drags.

var max_touch = 0

var tap_delay_timer = Timer.new()
var swipe_delay_timer = Timer.new()
var single_touch_cancelled = false

var drag_startup_timer = Timer.new()
var drag_enabled = false 


## Creates the required timers and connects their timeouts.
func _ready():
	_add_timer(drag_startup_timer, "on_drag_startup_timeout")


## Handles all unhandled inputs emiting the corresponding signals.
func _unhandled_input(event):
	# Keyboard to gesture.
	var swipe_emulation_dir = null
	if _action_pressed(event, "swipe_up"):
		swipe_emulation_dir = Vector2.UP
	elif _action_pressed(event,"swipe_up_right"):
		swipe_emulation_dir = Vector2.UP + Vector2.RIGHT
	elif _action_pressed(event,"swipe_right"):
		swipe_emulation_dir = Vector2.RIGHT
	elif _action_pressed(event,"swipe_down_right"):
		swipe_emulation_dir = Vector2.DOWN + Vector2.RIGHT
	elif _action_pressed(event,"swipe_down"):
		swipe_emulation_dir = Vector2.DOWN
	elif _action_pressed(event,"swipe_down_left"):
		swipe_emulation_dir = Vector2.DOWN + Vector2.LEFT
	elif _action_pressed(event,"swipe_left"):
		swipe_emulation_dir = Vector2.LEFT
	elif _action_pressed(event,"swipe_up_left"):
		swipe_emulation_dir = Vector2.UP + Vector2.LEFT

	if swipe_emulation_dir:
		var position = get_viewport().get_mouse_position()
		var relative = swipe_emulation_dir*SWIPE_DISTANCE_THRESHOLD*2
		var dt       = float(SWIPE_TIME_THRESHOLD)/SEC_IN_USEC
		emit("single_swipe", InputEventSingleScreenSwipe.new(position, position + relative, dt))

	# Mouse to gesture.
	elif event is InputEventMouseButton:
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
	
	# Native touch.
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.get_index()] = {"event": event, "time": OS.get_ticks_usec()}
			max_touch = max(max_touch,event.index)
			if (event.get_index() == 0): # First and only touch.
				single_touch_cancelled = false
				emit("single_touch", InputEventSingleScreenTouch.new(event, false))
			else:
				cancel_single_drag()
				if !single_touch_cancelled :
					single_touch_cancelled = true
					emit("single_touch", InputEventSingleScreenTouch.new(touches[0]["event"], true))
		else:
			if event.get_index() == 0:
				emit("single_touch", InputEventSingleScreenTouch.new(event, single_touch_cancelled))
				if !single_touch_cancelled:
					var distance = (event.position - touches[0]["event"].position).length()
					var elapsed_time = OS.get_ticks_usec() - touches[0]["time"] 
					if elapsed_time < TAP_TIME_THRESHOLD and distance <= TAP_DISTANCE_THRESHOLD:
							emit("single_tap", InputEventSingleScreenTap.new(touches[0]["event"]))
					if elapsed_time < SWIPE_TIME_THRESHOLD and distance > SWIPE_DISTANCE_THRESHOLD:
							emit("single_swipe", InputEventSingleScreenSwipe.new(touches[0]["event"].position, event.position, float(elapsed_time)/SEC_IN_USEC))
			if single_touch_cancelled and touches.size() == 1:
				var distance = (event.position - touches[event.index]["event"].position).length()
				var elapsed_time = OS.get_ticks_usec() - touches[event.index]["time"] 
				if elapsed_time < TAP_TIME_THRESHOLD and distance <= TAP_DISTANCE_THRESHOLD:
						emit("multi_tap", InputEventMultiScreenTap.new(touches[event.index]["event"], max_touch+1))
				if elapsed_time < SWIPE_TIME_THRESHOLD and distance > SWIPE_DISTANCE_THRESHOLD:
						emit("multi_swipe", InputEventMultiScreenSwipe.new(touches[event.index]["event"].position, event.position, float(elapsed_time)/SEC_IN_USEC, max_touch+1))
				max_touch = 0
			touches.erase(event.get_index())
			drags.erase(event.get_index())
			cancel_single_drag()
	# Native drag.
	elif event is InputEventScreenDrag:
		drags[event.index] = event
		if !complex_gesture_in_progress():
			if(drag_enabled):
				emit("single_drag", InputEventSingleScreenDrag.new(event))
			else:
				if drag_startup_timer.is_stopped(): drag_startup_timer.start(DRAG_STARTUP_TIME)
		else:
			cancel_single_drag()
			if drags.size() > 1 :
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

func on_drag_startup_timeout():
	drag_enabled = !complex_gesture_in_progress() and drags.size() > 0

#######
# AUX #
#######

# Check if the action is pressed
func _action_pressed(event, action):
	return InputMap.has_action(action) and event.is_action_pressed(action)

# Macro to add a timer and connect it's timeout to func_name.
func _add_timer(timer, func_name):
	timer.one_shot = true
	if func_name:
		timer.connect("timeout", self, func_name)
	self.add_child(timer)
