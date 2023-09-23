extends Area2D

var damaged = false
var damage = 50
onready var parent_is
# Called when the node enters the scene tree for the first time.
func _ready():
#	print("damageAREA Begin")
#	print($Sprite.global_position)
	$Timer.start(0.1)

func set_damage(dmg):
	damage = dmg

func set_parent_is(val):
	parent_is = val



func _process(_delta):
	if not damaged and get_overlapping_bodies() != []:
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(Global_DataParser.animal_group):

				i.reduce_hp(damage)
			if i in get_tree().get_nodes_in_group(Global_DataParser.darkempire_group):
				i.reduce_hp(damage) # наносим урон всем , кто в зоне  DamageArea
				$Sprite.visible = true
				if parent_is != null:
					parent_is.add_exp(damage)
#			if i in get_tree().get_nodes_in_group(Global_DataParser.animal_group):
#				print("Damage Active")
		damaged = true


func _on_Timer_timeout():
#	print("damage end")
	get_parent().remove_child(self)
	queue_free()

