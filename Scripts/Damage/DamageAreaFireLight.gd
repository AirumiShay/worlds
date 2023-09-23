extends Area2D

var damaged = false
var damage = 150

# Called when the node enters the scene tree for the first time.
func _ready():
#	print("damage Begin")
	$Timer.start(7.0)

func set_damage(dmg):
	damage = dmg



func _process(_delta):
	if not damaged and get_overlapping_bodies() != []:
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(Global_DataParser.players_group):
				print("Players Damage  Active")
				i.reduce_hp(damage)
#			if i in get_tree().get_nodes_in_group(Global_DataParser.darkempire_group):
#				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
#				print("DarkEmpire Damage Active")				
			if i in get_tree().get_nodes_in_group(Global_DataParser.empire_group):
				print("Empire Damage Active")
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
#			if i in get_tree().get_nodes_in_group(Global_DataParser.animal_group):
#				print("Player Damage Active")
#				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea

		damaged = true


func _on_Timer_timeout():
#	print("Dark damage end")
	get_parent().remove_child(self)
	queue_free()


func _on_TimerAttack_timeout():
	pass # Replace with function body.
