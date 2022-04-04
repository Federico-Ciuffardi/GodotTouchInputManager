# warning-ignore-all:unused_signal

extends Node

##########
# Config #
##########

const debug : bool = false 

const DRAG_STARTUP_TIME : float = 0.02

const FINGER_SIZE : float = 100.0

const TAP_TIME_LIMIT     : float = 0.2
const TAP_DISTANCE_LIMIT : float = 25.0

const SWIPE_TIME_LIMIT         : float = 0.5
const SWIPE_DISTANCE_LIMIT     : float = 30.0
const SWIPE_DISTANCE_THRESHOLD : float = 200.0

#########
# CONST #
#########

const Util : Object = preload("Util.gd")

###########
# Signals #
###########

signal single_tap
signal single_touch
signal single_drag
signal single_swipe
signal multi_drag
signal multi_tap
signal multi_swipe
signal pinch
signal twist
signal raw_gesture
signal any_gesture

########
# Enum #
########

enum Gesture {PINCH, MULTI_DRAG, TWIST}

########
# Vars #
########

var last_event_time : float = -1.0

var rawGesture : RawGesture = RawGesture.new() # Current rawGesture

var _last_mouse_press : InputEventMouseButton = null  # Last mouse button pressed

var _drag_startup_timer : Timer = Timer.new()

var _single_touch_cancelled : bool = false
var _single_drag_enabled    : bool = false 

#############
# Functions #
#############

func _ready() -> void:
	_add_timer(_drag_startup_timer, "_on_drag_startup_timeout")

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenDrag:
		_handle_screen_drag(event)
		last_event_time = Util._now()
	elif event is InputEventScreenTouch:
		_handle_screen_touch(event)
		last_event_time = Util._now()
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
		last_event_time = Util._now()
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)
		last_event_time = Util._now()
	else:
		_handle_action(event)

func _handle_mouse_button(event : InputEventMouseButton) -> void:
	if event.pressed:
		_last_mouse_press = event
		if event.button_index == BUTTON_WHEEL_DOWN or event.button_index == BUTTON_WHEEL_UP:
			var position : Vector2 = event.position
			var distance : Vector2 = Vector2(0,200)
			var relative : Vector2 = Vector2(0,40)
			if event.button_index == BUTTON_WHEEL_DOWN:
				relative = -relative
			var elapsed_time : float = SWIPE_TIME_LIMIT

			var rg : RawGesture = RawGesture.new()
			_updateRGScreenTouch(rg, _native_touch_event(0,position+distance,true), last_event_time - elapsed_time)
			_updateRGScreenTouch(rg, _native_touch_event(1,position-distance,true), last_event_time - elapsed_time)
			_updateRGScreenDrag(rg, _native_drag_event(0,position+distance,relative,relative/elapsed_time), last_event_time)
			_updateRGScreenDrag(rg, _native_drag_event(1,position-distance,-relative,-relative/elapsed_time), last_event_time)

			_emit("pinch", InputEventScreenPinch.new(rg))
	else:
		_last_mouse_press = null
		
