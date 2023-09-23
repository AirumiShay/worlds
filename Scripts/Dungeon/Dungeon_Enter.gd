extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Enable IME support
	pass
func get_teleport_position():
	return Vector2(15000,-10800)
func get_teleport_dungeon_name():
	return "res://Scenes/Dungeon/Dungeon_Sklep.tscn"
