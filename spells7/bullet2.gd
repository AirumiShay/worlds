extends Node2D

var damaged = false
var damage = 0
var dir = 0
var bullet_speed = 10


func _process(delta):
	var move_dir = Vector2(1,0).rotated(dir)
	global_position += (move_dir * bullet_speed)
	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()



func set_damage(dmg):
	damage = dmg
func _ready():
	var attack
	if GlobalData.player_level < 10:
		attack = 2 + GlobalData.player_level
	if GlobalData.player_level < 15:
		attack = 5 + 2*GlobalData.player_level
	if GlobalData.player_level < 20:
		attack = 10 + 3*GlobalData.player_level
	if GlobalData.player_level < 25:
		attack = 20 + 3*GlobalData.player_level
	if GlobalData.player_level >= 30:
		attack = 50 + 4*GlobalData.player_level
	GlobalData.player_attack = attack												
	set_damage(attack)
#func _on_bullet2_area_entered(area):
func _on_Area2D_area_entered(area):		
#func enemyHit(area: Area2D):
#	if not damaged and get_overlapping_bodies() != []:
#		for i in get_overlapping_bodies():
#			if i in get_tree().get_nodes_in_group(GlobalData.enemy_group):
#				i.reduce_hp(damage)
#		damaged = true
	if area.has_method("reduce_hp"):
		if area != GlobalData.main_player_id:
			area.reduce_hp(damage)	 
#	area.get_parent().get_node("AnimationPlayer").play("Death")
func reduce_hp(_val):
	return 0