func _handle_mouse_motion(event : InputEventMouseMotion) -> void:
	if _last_mouse_press:
		if _last_mouse_press.button_index == BUTTON_MIDDLE:
			var position : Vector2 = event.position
			var distance : Vector2 = Vector2(0,100)
			var relative : Vector2 = event.relative
			var speed    : Vector2 = event.speed
			var elapsed_time : float = relative.length()/speed.length()

			var rg : RawGesture = RawGesture.new()
			_updateRGScreenTouch(rg, _native_touch_event(0,position+distance,true), last_event_time - elapsed_time)
			_updateRGScreenTouch(rg, _native_touch_event(1,position-distance,true), last_event_time - elapsed_time)
			_updateRGScreenDrag(rg, _native_drag_event(0,position+distance,relative,speed), last_event_time)
			_updateRGScreenDrag(rg, _native_drag_event(1,position-distance,relative,speed), last_event_time)

			_emit("multi_drag", InputEventMultiScreenDrag.new(rg))

		elif _last_mouse_press.button_index == BUTTON_RIGHT:
			var rel1 : Vector2 = event.position - _last_mouse_press.position
			var rel2 : Vector2 = rel1 + event.relative
			var angle : float = rel1.angle_to(rel2)

			var position : Vector2 = _last_mouse_press.position
			var distance : Vector2 = Vector2(0,200)
			var speed    : Vector2 = event.speed
			var elapsed_time : float = event.relative.length()/speed.length()

			var rg : RawGesture = RawGesture.new()
			_updateRGScreenTouch(rg, _native_touch_event(0,position+distance,true), last_event_time - elapsed_time)
			_updateRGScreenTouch(rg, _native_touch_event(1,position-distance,true), last_event_time - elapsed_time)
			_updateRGScreenDrag(rg, _native_drag_event(0,position+distance,distance.rotated(angle) - distance ,speed), last_event_time)
			_updateRGScreenDrag(rg, _native_drag_event(1,position-distance,distance.rotated(-angle) - distance ,speed), last_event_time)

			_emit("twist", InputEventScreenTwist.new(rg))

func _handle_screen_touch(event : InputEventScreenTouch) -> void:
	_updateRGScreenTouch(rawGesture, event)
	var index : int = event.index
	if event.pressed:
		if rawGesture.size() == 1: # First and only touch
			_single_touch_cancelled = false
			_emit("single_touch", InputEventSingleScreenTouch.new(rawGesture))
		elif !_single_touch_cancelled :
				_single_touch_cancelled = true
				_cancel_single_drag()
				_emit("single_touch", InputEventSingleScreenTouch.new(rawGesture))
	else:
		var fingers : int = rawGesture.size() 
		if index == 0:
			_emit("single_touch", InputEventSingleScreenTouch.new(rawGesture))
			if !_single_touch_cancelled:
				var distance : float = (rawGesture.releases[0].position - rawGesture.presses[0].position).length()
				if rawGesture.elapsed_time < TAP_TIME_LIMIT and distance <= TAP_DISTANCE_LIMIT:
					_emit("single_tap", InputEventSingleScreenTap.new(rawGesture))
				if rawGesture.elapsed_time < SWIPE_TIME_LIMIT and distance > SWIPE_DISTANCE_THRESHOLD:
					_emit("single_swipe", InputEventSingleScreenSwipe.new(rawGesture))
		if rawGesture.active_touches == 0: # last finger released
			if _single_touch_cancelled:
				var distance : float = (rawGesture.centroid("releases","position") - rawGesture.centroid("presses","position")).length()
				if rawGesture.elapsed_time < TAP_TIME_LIMIT and distance <= TAP_DISTANCE_LIMIT and\
					 rawGesture.isConsistent(TAP_DISTANCE_LIMIT, FINGER_SIZE*fingers):
					_emit("multi_tap", InputEventMultiScreenTap.new(rawGesture))
				if rawGesture.elapsed_time < SWIPE_TIME_LIMIT and distance > SWIPE_DISTANCE_THRESHOLD and\
					 rawGesture.isConsistent(FINGER_SIZE, FINGER_SIZE*fingers):
					_emit("multi_swipe", InputEventMultiScreenSwipe.new(rawGesture))
			_end_gesture()
		_cancel_single_drag()

func _handle_screen_drag(event : InputEventScreenDrag) -> void:
	_updateRGScreenDrag(rawGesture, event)
	if rawGesture.drags.size() > 1:
		_cancel_single_drag()
		var gesture : int = _identify_gesture(rawGesture)
		if gesture == Gesture.PINCH:
			_emit("pinch", InputEventScreenPinch.new(rawGesture))
		elif gesture == Gesture.MULTI_DRAG:
			_emit("multi_drag", InputEventMultiScreenDrag.new(rawGesture))
		elif gesture == Gesture.TWIST:
			_emit("twist",InputEventScreenTwist.new(rawGesture))
	else:
		if _single_drag_enabled:
			_emit("single_drag", InputEventSingleScreenDrag.new(rawGesture))
		else:
			if _drag_startup_timer.is_stopped(): _drag_startup_timer.start(DRAG_STARTUP_TIME)

