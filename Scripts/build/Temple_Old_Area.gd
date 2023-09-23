extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func GiveEnergy(res_add):
	get_parent().GiveEnergy(res_add)
#	resource +=  res_add	
#	$Resource.text = str(resource)
#	res_add += 1
func TakeEnergy(res_add):
	var a
	a = get_parent().TakeEnergy(res_add) # = resource
#	resource = 0
#	$Resource.text = str(resource)
#	return a
	print("------------------------")
	print("resource area")
	print(a)
	print("------------------------")
	
	return a
