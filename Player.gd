extends Node2D

var time_enemy = 10
var speed = 5
var attack = 1
var bullet : PackedScene
var enemy_attack : PackedScene
onready var hp = 100
export var max_hp = 100
var SpellTime = 4 # кулдаун заклинания фейерверк, зеркалный двойник и огненная стена(с коэффициентами)
var Spell1_Time = 1 #время между файерболлами
var SpawnEnemy_Time = 3
var player_vol = Vector2(1,1)
var old_player_pos
var spell = true # можно активировать мощное заклинание  и ставить тотем
var spell2 = true # можно активировать заклинание стена огня
var spell_count = 4
var	dead = false
var heal_hp = 3
func _ready():
#	$Spell_Timer.start(Spell1_Time)
	GlobalData.dead_player = false	
	GlobalData.main_player_id = $Hurtbox #self
	old_player_pos = global_position
#	$Spell_Timer.start(SpellTime)
	update_hp()
#	add_to_group(GlobalData.entity_group)
	bullet = ResourceLoader.load("res://spells7/bullet2.tscn")
	enemy_attack = ResourceLoader.load("res://scenes7/DamageArea.tscn")	
	var Enemy_Time = SpawnEnemy_Time - int(GlobalData.player_level/2.5)
	$FireBall_Timer.start(Enemy_Time)		
func _physics_process(delta): 
#	if Input.is_action_pressed("ui_cancel"):
#		dead = false
#		get_tree().change_scene("res://scenes7/MenuDungeon.tscn")	
	attack = GlobalData.player_level * 2
	if dead == false:
		position += Vector2(int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_A)), int(Input.is_key_pressed(KEY_S)) - int(Input.is_key_pressed(KEY_W))) * speed #$AnimatedSprite.speed_scale
		look_at(get_global_mouse_position())
		handle_movement()
##	else:
#		if Input.is_action_pressed("ui_cancel"):
#			dead = false
#			get_tree().change_scene("res://scenes7/MenuDungeon.tscn")
#			get_tree().reload_current_scene() #$DeathAnimationPlayer.play("Death")	
func _process(delta): 
	if Input.is_action_pressed("ui_cancel"):
		dead = false
		get_tree().change_scene("res://scenes7/MenuDungeon.tscn")	
func shoot(): 
	if dead == false:
		spell = true
#	add_child(load("res://Bullet.tscn").instance())
func spawn_totem():
	var dir = get_global_mouse_position() - global_position
	if dir.length() > 5:
		rotation = dir.angle()	
	var a = load("res://scenes7/Player_Totem.tscn").instance()	
	a.start($Muzzle.global_position, rotation)
#	get_parent().add_child(b)		
	var b = $'/root/Main/YSort'.add_child(a)
#			a.global_position = GlobalData.main_player_id.global_position
#	a.position = self.global_position
#	a.start($Muzzle.global_position, rotation)
func spawn_wall():
	var dir = get_global_mouse_position() - global_position
	if dir.length() > 5:
		rotation = dir.angle()	
	var a = load("res://scenes7/Player_Wall.tscn").instance()	
	a.start($Muzzle.global_position, rotation)
#	get_parent().add_child(b)		
	var b = $'/root/Main/YSort'.add_child(a)
#			a.global_position = GlobalData.main_player_id.global_position
#	a.position = self.global_position
	a.start($Muzzle.global_position, rotation)
	
func spawn():
		pass
func spawn_enemy():	
	if spell == true: 
		if GlobalData.count_enemy < 150:
			get_parent().add_child(load("res://Enemy.tscn").instance())
			var lvl = GlobalData.player_level
#		if  lvl == 2 or lvl == 6 or lvl == 9 or lvl == 12 or lvl == 15:
#			spawn_totem()

		if GlobalData.player_level > 4 and time_enemy > 0 and GlobalData.count_enemy < 50:
			time_enemy -= 1
			if time_enemy <=0:
				time_enemy = 10 #- (GlobalData.player_level/10)
				
				if time_enemy <=0:
					time_enemy = 1
					get_parent().add_child(load("res://scenes7/Enemy0.tscn").instance())
	var Enemy_Time = SpawnEnemy_Time - int(GlobalData.player_level/2.5)
	if Enemy_Time <= 0.25: Enemy_Time = 0.25
	$FireBall_Timer.start(Enemy_Time)
func enemyContact(enemyHitbox): 
#	if get_overlapping_bodies() != []:
#		for i in get_overlapping_bodies():
#			if i in get_tree().get_nodes_in_group(GlobalData.enemy_group):
#				i.reduce_hp(damage)
	var scene_id = enemyHitbox # получаем id сцены