func _handle_action(event : InputEvent) -> void:
	var swipe_emulation_dir : Vector2 = Vector2.ZERO
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

	if swipe_emulation_dir != Vector2.ZERO:
		var position : Vector2 = get_viewport().get_mouse_position()
		var relative : Vector2 = swipe_emulation_dir*SWIPE_DISTANCE_THRESHOLD*2
		var elapsed_time : float = SWIPE_TIME_LIMIT

		var rg : RawGesture = RawGesture.new()
		_updateRGScreenTouch(rg, _native_touch_event(0,position,true), last_event_time - elapsed_time)
		_updateRGScreenTouch(rg, _native_touch_event(0,position+relative,false), last_event_time)

		_emit("single_swipe", InputEventSingleScreenSwipe.new(rg))

# Emits signal sig with the specified args
func _emit(sig : String, val : InputEvent) -> void:
	if debug: print(val.as_text())
	emit_signal("any_gesture", sig, val)
	emit_signal(sig, val)
	Input.parse_input_event(val)


# Disables drag and stops the drag enabling timer
func _cancel_single_drag() -> void:
	_single_drag_enabled = false
	_drag_startup_timer.stop()


# Checks if the gesture is pinch
func _identify_gesture(_rawGesture : RawGesture) -> int:
	var center : Vector2 = _rawGesture.centroid("drags","position")
	
	var sector : int = -1
	for e in _rawGesture.drags.values():
		var adjusted_position : Vector2 = center - e.position
		var raw_angle      : float = fmod(adjusted_position.angle_to(e.relative) + (PI/4), TAU) 
		var adjusted_angle : float = raw_angle if raw_angle >= 0 else raw_angle + TAU
		var e_sector       : int = int(floor(adjusted_angle / (PI/2)))
		if sector == -1: 
			sector = e_sector
		elif sector != e_sector:
			return Gesture.MULTI_DRAG

	if sector == 0 or sector == 2:
		return Gesture.PINCH
	else: # sector == 1 or sector == 3:
		return Gesture.TWIST

func _on_drag_startup_timeout() -> void:
	_single_drag_enabled = rawGesture.drags.size() == 1

func _end_gesture() -> void:
	_single_drag_enabled = false
	rawGesture = RawGesture.new()

# create a native touch event
func _native_touch_event(index : int, position : Vector2, pressed : bool) -> InputEventScreenTouch:
	var native_touch : InputEventScreenTouch = InputEventScreenTouch.new()
	native_touch.index = index
	native_touch.position = position
	native_touch.pressed  = pressed
	return native_touch

# create a native touch event
func _native_drag_event(index : int, position : Vector2, relative : Vector2, speed : Vector2) -> InputEventScreenDrag:
	var native_drag : InputEventScreenDrag = InputEventScreenDrag.new()
	native_drag.index = index
	native_drag.position = position
	native_drag.relative  = relative 
	native_drag.speed    = speed
	return native_drag

func _updateRGScreenTouch(rg : RawGesture, event : InputEventScreenTouch, time : float = -1):
	rg._updateScreenTouch(event,time)
	_emit("raw_gesture", rg)

func _updateRGScreenDrag(rg : RawGesture, event : InputEventScreenDrag, time : float = -1):
	rg._updateScreenDrag(event,time)
	_emit("raw_gesture", rg)

# Check if the action is pressed
func _action_pressed(event : InputEvent, action : String) -> bool:
	return InputMap.has_action(action) and event.is_action_pressed(action)

# Macro to add a timer and connect it's timeout to func_name
func _add_timer(timer : Timer, func_name : String) -> void:
	timer.one_shot = true
	if func_name:
		timer.connect("timeout", self, func_name)
	self.add_child(timer)
