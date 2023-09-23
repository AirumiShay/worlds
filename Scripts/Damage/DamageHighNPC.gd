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
#var dead = false
#var speed
#var bite_strength = 10
#var target_intercepted = false
#var can_bite = true
var attack = true
var player = 0 # id player object
func set_target_position(pl):
	target_intercepted = pl
	return target_intercepted 
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
	
func search_for_target1(pl):
#	target = null
#	var pl = get_parent().get_parent().get_player()
	if pl:
#		if position.distance_to(pl.position) < 200:
		cancel_movement()
		speed = default_speed * 3 if speed == default_speed else speed
		target = pl
#		else:
#			if target:
#				cancel_movement()
#			target = null
		if target:
			set_destination(target) #.position)

func _ready():
	speed = default_speed
#	self.dead = false
	self.hp = 200
	self.max_hp = 200

	set_start_hp(self.hp, self.max_hp)
#	add_to_group(GlobalVars.entity_group)
#	add_to_group(GlobalVars.animal_group)
#	add_to_group(Global_DataParser.darkempire_group)
	add_to_group(Global_DataParser.neutral_group)
	add_to_group(Global_DataParser.unhole_ground_group)

	$Timer.start(60)	
	$TimerAttack.start(1)	
	
func _process(delta):
#	if self.dead == false:
#		prev_pos = position
	if velocity:
		move_and_slide(velocity)
	#		position.x = clamp(x, 0, 2000)
	#		position.y = clamp(y, 0, 2000)

#	wander()
	return
	if attack == true:
#		print("Archer ready attack")
		$DamageNPC.set_damage(199)
		var target_count = $DamageNPC._attack_true(player)
		attack = false
		$TimerAttack.start(10)
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
			cancel_movement()
			attack_on()
		elif pos.distance_to(destination) <= 0.6:
			cancel_movement()
			attack_on()			
#func search_for_target():

func attack_on():
#	if player_control == false:
#		print("Attacking pressed before atack")
		var a = load("res://Scenes/Damage/DamageAreaRemove.tscn").instance()
		var dmg = 150
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
		a.set_damage(dmg)
		$'/root/Game/Empire'.add_child(a)		
#		get_parent().add_child(a)
		return
#		a.new_position = $Sprite.global_position #$DamagePos.position #разброс попадания в цель
		a.position = $Sprite.global_position #$DamagePos.position #разброс попадания в цель

		var b = load("res://Scenes/Damage/DamageAreaFireLightMobs.tscn").instance()
		dmg = 150
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
#		b.set_damage(dmg)
		$'/root/Game/Empire'.add_child(b)		
		get_parent().add_child(a)
#		b.new_position = $Sprite.global_position #$DamagePos.position #разброс попадания в цель

func _on_Timer_timeout():
#func _on_Timer_timeout():
	print("damagehigh end")
	get_parent().remove_child(self)
	queue_free()


func _on_TimerAttack_timeout():
		attack_on()	
		print("attack now")
#		attack = true # снова можно атаковать
#		return
		$DamageNPC.set_damage(199)
		var target_count = $DamageNPC._attack_true(player)
		attack = false

		if target_count != null and target_count >  0:
			var pl1 = $DamageNPC.search_for_target1()
			var pl = pl1["position_target"]
			target_intercepted = pl
			if pl !=  Vector2():
				search_for_target()
	
		attack = true
		$TimerAttack.start(10)		
func _on_StandingTimer_timeout():
	stands = true
