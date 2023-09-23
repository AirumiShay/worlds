extends "res://Scripts/Unit/npc_player_control.gd"
#Это юнит умертвиеб раса нежить
var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 20
var	attack_end = true
var count_attack = 100
var player_control = false # моб сейчас управляется игроком?
var npc_god = false
var target_main = Vector2(0,0)

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

#var dead = false
func search_for_target():
	if dead == true:
		return false
	var pl = target_main
	if pl:
		if position.distance_to(pl) < 1000:
	#		print("You character has visible for Monster!!!")

			cancel_movement()
			speed = default_speed * 1.5 if speed == default_speed else speed
			target = pl
#			if attack_end == false:
#				$Timer.start(5) # переходим в режим атаки на 1сек
#				attack_end = true
		else:
			if target:
				cancel_movement()
			target = null
		if target:
			set_destination(target)

func _ready():
	dead = false
	speed = default_speed
	self.hp = 50
	self.max_hp = 50
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.neutral_group)
	$StandingTimer.start(2)
#	add_bag()
	Global_DataParser.inc_mobs(9,1)		
func add_bag():
	var	bag = load('res://Scenes/Bag.tscn').instance()
	bag.name = "Bag_NPC_" + str(Global_DataParser.rng.randi())
#	print(bag.name) #= nickname
	$Inventory.add_child(bag)
func set_target(target1):
	target_main = target1
	print(target1)	
	
	
	
func die1():
	if	Global_DataParser.player_control == false:
		player_control = false				
		$Camera.current = false
		die()	
		dead = true	
	#	print("Paladin Dead")
		Global_DataParser.dec_mobs(9,1)
		cancel_movement()
		set_process(false)
		$Sprite.texture = load("res://Assets/units/mob/drow_f.png")	
	#	die()
		self.hp = 0	
		$HP_bar.visible = false
#		toggle_hp_bar()	


	$TimerDead.start(120)
	
func _process(delta):
	if level_up == true:
		$LevelLabel.text = str(level)
		level_up = false
		$LevelLabel.visible = true	
	npc_player_control()
	
func npc_player_control():	
	if dead == false:
		if player_control == false:
			$Camera.current = false	
			speed = default_speed * 5				
			if velocity:
				prev_pos = position
				move_and_slide(velocity)
			wander()
#			if target_main != Vector2(0,0):
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

			if Input.is_action_pressed("spell_3"):
				attack_play2()
			if Input.is_action_pressed("spell_4"):
				attack_play3()


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
#		Global_DataParser.player_control = false
#		player_control = false			
func toggle_player_control():	# переключаем управление на игрока и обратно на скрипт
	if Global_DataParser.player_control == false:
		Global_DataParser.player_control = true
		player_control = true
		$Camera.current = true	
		speed = default_speed * 5		
		$LevelLabel.visible = true	
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
	attack_on()	

func wander():
	var pos = position
	if stands:
		randomize()
#		x = int(rand_range(pos.x - 150, pos.x + 150))
#		y = int(rand_range(pos.y - 150, pos.y + 150))

		var x1 = int(rand_range(- 250, 250))
		var y1 = int(rand_range(- 250, 250))
		x = pos.x + x1
		y = pos.y + y1
#		x = clamp(x, -25500, -22000)
#		y = clamp(y, -1500, 1000)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()

		else:

			if pos.distance_to(destination) <= 5:
				cancel_movement()
			
			
func attack_on():
	if player_control == false:
#		print("Attacking pressed before atack")
		var a = load("res://Scenes/Damage/DamageArea.tscn").instance()
		var dmg = 15
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
		a.set_damage(dmg)
		a.name = "DamageArea_" + str(Global_DataParser.rng.randi())		
		
		get_parent().add_child(a)
#		$'/root/Game/Empire'.add_child(a)		
		a.position = $Sprite.global_position #разброс попадания в цель
#		a.position = position + $DamagePos.position
#		print("attaking pressed until atack ")	
		count_attack -= 1
		if count_attack < 0:
			die1()
func attack_play():
		var a = load("res://Scenes/Damage/DamageArea.tscn").instance()
		var dmg = 5
		a.set_damage(damage_power)
		a.set_parent_is(self)	
		get_parent().add_child(a)
		a.position = $Sprite.global_position # $DamagePos.position #разброс попадания в цель
func attack_play2():
		var a = load("res://Scenes/Damage/DamageAreaDark.tscn").instance()
		var dmg = 10
		a.set_damage(damage_power)
		a.set_parent_is(self)
		get_parent().add_child(a)
		a.position = $Sprite.global_position # $DamagePos.position #разброс попадания в цель
func attack_play3():
		var	a = load("res://Scenes/Damage/DamageAreaRemove.tscn").instance()
		var dmg = 250
		a.set_damage(dmg)
#		a.set_parent_is(self)
		get_parent().add_child(a)
		a.position = $Sprite.global_position # $DamagePos.position #разброс попадания в цель


func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout():
	attack_end = true


func _on_TimerDead_timeout():
	get_parent().remove_child(self)
	queue_free()
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = $Sprite.global_position.x
	_new_data["positionY"] = $Sprite.global_position.y		
	_new_data["whoiam"] ="res://Scenes/Race/Zombi.tscn"
	_new_data["nickname"] ="Zombie"
	return _new_data
func set_data(_new_data):
	set_data_all(_new_data)
