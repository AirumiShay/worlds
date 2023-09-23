extends Camera2D


onready var zoomfactor = 1 #
onready var zoomspeed = 15 #
onready var zoomstep = 0.03 #
onready var factorstep = 0.01 #

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass 
	
func _process(delta):
	
	zoom.x = lerp (zoom.x, zoomfactor * zoom.x, zoomspeed * delta)
	zoom.y = lerp (zoom.y, zoomfactor * zoom.y, zoomspeed * delta)
	
	zoom.x = clamp(zoom.x, 0.25, 3)
	zoom.y = clamp(zoom.y, 0.25, 3)

	if zoomfactor > 1:
		zoomfactor -= factorstep
	elif zoomfactor < 1:
		zoomfactor += factorstep

func _input(event):
	
	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_WHEEL_UP:
			zoomfactor -= zoomstep
		
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoomfactor += zoomstep
					
