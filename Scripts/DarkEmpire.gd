extends "res://Scripts/Stickman.gd"
#это юнит Жрица Светлых Эльфовб лечит Светлых юнитовб темным юнитам наносит урон
var stands = true
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 45
var	attack_end = true

func search_for_target1(pl):
#	var pl = get_parent().get_parent().get_parent().get_player()
#		var pl = Global_DataParser.player_position
#	if pl != Vector2(0,0):
#		if position.distance_to(pl) < 2500:
	#		print("You character has visible for Monster!!!")

			cancel_movement()
			speed = default_speed * 2 if speed == default_speed else speed
			target = pl
			$TimerTarget.start(12) # переходим в режим преследования на 10 сек			
			if attack_end == false:
				$Timer.start(10) # переходим в режим атаки на 1сек
				attack_end = true
#		else:
#			if target:
#				cancel_movement()
#			target = null
#			if target:
				set_destination(target)
func search_for_target(pl):
#	if dead == true:
#		return false
#	var pl = get_parent().get_parent().get_player()
#	if pl:
#		if position.distance_to(pl.position) < 5000:
	#		print("You character has visible for Monster!!!")

			cancel_movement()
			speed = default_speed * 2 if speed == default_speed else speed
			target = pl #.position
#			if attack_end == false:
#				$Timer.start(5) # переходим в режим атаки на 1сек
#				attack_end = true
#		else:
#			if target:
#				cancel_movement()
#			target = null
#		if target:
			set_destination(target)

func _ready():
	speed = default_speed
	self.hp = 100
	self.max_hp = 100
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.empire_group)
	$StandingTimer.start(20)
	Global_DataParser.inc_mobs(13,1)	
func _process(delta):

	if velocity:
		prev_pos = position
		move_and_slide(velocity)

	if 	attack_end == false:
#		print("ходим")	
		wander()

	$DamagePos.position = position
#	print("Цель рядом - атакуем")

	if 	attack_end == true :
#		print("atack Shaman")
		attack_on()
		attack_end = false
#		$Timer.start(1) # переходим в режим атаки на 1сек
#		attack_end = false
#	if attack_end == false:
		$Timer.start(10) # переходим в режим  атаки через 10 сек
#		attack_end = true


func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false

func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
	$StandingTimer.start(5)
	speed = default_speed
#	stands = true
	
func wander():
	var pos = position
	if stands:
		randomize()
		x = int(rand_range(pos.x - 150, pos.x + 150))
		y = int(rand_range(pos.y - 150, pos.y + 150))
		
#		x = clamp(x, -23500, -22000)
#		y = clamp(y, -500, 1000)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()

		else:

			if pos.distance_to(destination) <= 0.7:
				cancel_movement()
			
			
func attack_on():
#		print("Attacking pressed before atack")
		var a = load("res://Scenes/Damage/DamageAreaLightResurect.tscn").instance()
		var dmg = 75
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
		a.set_damage(dmg)
		get_parent().add_child(a)
		a.position = $DamagePos.position #разброс попадания в цель
#		a.position = position + $DamagePos.position
#		print("attaking pressed until atack ")	


func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout():
	attack_end = true	
#	attack_end = false
#	print("ищем")
#	search_for_target()	


func _on_TimerTarget_timeout():
#	print("Target End on 10 sec")
	target = null
	cancel_movement()	
func _unhandled_input(event):
	if event.is_action_pressed("Alt"):
#		print("I pressed Alt")
#		toggle_hp_bar()
#		if dead == false:
		var pl = Vector2(0,0)
#		print("target Global position")		
#		print(Global_DataParser.player_position1)		 
		pl = Global_DataParser.player_position1

#		print("target alt position")
#		print(pl)				
		search_for_target(pl)	
#		cancel_movement()
#		speed = default_speed * 2 if speed == default_speed else speed
#		set_destination(Global_DataParser.player_position1)
		
