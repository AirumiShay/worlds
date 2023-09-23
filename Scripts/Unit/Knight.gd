extends "res://Scripts/Unit/npc_player_control.gd"
#Это юнит гном-рыцарь
var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 60
var	attack_end = true
var count_attack = 200
var player_control = false # моб сейчас управляется игроком?
var npc_god = false
var dead_time = 30 # время существования трупа
var level1 = 0

func _ready():
	dead = false
	speed = default_speed
	self.hp = 300
	self.max_hp = 300
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.empire_group)	
	$StandingTimer.start(5)
	$TimerDamage.start(5) # переходим в режим атаки через 5 сек
	level = level1 
	if level1 > 0:
		$LevelLabel.visible = true		
func toggle_player_control():	# переключаем управление на игрока и обратно на скрипт
#	if Global_DataParser.player_control == false:
		Global_DataParser.player_control = true
		player_control = true
		$Camera.current = true	
		speed = default_speed * 5		
		$LevelLabel.visible = true	
		count_attack = 10000
		npc_god = true # теперь после смерти этот юнит будет возрождаться
		
func _process(delta):
	if level_up == true:
		$LevelLabel.text = str(level)
		level_up = false
		$LevelLabel.visible = true	
	npc_player_control()
	
func npc_player_control():
	if dead == false:
		if player_control == false:

	#	player_control = false				
			$Camera.current = false	
			speed = default_speed 			
			if velocity:
				prev_pos = position
				move_and_slide(velocity)
			wander()
			search_for_target()
			$DamagePos.position = position
		#	print("Цель рядом - атакуем")
		#	if 	attack_end == true:
		#		attack_on()
		else:
			$Camera.current = true	
			var velocity = Vector2()
			if Input.is_action_pressed("ui_up"):
				velocity.y -= speed
			if Input.is_action_pressed("ui_down"):
				velocity.y += speed
			if Input.is_action_pressed("ui_left"):
				velocity.x -= speed
			if Input.is_action_pressed("ui_right"):
				velocity.x += speed
			if Input.is_action_pressed("spell_2"):
				attack_play()
				pass
			move_and_slide(velocity)

func _unhandled_input(event):
	if event.is_action_pressed("enter_enter"):
#		print("I pressed Alt")
#		toggle_hp_bar()
		Global_DataParser.player_control = false
		player_control = false		
#	if event.is_action_pressed("Alt"):
#		print("I pressed Alt")
#		toggle_hp_bar()
#	if Input.is_action_pressed("ui_cancel"):
#		if $MidleMenu1.visible == true:
#			$MidleMenu1.visible = false
#		else:
#			$MidleMenu1.visible = true
#			player_stats_save()
#
			
func attack_play():
		var a = load("res://Scenes/Damage/DamageArea.tscn").instance()
		var dmg = 25
		a.set_damage(dmg)
		a.set_parent_is(self)
		get_parent().add_child(a)
		a.position = $Sprite.global_position # $DamagePos.position #разброс попадания в цель
				
func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false

func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
	$StandingTimer.start(3)
	speed = default_speed
#	if attack_end == true:
#		$Timer.start(2) # переходим в режим атаки на 1сек
#		attack_end = false
#		attack_on()	
	$TimerDamage.start(5) 
func wander():
	var pos = position
	if stands:
		randomize()
		x = int(rand_range(pos.x - 150, pos.x + 150))
		y = int(rand_range(pos.y - 150, pos.y + 150))
		
#		x = clamp(x, -25500, -22000)
#		y = clamp(y, -1500, 1000)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()

		else:

			if pos.distance_to(destination) <= 5:
				cancel_movement()
func search_for_target():
	if dead == false:
		return false
	var pl = get_parent().get_parent().get_player()
	if pl:
		if position.distance_to(pl.position) < 200:
	#		print("You character has visible for Monster!!!")

			cancel_movement()
			speed = default_speed * 1.35 if speed == default_speed else speed
			target = pl
#			if attack_end == false:
#				$Timer.start(5) # переходим в режим атаки на 1сек
#				attack_end = true
		else:
			if target:
				cancel_movement()
			target = null
		if target:
			set_destination(target.position)
func increase_xp(val):
	expirience += 	val	
			
func reduce_hp(val):
	if self.hp > 0:
		self.hp -= val
#		print("Healt -= %s" % val)
#		print(hp)
	if self.hp > 0:
		update_hp()
	if self.hp <= 0:
		die1()
		return false
	return true
	
	
func die1():
	if player_control == false and npc_god == false:	
		dead = true	
	#	print("Paladin Dead")
		Global_DataParser.dec_mobs(7,1)
		cancel_movement()
		set_process(false)
		$Sprite.texture = load("res://Assets/units/mob/drow_f.png")
	#	$CollisionShape2D.scale.x = 0.1	
	#	$CollisionShape2D.scale.y = 0.1
	#	die()
		self.hp = 0	
		toggle_hp_bar()
		$TimerDie.start(dead_time) # запускаем таймер для трупа персонажа			
	else:
		position = Vector2(0,0)
		hp = max_hp
		dead = false
func set_resurect():
	if 	dead != false:
		dead = false
		speed = default_speed
		self.hp = 300
		self.max_hp = 300
		set_start_hp(self.hp, self.max_hp)
		$StandingTimer.start(5)
		$TimerDamage.start(5) # переходим в режим атаки через 5 сек
		update_hp()
		count_attack = 200	
		$Sprite.texture = load("res://Assets/units_new/gnome/unit_broad_swordman.png")			
		set_process(true)
func attack_on():
	if 	dead == false:	
		$DamageNPC.set_damage(45)
		$DamageNPC._attack_true()
		count_attack -= 1
		if count_attack < 0:
			die1()
			
			
func attack_on2():


	
#		print("Attacking pressed before atack")
		var a = load("res://Scenes/Damage/DamageArea.tscn").instance()
#		var dmg = 2
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
#		a.set_damage(dmg)
		get_parent().add_child(a)
		a.position = $DamagePos.position #разброс попадания в цель
#		a.position = position + $DamagePos.position
#		print("attaking pressed until atack ")	
			
func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout():
	attack_end = true
	attack_on()	

func _on_TimerDamage_timeout():
		$TimerDamage.start(5) # переходим в режим атаки через 5 сек
		attack_end = false
		attack_on()	
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = $Sprite.global_position.x
	_new_data["positionY"] = $Sprite.global_position.y		
	_new_data["whoiam"] ="res://Scenes/Race/Knight.tscn"
	_new_data["nickname"] ="Knight"
	return _new_data
func set_data(_new_data):
	set_data_all(_new_data)
#	print(_new_data["level"])
	if _new_data["level"] > 0:
		self.level1 = _new_data["level"]
#		print(level1)
#		print(level)
func _on_TimerDie_timeout():
		self.dead = true
		get_parent().remove_child(self)
		queue_free()

