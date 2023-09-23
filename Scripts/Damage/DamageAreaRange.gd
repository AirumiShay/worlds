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
#	print("Archer search attack")	
#	if not damaged and get_overlapping_bodies() != []:
	if get_overlapping_bodies() != []:
#		print("Archer found attack")	
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(Global_DataParser.darkempire_group):
#				print(i)
#		print("Archer check area attack")
				i.reduce_hp(damage)
				return {"target":true, "what_target":i.position}
			if i in get_tree().get_nodes_in_group(Global_DataParser.neutral_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
				return {"target":true, "what_target":i.position}
#				print("Archer endattack")
#		damaged = true
			if i in get_tree().get_nodes_in_group(Global_DataParser.animal_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
				return {"target":true, "what_target":i.position}
		return 	 {"target":false}	
	return 	 {"target":false}
#func _on_Timer_timeout():
#	print("damage end")
#	get_parent().remove_child(self)
#	queue_free()
