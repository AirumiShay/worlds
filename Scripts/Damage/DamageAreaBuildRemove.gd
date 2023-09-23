extends Area2D

var damaged = false
var damage = 100
var new_position = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	print("damage REMOVE  Begin")
	print($Sprite.global_position)	
	self.position = new_position
	$Timer.start(10)

func set_damage(dmg):
	damage = dmg



func _process(_delta):
	self.position = new_position	
	if not damaged and get_overlapping_bodies() != []:
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(Global_DataParser.build_remove_group):
#				print("BuildRemove Damage Active")
				i.reduce_hp(damage)
			if i in get_tree().get_nodes_in_group(Global_DataParser.entity_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
			if i in get_tree().get_nodes_in_group(Global_DataParser.darkempire_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
			if i in get_tree().get_nodes_in_group(Global_DataParser.farm_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea

		damaged = true


func _on_Timer_timeout():
#	print("Dark damage end")
	get_parent().remove_child(self)
	queue_free()
