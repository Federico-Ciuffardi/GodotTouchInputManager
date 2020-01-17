extends Camera2D

onready var deb = get_node("/root/World/Control/InfoDisp")

# Public

func to_global(position):
	if anchor_mode == ANCHOR_MODE_FIXED_TOP_LEFT:
		return offset + position*zoom
	elif anchor_mode ==  ANCHOR_MODE_DRAG_CENTER:
		return offset + (position + (get_viewport().get_visible_rect().size/2))*zoom

# Private

func _on_InputManager_multi_drag(event):
	offset -= event.relative*zoom
	
func _on_InputManager_pinch(event):
	var relative_scaled = event.relative/400.0
	if zoom.x <= 0.16 and sign(relative_scaled) < 0:
		pass
	elif zoom.x >= 4 and sign(relative_scaled) > 0:
		pass
	else:
		if anchor_mode == ANCHOR_MODE_FIXED_TOP_LEFT:
			offset += event.position*(-relative_scaled*zoom)
		zoom += Vector2(relative_scaled,relative_scaled)*zoom
		