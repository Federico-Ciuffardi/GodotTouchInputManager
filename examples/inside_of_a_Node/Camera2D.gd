extends Camera2D

func _on_InputManager_multi_drag(pos,rel):
	offset -= rel*zoom

func _on_InputManager_pinch(pos,i):
	if zoom.x <= 0.16 and sign(i) < 0:
		pass
	elif zoom.x >= 4 and sign(i) > 0:
		pass
	else:
		offset += pos*(-i*zoom)
		zoom += Vector2(i,i)*zoom
