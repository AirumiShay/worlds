extends Area2D

var damaged = false
var damage = 100
var position_target = Vector2(0,0)
var target_id = {"0": 0,
	"1":1,
	"2":2,
	"3":3
	}
var target_present = false
# Called when the node enters the scene tree for the first time.
func _ready():
	print("damagehigh Begin")
#	$Timer.start(10)


func set_damage(dmg):
	damage = dmg


func search_for_target1():
	return ({"target_id":target_id, "position_target":position_target, "target_present":target_present})	
#func _process(_delta):
func _attack_true(player):
	var n = 0
	print("Damage LightMobs search attack")	
#	if not damaged and get_overlapping_bodies() != []:
	if get_overlapping_bodies() != []:

#		print("Archer found attack")	
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(Global_DataParser.build_remove_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
				print("DamageHigh: build area attack")

				target_id[str(n)] = i
				n += 1
				position_target = i.position
#				player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += ": Vampire build attack"
				print(i)			
			if i in get_tree().get_nodes_in_group(Global_DataParser.empire_group):
#				print("Damage Active")
#		print("Archer check area attack") neutral_group
				i.reduce_hp(damage)
				n += 1
				position_target = i.position				
#				player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Vampire attack Empire: " + str(i.get_name()) + "\n"
#			if i in get_tree().get_nodes_in_group(Global_DataParser.neutral_group):
#				print("Damage Active")
#		print("Archer check area attack") neutral_group
#				i.reduce_hp(damage)
#				player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Vampire attack Neutral: " + str(i.get_name()) + "\n"

			if i in get_tree().get_nodes_in_group(Global_DataParser.darkempire_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
				target_id[str(n)] = i
				n += 1
				position_target = i.position
#				print("DamageHigh: endattack")
#				player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Vampire attack Dark: " + str(i.get_name()) + "\n"
				print(i)
#		damaged = true
			if i in get_tree().get_nodes_in_group(Global_DataParser.players_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
				target_id[str(n)] = i
				n += 1
				position_target = i.position
				print("DamageHigh: Player endattack")
#				player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Vampire attack Dark: " + str(i.get_name()) + "\n"
				print(i)
#		damaged = true
				
	return n			
#func _on_Timer_timeout():
#	print("damagehigh end")
#	get_parent().remove_child(self)
#	queue_free()
