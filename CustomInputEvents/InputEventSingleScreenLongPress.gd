class_name InputEventSingleScreenLongPress
extends InputEventAction

var position   : Vector2
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		if !raw_gesture.presses.has(0):
			print("RAW GESTURE:\n" + raw_gesture.as_text())
			var linear_event_history = raw_gesture.get_linear_event_history()
			var history = "\nHISTORY:\n"
			for e in linear_event_history:
				if e is RawGesture.Drag:
					history += "D | "
				else:
					history += "T | "
				history += e.as_text()
				history +="\n"
			print(history)
			var error_msg="Hello! we are trying to fix this bug.\nTo help us please copy the output and comment it (attached as a file) in the following issue: https://github.com/Federico-Ciuffardi/GodotTouchInputManager/issues/20\nAlso, if you can, include in that comment what version of Godot you are using, what platform you are running on, and what you were doing when the error occurred.\nThanks!"
			print(error_msg)			
		position = raw_gesture.presses.values()[0].position


func as_string() -> String:
	return "position=" + str(position)
