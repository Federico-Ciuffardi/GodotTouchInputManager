# warning-ignore-all:return_value_discarded
# warning-ignore-all:unused_signal

extends Node

##########
# Config #
##########

const DEFAULT_BINDIGS : bool = true

const DEBUG : bool = false 

const DRAG_STARTUP_TIME : float = 0.02

const FINGER_SIZE : float = 100.0

const MULTI_FINGER_RELEASE_THRESHOLD : float = 0.1

const TAP_TIME_LIMIT     : float = 0.2
const TAP_DISTANCE_LIMIT : float = 25.0

const LONG_PRESS_TIME_THRESHOLD : float = 0.75
const LONG_PRESS_DISTANCE_LIMIT : float = 25.0

const SWIPE_TIME_LIMIT         : float = 0.5
const SWIPE_DISTANCE_THRESHOLD : float = 200.0

#########
# CONST #
#########

const Util : GDScript = preload("Util.gd")

const	swipe2dir : Dictionary = \
{
	"swipe_up"         : Vector2.UP,
	"swipe_up_right"   : Vector2.UP + Vector2.RIGHT,
	"swipe_right"      : Vector2.RIGHT,
	"swipe_down_right" : Vector2.DOWN + Vector2.RIGHT,
	"swipe_down"       : Vector2.DOWN,
	"swipe_down_left"  : Vector2.DOWN + Vector2.LEFT,
	"swipe_left"       : Vector2.LEFT,
	"swipe_up_left"    : Vector2.UP + Vector2.LEFT
}


###########
# Signals #
###########

signal touch 
signal drag
signal single_tap
signal single_touch
signal single_drag
signal single_swipe
signal single_long_press
signal multi_drag
signal multi_tap
signal multi_swipe
signal multi_long_press
signal pinch
signal twist
signal raw_gesture
signal cancel
signal any_gesture

########
# Enum #
########

enum Gesture {PINCH, MULTI_DRAG, TWIST, SINGLE_DRAG, NONE}

########
# Vars #
########

var raw_gesture_data : RawGesture = RawGesture.new() # Current raw_gesture

var _mouse_event_press_position : Vector2
var _mouse_event : int = Gesture.NONE


var _drag_startup_timer : Timer = Timer.new()
var _long_press_timer   : Timer = Timer.new()

var _single_touch_cancelled : bool = false
var _single_drag_enabled    : bool = false 

#############
# Functions #
#############

