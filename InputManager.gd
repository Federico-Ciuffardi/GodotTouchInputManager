extends Node

#########
# CONST #
#########
const SEC_IN_USEC = 1000000

##########
# Config #
##########
const debug = false 

const DRAG_STARTUP_TIME = 0.02

const FINGER_SIZE = 100

const TAP_TIME_LIMIT     = 0.2
const TAP_DISTANCE_LIMIT = 25

const SWIPE_TIME_LIMIT         = 0.5
const SWIPE_DISTANCE_LIMIT     = 30
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
var rawGesture : RawGesture = RawGesture.new()

var tap_delay_timer = Timer.new()
var swipe_delay_timer = Timer.new()
var drag_startup_timer = Timer.new()

var single_touch_cancelled = false
var single_drag_enabled = false 


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
		var elapsed_time = SWIPE_TIME_LIMIT
		var now = float(OS.get_ticks_usec())/SEC_IN_USEC

		var rg = RawGesture.new()
		rg.updateScreenTouch(_native_touch_event(0,position,true), now - elapsed_time)
		rg.updateScreenTouch(_native_touch_event(0,position+relative,false), now)

		emit("single_swipe", InputEventSingleScreenSwipe.new(rg))

	# Mouse to gesture.
	elif event is InputEventMouseButton:
		if event.pressed:
			last_mouse_press = event
			if event.button_index == BUTTON_WHEEL_DOWN or event.button_index == BUTTON_WHEEL_UP:
				var position = event.position
				var distance = Vector2(0,200)
				var relative = Vector2(0,40)
				if event.button_index == BUTTON_WHEEL_DOWN:
					relative = -relative
				var elapsed_time = SWIPE_TIME_LIMIT
				var now = float(OS.get_ticks_usec())/SEC_IN_USEC

				var rg = RawGesture.new()
				rg.updateScreenTouch(_native_touch_event(0,position+distance,true), now - elapsed_time)
				rg.updateScreenTouch(_native_touch_event(1,position-distance,true), now - elapsed_time)
				rg.updateScreenDrag(_native_drag_event(0,position+distance,relative,relative/elapsed_time), now)
				rg.updateScreenDrag(_native_drag_event(1,position-distance,-relative,-relative/elapsed_time), now)

				emit("pinch", InputEventScreenPinch.new(rg))
		else:
			last_mouse_press = null
		
	elif event is InputEventMouseMotion:
		if last_mouse_press:
			if last_mouse_press.button_index == BUTTON_MIDDLE:
				var position = event.position
				var distance = Vector2(0,100)
				var relative = event.relative
				var speed    = event.speed
				var elapsed_time = relative.length()/speed.length()
				var now = float(OS.get_ticks_usec())/SEC_IN_USEC

				var rg = RawGesture.new()
				rg.updateScreenTouch(_native_touch_event(0,position+distance,true), now - elapsed_time)
				rg.updateScreenTouch(_native_touch_event(1,position-distance,true), now - elapsed_time)
				rg.updateScreenDrag(_native_drag_event(0,position+distance,relative,speed), now)
				rg.updateScreenDrag(_native_drag_event(1,position-distance,relative,speed), now)

				emit("multi_drag", InputEventMultiScreenDrag.new(rg))

			elif last_mouse_press.button_index == BUTTON_RIGHT:
				var rel1 = event.position - last_mouse_press.position
				var rel2 = rel1 + event.relative
				var angle = rel1.angle_to(rel2)

				var position = last_mouse_press.position
				var distance = Vector2(0,200)
				var speed    = event.speed
				var elapsed_time = event.relative.length()/speed.length()
				var now = float(OS.get_ticks_usec())/SEC_IN_USEC

				var rg = RawGesture.new()
				rg.updateScreenTouch(_native_touch_event(0,position+distance,true), now - elapsed_time)
				rg.updateScreenTouch(_native_touch_event(1,position-distance,true), now - elapsed_time)
				rg.updateScreenDrag(_native_drag_event(0,position+distance,distance.rotated(angle) - distance ,speed), now)
				rg.updateScreenDrag(_native_drag_event(1,position-distance,distance.rotated(-angle) - distance ,speed), now)

				emit("twist", InputEventScreenTwist.new(rg))

	
	# Native touch.
	elif event is InputEventScreenTouch:
		rawGesture.updateScreenTouch(event)
		var index = event.index
		if event.pressed:
			if rawGesture.size() == 1: # First and only touch.
				single_touch_cancelled = false
				emit("single_touch", InputEventSingleScreenTouch.new(rawGesture))
			elif !single_touch_cancelled :
					single_touch_cancelled = true
					cancel_single_drag()
					emit("single_touch", InputEventSingleScreenTouch.new(rawGesture))
		else:
			var fingers = rawGesture.size() 
			if index == 0:
				emit("single_touch", InputEventSingleScreenTouch.new(rawGesture))
				if !single_touch_cancelled:
					var distance = (rawGesture.releases[0].position - rawGesture.presses[0].position).length()
					if rawGesture.elapsed_time < TAP_TIME_LIMIT and distance <= TAP_DISTANCE_LIMIT:
						emit("single_tap", InputEventSingleScreenTap.new(rawGesture))
					if rawGesture.elapsed_time < SWIPE_TIME_LIMIT and distance > SWIPE_DISTANCE_THRESHOLD:
						emit("single_swipe", InputEventSingleScreenSwipe.new(rawGesture))
			if rawGesture.active_touches == 0: # last finger released.
				if single_touch_cancelled:
					var distance = (rawGesture.centroid("releases","position") - rawGesture.centroid("presses","position")).length()
					if rawGesture.elapsed_time < TAP_TIME_LIMIT and distance <= TAP_DISTANCE_LIMIT and\
						 rawGesture.isConsistent(TAP_DISTANCE_LIMIT, FINGER_SIZE*fingers):
						emit("multi_tap", InputEventMultiScreenTap.new(rawGesture))
					if rawGesture.elapsed_time < SWIPE_TIME_LIMIT and distance > SWIPE_DISTANCE_THRESHOLD and\
						 rawGesture.isConsistent(FINGER_SIZE, FINGER_SIZE*fingers):
						emit("multi_swipe", InputEventMultiScreenSwipe.new(rawGesture))
				_end_gesture()
			cancel_single_drag()
	# Native drag.
	elif event is InputEventScreenDrag:
		rawGesture.updateScreenDrag(event)
		if rawGesture.drags.size() > 1:
			cancel_single_drag()
			var gesture = identify_gesture(rawGesture)
			if gesture == Gestures.PINCH:
				emit("pinch", InputEventScreenPinch.new(rawGesture))
			elif gesture == Gestures.MULTI_DRAG:
				emit("multi_drag", InputEventMultiScreenDrag.new(rawGesture))
			elif gesture == Gestures.TWIST:
				emit("twist",InputEventScreenTwist.new(rawGesture))
		else:
			if single_drag_enabled:
				emit("single_drag", InputEventSingleScreenDrag.new(rawGesture))
			else:
				if drag_startup_timer.is_stopped(): drag_startup_timer.start(DRAG_STARTUP_TIME)


