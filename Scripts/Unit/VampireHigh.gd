#extends KinematicBody2D
extends "res://Scripts/Stickman.gd"
# скрипт основного игрока, наследуется от  Player_main.tscn,player.gd

#Высший Вампир
var stands = true
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 65

var target_intercepted =  Vector2()

var attack = true
var player = 0 # id player object
var player_control = false
var expirience = 0
var level = 0
var speed_level = 1.4 # скорость набора опыта(коеффициент, насколько нужно больше опыта для след. уровня
var level_up = false
var level_exp = false
var exp_need = 100 # кол-во опыта, нужное для повыешения уровня
var damage_power = 5 
#func set_target_position(pl):
#	target_intercepted = pl
#	return player
func set_player_id(player_id):
	player = player_id
	return player
func search_for_target():
#	target = null
#	var pl = get_parent().get_parent().get_player()
	if target_intercepted:
#		if position.distance_to(pl.position) < 200:
		cancel_movement()
		speed = default_speed * 5 if speed == default_speed else speed
		target = target_intercepted
#		else:
#			if target:
#				cancel_movement()
#			target = null
		if target:
			set_destination(target) #.position)

func _ready():
	speed = default_speed
#	self.dead = false
	self.hp = 2000
	self.max_hp = 2000
#	print("before start hp")
	set_start_hp(self.hp, self.max_hp)
#	add_to_group(GlobalVars.entity_group)
#	add_to_group(GlobalVars.animal_group)
#	add_to_group(Global_DataParser.darkempire_group)
	add_to_group(Global_DataParser.neutral_group)

#	var skin = ItemMachine.generate_inventory_item("dagger")
#	self.inventory.add_item(skin)
	$TimerAttack.start(5)	
	Global_DataParser.inc_mobs(11,1)	
func _process(delta):
	if level_up == true:
		$LevelLabel.text = str(level)
		level_up = false	
#	if self.dead == false:
#		prev_pos = position
	if velocity:
		move_and_slide(velocity)
	#		position.x = clamp(x, 0, 2000)
	#		position.y = clamp(y, 0, 2000)

	wander()
	return
	if attack == true:
#		print("Archer ready attack")
		$DamageNPC.set_damage(199)
		var target_count = $DamageNPC._attack_true(player)
		attack = false
		$TimerAttack.start(5)
		if target_count != null and target_count >  0:
			var pl1 = $DamageNPC.search_for_target1()
			var pl = pl1["position_target"]
			target_intercepted = pl
			search_for_target()
			attack_on()			
#		if target_intercepted and can_bite:
#			bite(target)
#	else:
#		cancel_movement()
func attack_on():
		if (Global_DataParser.energy > 1):		
			Global_DataParser.reduce_energy_vampire(1) #уменьшаем энергию для светлых и темных аватаров
			if 	self.max_hp == self.hp:
				self.max_hp += (1+self.level)
				$HP_bar.max_value = int(max_hp) 
			increase_hp(1+self.level) #регенерация здоровья
			add_exp(1+self.level) #добавляем опыт			
		return	
#	if player_control == false:
#		print("Attacking pressed before atack")
		var	object_path = "res://Scenes/Damage/Damage_High.tscn"
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"DamageHigh")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,$Sprite.global_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)

#		var a = load("res://Scenes/Damage/Damage_High.tscn").instance()
#		var dmg = 100
#		$'/root/Game/Empire'.add_child(a)		
#		a.position = $Sprite.global_position # $DamagePos.position #разброс попадания в цель
#		a.set_target_position(target_intercepted)
func increase_xp(val):
	expirience += 	val	

func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false

func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
	$StandingTimer.start(2)
	speed = default_speed
	
func wander():
	var pos = position
	if stands:
		randomize()
		x = int(rand_range(pos.x - 150, pos.x + 150))
		y = int(rand_range(pos.y - 150, pos.y + 150))
		
#		x = clamp(x, -23500, -22400)
#		y = clamp(y, -500, 1000)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			attack_on()
		elif pos.distance_to(destination) <= 0.6:
			cancel_movement()
			attack_on()
			
#func search_for_target():


func _on_Timer_timeout():
	stands = true
#	pass # Replace with function body.


func _on_TimerAttack_timeout():
#		attack = true # снова можно атаковать
#		return
		$DamageNPC.set_damage(199)
		var target_count = $DamageNPC._attack_true(player)
		attack = false

		if target_count != null and target_count >  0:
			var pl1 = $DamageNPC.search_for_target1()
			var pl = pl1["position_target"]
			target_intercepted = pl
			search_for_target()
		attack_on()		
		attack = true
		$TimerAttack.start(45)		
func _on_StandingTimer_timeout():
	stands = true
func add_level(val):
	level += val
#	print("level up")
#	print(level)
	self.max_hp *= speed_level
	self.hp = self.max_hp
	update_hp()	
	level_up = true
	return level
	
func add_exp(val):
	var a = add_expirience(val)
#	print("expirience up")
#	print(expirience)
	level_exp = true	
	if	a >= exp_need:
		expirience = a - exp_need		
		add_level(1) # повышаем уровень персонажа
		up_power()
		up_exp_need(speed_level)
#		if expirience == 0:
#			return
#		else:
#			add_exp(exp_need)	
func up_exp_need(val):
	exp_need *= val
	return int(exp_need)

func up_power():
	hp = int(max_hp * 1.1)
	hp = max_hp
#	max_mana = int(max_mana * 1.05)
	damage_power  = damage_power * 1.20 # повышаем характеристики персонажа


func add_expirience(val):
	expirience +=val
	return expirience
