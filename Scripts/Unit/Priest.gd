extends "res://Scripts/Stickman.gd"

var printdbg = false
var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 45
var	attack_end = true

func search_for_target1(pl):
#	var pl = get_parent().get_parent().get_player()
	if pl:
		if position.distance_to(pl.position) < 500:
	#		print("You character has visible for Monster!!!")

			cancel_movement()
			speed = default_speed * 2 if speed == default_speed else speed
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
	self.hp = 60
	self.max_hp = 60
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
	$StandingTimer.start(25)

func _process(delta):

	if velocity:
		prev_pos = position
		move_and_slide(velocity)
	wander()
#	search_for_target()
	$DamagePos.position = position
#	print("Цель рядом - атакуем")
	if 	attack_end == true:
		attack_end = false
		attack_on()

func _unhandled_input(event):
	if event.is_action_pressed("Alt"):
			var pl = Global_DataParser.player_position1
#			print("dark elf target position")
#			print(pl)		
			search_for_target(pl)	
			
func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false

func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
	$StandingTimer.start(5)
	speed = default_speed
#	if attack_end == true:
#		$Timer.start(2) # переходим в режим атаки на 1сек
#		attack_end = false
#		attack_on()	

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
func printdebug(val):
	if printdbg == true:
		print(val)		
func attack_on():

		var a = load("res://Scenes/Damage/DamageAreaLightResurect.tscn").instance()
		var dmg = 500
		a.set_damage(dmg)
		get_parent().add_child(a)
			
		a.position = $Sprite.global_position #разброс попадания в цель



func _on_StandingTimer_timeout():
	stands = true
	attack_end = true

func _on_Timer_timeout():
	attack_end = false