#	var scene = get_node(scene_id) # получаем ссылку на сцену
	if dead == false:
		if scene_id.has_method("reduce_hp"):
#		if scene_id.has_method("die"):
#		i.reduce_hp(damage)

			print("player attacked ")
			print(attack)
			print("player attack end ")
#			var enemy_attack = load("res://scenes7/DamageArea.tscn")
#			enemy_attack.instance()
			var bull = enemy_attack.instance()
#			add_child(enemy_attack)
			get_parent().add_child(bull)
			bull.set_damage(attack)

		else:
			print(attack)
			print("attacked-heal")
#		var heal = scene_id.reduce_hp(attack)
#		print("heal:")	
#		if heal >= 0:
#			print("heal:")	
#			print(heal)
		
#			increase_hp(heal)
func decrease_hp(val):
#	return
	self.hp -= val
	update_hp()
	if self.hp <= 0:
		die()
		return false
	return true
func update_hp():
	$HP.text = str(hp)
func increase_hp(val):
	self.hp = min(self.hp + val, self.max_hp)
	update_hp()
	
func die():	
	dead = true
	GlobalData.dead_player = true
#	get_tree().reload_current_scene() #$DeathAnimationPlayer.play("Death")
func Spell_Action():
	var bull = bullet.instance()
	bull.dir = rotation
	bull.rotation = rotation
	bull.global_position = global_position
	get_parent().add_child(bull)
	$Level.text = str(GlobalData.player_level)
	$EnemyCount.text = str(GlobalData.dead_enemy)

	$Atack.text = str(GlobalData.player_attack)
func _on_Spell_Timer_timeout():
	if dead == false:	
		Spell_Action()
	
func handle_movement():
	if Input.is_action_pressed("Spell"):
		if spell == true:
			add_child(load("res://Bullet.tscn").instance())
			if GlobalData.player_level < 5:
				increase_hp(heal_hp)
			elif GlobalData.player_level < 10:
				max_hp = 150
				increase_hp(heal_hp)
			elif GlobalData.player_level < 15:
				max_hp = 220
				increase_hp(heal_hp*2)
			elif GlobalData.player_level < 20:
				max_hp = 300
				increase_hp(heal_hp*2)
			elif GlobalData.player_level < 25:
				max_hp = 450
				increase_hp(heal_hp*3)
			elif GlobalData.player_level < 30:
				max_hp = 675
				increase_hp(heal_hp*4)
			elif GlobalData.player_level < 35:
				max_hp = 950
				increase_hp(heal_hp*4)
			elif GlobalData.player_level < 40:
				max_hp = 1450
				increase_hp(heal_hp*5)
			elif GlobalData.player_level < 45:
				max_hp = 2500
				increase_hp(heal_hp*5)
			elif GlobalData.player_level < 50:
				max_hp = 3750
				increase_hp(heal_hp*6)
			else:
				max_hp = 5000
				increase_hp(heal_hp*6)																													
			spell_count -= 1
			if spell_count < 0:
				if GlobalData.player_level < 5:
					spell_count = 2
				elif GlobalData.player_level < 10:
					spell_count = 3
				elif GlobalData.player_level < 15:
					spell_count = 4
				elif GlobalData.player_level < 20:
					spell_count = 5
				elif GlobalData.player_level < 25:
					spell_count = 6
				elif GlobalData.player_level < 30:
					spell_count = 7
				elif GlobalData.player_level < 35:
					spell_count = 8
				else:
					spell_count = 9															
				spell = false
				$Spell_Timer2.start(SpellTime)
	if Input.is_action_pressed("Spell1"):
		if spell2 == true:
			spell2 = false
			spawn_wall()
			$Spell_Timer2.start(SpellTime*5)						
	if Input.is_action_pressed("Spell2"):
		if spell == true:
			spell = false
			spawn_totem()			

#			var a = $'/root/Main/YSort'.add_child(load("res://scenes7/Player_Totem.tscn").instance())
#			a.global_position = GlobalData.main_player_id.global_position
#			a.position = self.global_position

			decrease_hp(10*GlobalData.player_level)
#			spell_count1 -= 1
#			if spell_count1 < 0 :
#				spell_count1 = 5

			$Spell_Timer2.start(SpellTime)


func _on_Spell_Timer2_timeout():
	spell2 = true


func _on_FireBall_Timer_timeout():
	spawn_enemy()