func _ready() -> void:
	_add_timer(_drag_startup_timer, "_on_drag_startup_timer_timeout")
	_add_timer(_long_press_timer,   "_on_long_press_timer_timeout")

	if DEFAULT_BINDIGS:
		_set_default_action("multi_swipe_up"        , _native_key_event(KEY_I))
		_set_default_action("multi_swipe_up_right"  , _native_key_event(KEY_O))
		_set_default_action("multi_swipe_right"     , _native_key_event(KEY_L))
		_set_default_action("multi_swipe_down_right", _native_key_event(KEY_PERIOD))
		_set_default_action("multi_swipe_down"      , _native_key_event(KEY_COMMA))
		_set_default_action("multi_swipe_down_left" , _native_key_event(KEY_M))
		_set_default_action("multi_swipe_left"      , _native_key_event(KEY_J))
		_set_default_action("multi_swipe_up_left"   , _native_key_event(KEY_U))

		_set_default_action("single_swipe_up"        , _native_key_event(KEY_W))
		_set_default_action("single_swipe_up_right"  , _native_key_event(KEY_E))
		_set_default_action("single_swipe_right"     , _native_key_event(KEY_D))
		_set_default_action("single_swipe_down_right", _native_key_event(KEY_C))
		_set_default_action("single_swipe_down"      , _native_key_event(KEY_X))
		_set_default_action("single_swipe_down_left" , _native_key_event(KEY_Z))
		_set_default_action("single_swipe_left"      , _native_key_event(KEY_A))
		_set_default_action("single_swipe_up_left"   , _native_key_event(KEY_Q))

		# _set_default_action("single_touch"           , _native_mouse_button_event(MOUSE_BUTTON_LEFT))
		_set_default_action("multi_touch"              , _native_mouse_button_event(MOUSE_BUTTON_MIDDLE))
		# _set_default_action("pinch"                  , _native_mouse_button_event(MOUSE_BUTTON_RIGHT)) # TODO
		_set_default_action("pinch_outward"            , _native_mouse_button_event(MOUSE_BUTTON_WHEEL_UP))
		_set_default_action("pinch_inward"             , _native_mouse_button_event(MOUSE_BUTTON_WHEEL_DOWN))
		_set_default_action("twist"                    , _native_mouse_button_event(MOUSE_BUTTON_RIGHT))
		# _set_default_action("twist_clockwise"        , _native_mouse_button_event(MOUSE_BUTTON_WHEEL_UP)) # TODO
		# _set_default_action("twist_counterclockwise" , _native_mouse_button_event(MOUSE_BUTTON_WHEEL_DOWN)) # TODO

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventScreenDrag:
		_handle_screen_drag(event)
	elif event is InputEventScreenTouch:
		_handle_screen_touch(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	else:
		_handle_action(event)
		
func _handle_mouse_motion(event : InputEventMouseMotion) -> void:
	if raw_gesture_data.size() == 1 and _mouse_event == Gesture.SINGLE_DRAG:
		_emit("drag", _native_drag_event(0, event.position, event.relative, event.velocity))
	elif raw_gesture_data.size() == 2 and _mouse_event == Gesture.MULTI_DRAG:
		var offset = Vector2(5,5)
		var e0 = _native_drag_event(0, event.position-offset, event.relative, event.velocity)
		raw_gesture_data._update_screen_drag(e0)
		var e1 = _native_drag_event(1, event.position+offset, event.relative, event.velocity)
		raw_gesture_data._update_screen_drag(e1)
		_emit("multi_drag", InputEventMultiScreenDrag.new(raw_gesture_data,e0))
		_emit("multi_drag", InputEventMultiScreenDrag.new(raw_gesture_data,e1))
	elif _mouse_event == Gesture.TWIST:
		var rel1 = event.position - _mouse_event_press_position
		var rel2 = rel1 + event.relative
		var twist_event = InputEventScreenTwist.new()
		twist_event.position = _mouse_event_press_position
		twist_event.relative = rel1.angle_to(rel2)
		twist_event.fingers  = 2
		_emit("twist", twist_event)

func _handle_screen_touch(event : InputEventScreenTouch) -> void:
	if event.index < 0:
		_emit("cancel", InputEventScreenCancel.new(raw_gesture_data, event))
		_end_gesture()
		return

	# ignore orphaned touch release events
	if !event.pressed and not event.index in raw_gesture_data.presses:
		return

	raw_gesture_data._update_screen_touch(event)
	_emit("raw_gesture", raw_gesture_data)
	var index : int = event.index
	if event.pressed:
		if raw_gesture_data.size() == 1: # First and only touch
			_long_press_timer.start(LONG_PRESS_TIME_THRESHOLD)
			_single_touch_cancelled = false
			_emit("single_touch", InputEventSingleScreenTouch.new(raw_gesture_data))
		elif !_single_touch_cancelled :
				_single_touch_cancelled = true
				_cancel_single_drag()
				_emit("single_touch", InputEventSingleScreenTouch.new(raw_gesture_data))
	else:
		var fingers : int = raw_gesture_data.size() 
		if index == 0:
			_emit("single_touch", InputEventSingleScreenTouch.new(raw_gesture_data))
			if !_single_touch_cancelled:
				var distance : float = (raw_gesture_data.releases[0].position - raw_gesture_data.presses[0].position).length()
				if raw_gesture_data.elapsed_time < TAP_TIME_LIMIT and distance <= TAP_DISTANCE_LIMIT:
					_emit("single_tap", InputEventSingleScreenTap.new(raw_gesture_data))
				if raw_gesture_data.elapsed_time < SWIPE_TIME_LIMIT and distance > SWIPE_DISTANCE_THRESHOLD:
					_emit("single_swipe", InputEventSingleScreenSwipe.new(raw_gesture_data))
		if raw_gesture_data.active_touches == 0: # last finger released
			if _single_touch_cancelled:
				var distance : float = (raw_gesture_data.centroid("releases","position") - raw_gesture_data.centroid("presses","position")).length()
				if raw_gesture_data.elapsed_time < TAP_TIME_LIMIT and distance <= TAP_DISTANCE_LIMIT and\
					raw_gesture_data.is_consistent(TAP_DISTANCE_LIMIT, FINGER_SIZE*fingers) and\
					_released_together(raw_gesture_data, MULTI_FINGER_RELEASE_THRESHOLD):
					_emit("multi_tap", InputEventMultiScreenTap.new(raw_gesture_data))
				if raw_gesture_data.elapsed_time < SWIPE_TIME_LIMIT and distance > SWIPE_DISTANCE_THRESHOLD and\
					raw_gesture_data.is_consistent(FINGER_SIZE, FINGER_SIZE*fingers) and\
					_released_together(raw_gesture_data, MULTI_FINGER_RELEASE_THRESHOLD):
					_emit("multi_swipe", InputEventMultiScreenSwipe.new(raw_gesture_data))
			_end_gesture()
		_cancel_single_drag()

func _handle_screen_drag(event : InputEventScreenDrag) -> void:
	if event.index < 0:
		_emit("cancel", InputEventScreenCancel.new(raw_gesture_data, event))
		_end_gesture()
		return

	raw_gesture_data._update_screen_drag(event)
	_emit("raw_gesture", raw_gesture_data)
	if raw_gesture_data.drags.size() > 1:
		_cancel_single_drag()
		var gesture : int = _identify_gesture(raw_gesture_data)
		if gesture == Gesture.PINCH:
			_emit("pinch", InputEventScreenPinch.new(raw_gesture_data, event))
		elif gesture == Gesture.MULTI_DRAG:
			_emit("multi_drag", InputEventMultiScreenDrag.new(raw_gesture_data, event))
		elif gesture == Gesture.TWIST:
			_emit("twist",InputEventScreenTwist.new(raw_gesture_data, event))
	else:
		if _single_drag_enabled:
			_emit("single_drag", InputEventSingleScreenDrag.new(raw_gesture_data))
		else:
			if _drag_startup_timer.is_stopped(): _drag_startup_timer.start(DRAG_STARTUP_TIME)

func _handle_action(event : InputEvent) -> void:
	if InputMap.has_action("single_touch") and (event.is_action_pressed("single_touch") or event.is_action_released("single_touch")):
		_emit("touch", _native_touch_event(0, get_viewport().get_mouse_position(), event.pressed))
		if event.pressed:
			_mouse_event = Gesture.SINGLE_DRAG
		else:
			_mouse_event = Gesture.NONE
	elif InputMap.has_action("multi_touch") and (event.is_action_pressed("multi_touch") or event.is_action_released("multi_touch")):
		_emit("touch", _native_touch_event(0, get_viewport().get_mouse_position(), event.pressed))
		_emit("touch", _native_touch_event(1, get_viewport().get_mouse_position(), event.pressed))
		if event.pressed:
			_mouse_event = Gesture.MULTI_DRAG
		else:
			_mouse_event = Gesture.NONE
	elif InputMap.has_action("twist") and (event.is_action_pressed("twist") or event.is_action_released("twist")):
		_mouse_event_press_position = get_viewport().get_mouse_position()
		if event.pressed:
			_mouse_event = Gesture.TWIST
		else:
			_mouse_event = Gesture.NONE
	elif (InputMap.has_action("pinch_outward") and event.is_action_pressed("pinch_outward")) or (InputMap.has_action("pinch_inward") and event.is_action_pressed("pinch_inward")):
		var pinch_event = InputEventScreenPinch.new()
		pinch_event.fingers = 2 
		pinch_event.position = get_viewport().get_mouse_position()
		pinch_event.distance = 400
		pinch_event.relative = 40
		if event.is_action_pressed("pinch_inward"):
			pinch_event.relative *= -1
		_emit("pinch", pinch_event)
	else:
		var swipe_emulation_dir  : Vector2 = Vector2.ZERO
		var is_single_swipe : bool 
		for swipe in swipe2dir:
			var dir = swipe2dir[swipe]
			if InputMap.has_action("single_"+swipe) and event.is_action_pressed("single_"+swipe):
				swipe_emulation_dir  = dir
				is_single_swipe = true
				break
			if InputMap.has_action("multi_"+swipe) and event.is_action_pressed("multi_"+swipe):
				swipe_emulation_dir  = dir
				is_single_swipe = false
				break

		if swipe_emulation_dir != Vector2.ZERO:
			var swipe_event
			if is_single_swipe:
				swipe_event = InputEventSingleScreenSwipe.new()
			else:
				swipe_event = InputEventMultiScreenSwipe.new()
				swipe_event.fingers = 2
			swipe_event.position = get_viewport().get_mouse_position()
			swipe_event.relative = swipe_emulation_dir*SWIPE_DISTANCE_THRESHOLD*2
			if is_single_swipe:
				_emit("single_swipe", swipe_event)
			else:
				_emit("multi_swipe", swipe_event)

# Emits signal sig with the specified args
func _emit(sig : String, val : InputEvent) -> void:
	if DEBUG: print(val.as_text())
	emit_signal("any_gesture", sig, val)
	emit_signal(sig, val)
	Input.parse_input_event(val)


# Disables drag and stops the drag enabling timer
func _cancel_single_drag() -> void:
	_single_drag_enabled = false
	_drag_startup_timer.stop()

func _released_together(_raw_gesture_data : RawGesture, threshold : float) -> bool:
	_raw_gesture_data = _raw_gesture_data.rollback_relative(threshold)[0]
	return _raw_gesture_data.size() == _raw_gesture_data.active_touches

# Checks if the gesture is pinch
func _identify_gesture(_raw_gesture_data : RawGesture) -> int:
	var center : Vector2 = _raw_gesture_data.centroid("drags","position")
	
	var sector : int = -1
	for e in _raw_gesture_data.drags.values():
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

func _on_drag_startup_timer_timeout() -> void:
	_single_drag_enabled = raw_gesture_data.drags.size() == 1

func _on_long_press_timer_timeout() -> void:
	var ends_centroid   : Vector2    = Util.centroid(raw_gesture_data.get_ends().values())
	var starts_centroid : Vector2    = raw_gesture_data.centroid("presses", "position")
	var distance        : float      = (ends_centroid - starts_centroid).length()

	if raw_gesture_data.releases.is_empty() and distance <= LONG_PRESS_DISTANCE_LIMIT and\
		raw_gesture_data.is_consistent(LONG_PRESS_DISTANCE_LIMIT, FINGER_SIZE*raw_gesture_data.size()):
		if _single_touch_cancelled:
			_emit("multi_long_press", InputEventMultiScreenLongPress.new(raw_gesture_data))
		else:
			_emit("single_long_press", InputEventSingleScreenLongPress.new(raw_gesture_data))
	

func _end_gesture() -> void:
	_single_drag_enabled = false
	_long_press_timer.stop()
	raw_gesture_data = RawGesture.new()

# create a native touch event
func _native_touch_event(index : int, position : Vector2, pressed : bool) -> InputEventScreenTouch:
	var native_touch : InputEventScreenTouch = InputEventScreenTouch.new()
	native_touch.index = index
	native_touch.position = position
	native_touch.pressed  = pressed
	return native_touch

# create a native touch event
func _native_drag_event(index : int, position : Vector2, relative : Vector2, velocity : Vector2) -> InputEventScreenDrag:
	var native_drag : InputEventScreenDrag = InputEventScreenDrag.new()
	native_drag.index = index
	native_drag.position = position
	native_drag.relative  = relative 
	native_drag.velocity    = velocity
	return native_drag

func _native_mouse_button_event(button : int) -> InputEventMouseButton:
	var ev = InputEventMouseButton.new()
	ev.button_index = button
	return ev

func _native_key_event(key : int) -> InputEventKey:
	var ev = InputEventKey.new()
	ev.keycode = key
	return ev

func _set_default_action(action : String, event : InputEvent) -> void:
	if !InputMap.has_action(action):
		InputMap.add_action(action)
		InputMap.action_add_event(action,event)

# Macro to add a timer and connect it's timeout to func_name
func _add_timer(timer : Timer, func_name : String) -> void:
	timer.one_shot = true
	if func_name:
		timer.connect("timeout", Callable(self, func_name))
	self.add_child(timer)
