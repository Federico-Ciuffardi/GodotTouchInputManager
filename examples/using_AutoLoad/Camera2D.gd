extends Camera2D

var lastMouseButton = null

func _ready():
	InputManager.connect("multi_drag",self,"on_multi_drag")
	InputManager.connect("pinch",self,"on_pinch")

func on_multi_drag(pos,rel):
	offset -= rel*zoom
	
func on_pinch(pos,i):
	if zoom.x <= 0.16 and sign(i) < 0:
		pass
	elif zoom.x >= 4 and sign(i) > 0:
		pass
	else:
		offset += pos*(-i*zoom)
		zoom += Vector2(i,i)*zoom

