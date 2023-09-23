extends Area2D

var damaged = false
var damage = 1

# Called when the node enters the scene tree for the first time.
func _ready():
#	print("damage Begin")
#	$Timer.start(0.1)
	pass

func set_damage(dmg):
	damage = dmg



#func _process(_delta):
func _attack_true():

#	if not damaged and get_overlapping_bodies() != []:
	if get_overlapping_bodies() != []:
#		for i in get_overlapping_bodies():
#			print("begin")
#			print(i)
#			print("end")
		return true
	else:
		false	
#		for i in get_overlapping_bodies():
#			if i in get_tree().get_nodes_in_group(Global_DataParser.empire_group):
#				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
#			if i in get_tree().get_nodes_in_group(Global_DataParser.animal_group):
#				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
#	
#				print("Archer endattack")
#	
#	damaged = true


#func _on_Timer_timeout():
#	print("damage end")
#	get_parent().remove_child(self)
#	queue_free()