# Emits signal sig with the specified args.
func emit(sig : String, val : InputEvent):
	if debug: print(val.as_text())
	emit_signal("any_gesture", sig, val)
	emit_signal(sig, val)
	Input.parse_input_event(val)


# Disables drag and stops the drag enabling timer.
func cancel_single_drag():
	single_drag_enabled = false
	drag_startup_timer.stop()


# Checks if the gesture is pinch.
func identify_gesture(_rawGesture : RawGesture):
	var center = _rawGesture.centroid("drags","position")
	
	var sector = null
	for e in _rawGesture.drags.values():
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
	single_drag_enabled = rawGesture.drags.size() == 1

#################
# Aux Functions #
#################

# 
func _end_gesture():
	single_drag_enabled = false
	rawGesture.clear()


# create a native touch event
func _native_touch_event(index : int, position : Vector2, pressed : bool):
	var native_touch = InputEventScreenTouch.new()
	native_touch.index = index
	native_touch.position = position
	native_touch.pressed  = pressed
	return native_touch

# create a native touch event
func _native_drag_event(index : int, position : Vector2, relative : Vector2, speed : Vector2):
	var native_drag = InputEventScreenDrag.new()
	native_drag.index = index
	native_drag.position = position
	native_drag.relative  = relative 
	native_drag.speed    = speed
	return native_drag


# Check if the action is pressed
func _action_pressed(event : InputEvent, action : String):
	return InputMap.has_action(action) and event.is_action_pressed(action)

# Macro to add a timer and connect it's timeout to func_name.
func _add_timer(timer : Timer, func_name : String):
	timer.one_shot = true
	if func_name:
		timer.connect("timeout", self, func_name)
	self.add_child(timer)
