extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Enable IME support
	OS.set_ime_active(true)
	$BlockingDialogBox.append_text("The village: Small Poplar",15,36)	
	yield($BlockingDialogBox, "box_hidden")
	$BlockingDialogBox.append_text("Population of 42 people", 20,36)
	yield($BlockingDialogBox, "box_hidden")
func get_teleport_position():
	return Vector2(15000,-10800)
func get_teleport_dungeon_name():
	return "res://Scenes/Dungeon/Dungeon_Farm.tscn"
