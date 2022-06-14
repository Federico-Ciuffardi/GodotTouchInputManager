class_name InputEventSingleScreenLongPress
extends InputEventAction

var position   : Vector2
var raw_gesture : RawGesture

func _init(_raw_gesture : RawGesture = null) -> void:
	raw_gesture = _raw_gesture
	if raw_gesture:
		if !raw_gesture.presses.has(0):
			print("RAW GESTURE:\n" + raw_gesture.as_text())
			var rollback_res = raw_gesture.rollback_relative(1.0)
			var discarded_events = rollback_res[1]
			var history = "\nHISTORY:\n"
			for e in discarded_events:
				if e is RawGesture.Drag:
					history += "D | "
				else:
					history += "T | "
				history += e.as_text()
				history +="\n"
			print(history)
			var error_msg_short = "Hello! we are trying to fix this bug.\nPlease help us by following the steps at the end of the output.\nThanks!"
			var error_msg="Hello! we are trying to fix this bug.\nTo help us please copy the output and comment it (attached as a file) in the following issue: https://github.com/Federico-Ciuffardi/GodotTouchInputManager/issues/20\nAlso, if you can, include in that comment what version of Godot you are using, what platform you are running on, and what you were doing when the error occurred.\nThanks!"
			print(error_msg)
			
			assert(false,error_msg_short)
		position = raw_gesture.presses[0].position


func as_text() -> String:
	return "position=" + str(position)
