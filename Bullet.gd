extends Area2D

var damaged = false
var damage = 0
func set_damage(dmg):
	damage = dmg
func _ready():
	set_damage(10)
	
func enemyHit(area: Area2D):
	if not damaged and get_overlapping_bodies() != []:
		for i in get_overlapping_bodies():
			if i in get_tree().get_nodes_in_group(GlobalData.enemy_group):
				if i != GlobalData.main_player_id:
					i.reduce_hp(damage)
		damaged = true
	if area.has_method("reduce_hp"):
		area.reduce_hp(damage)	 
#	area.get_parent().get_node("AnimationPlayer").play("Death")
func reduce_hp(val):
	return 0
