extends Area2D

var damaged = false
var damage = 1
var healing = 350

# Called when the node enters the scene tree for the first time.
func _ready():
#	print("damage Begin")
	$Timer.start(2)

func set_damage(dmg):
	damage = dmg

func set_heal(dmg):
	healing = dmg


func _process(_delta):
	if not damaged and get_overlapping_bodies() != []:
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(Global_DataParser.build_repare_group):
				print("Build Repare Active")
				i.increase_hp(healing)
			if i in get_tree().get_nodes_in_group(Global_DataParser.builds_group):
				print("Build Restore Active")
				i.increase_hp(healing)
			if i in get_tree().get_nodes_in_group(Global_DataParser.builds_group):
				print("Build Restore Active")
				i.increase_hp(healing)
				
#			if i in get_tree().get_nodes_in_group(Global_DataParser.darkempire_group):
#				print("Dark Damage Active for dark empire entity")				
#				i.reduce_hp(50) # наносим урон всем , кто в зоне  DamageArea
#			if i in get_tree().get_nodes_in_group(Global_DataParser.players_group):
#				i.increase_hp(healing) # наносим урон всем , кто в зоне  DamageArea

		damaged = true


func _on_Timer_timeout():
#	print("Dark damage end")
	get_parent().remove_child(self)
	queue_free()
