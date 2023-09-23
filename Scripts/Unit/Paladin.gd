extends "res://Scripts/Stickman.gd"

var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 30
var	attack_end = true
var count_attack = 500
#var dead = false
func search_for_target():
	if dead == false:
		return false
	var pl = get_parent().get_parent().get_player()
	if pl:
		if position.distance_to(pl.position) < 200:
	#		print("You character has visible for Monster!!!")

			cancel_movement()
			speed = default_speed * 1.25 if speed == default_speed else speed
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

func _ready():
	dead = false
	speed = default_speed
	self.hp = 400
	self.max_hp = 400
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.empire_group)
	$StandingTimer.start(5)
func die1():
	dead = true	
#	print("Paladin Dead")
	Global_DataParser.dec_paladin(1)
	cancel_movement()
	set_process(false)
	$Sprite.texture = load("res://Assets/units/mob/drow_f.png")	
#	die()
	self.hp = 0	
	toggle_hp_bar()	

func _process(delta):
	if dead == false:
		if velocity:
			prev_pos = position
			move_and_slide(velocity)
		wander()
		search_for_target()
		$DamagePos.position = position
	#	print("Цель рядом - атакуем")
	#	if 	attack_end == true:
	#		attack_on()

func _unhandled_input(event):
	if event.is_action_pressed("Alt"):
#		print("I pressed Alt")
		toggle_hp_bar()
				
func set_destination(dest):
	destination = dest
	velocity = (destination - position).normalized() * speed
	stands = false

func cancel_movement():
	velocity = Vector2()
	destination = Vector2()
	$StandingTimer.start(3)
	speed = default_speed
	if attack_end == true:
		$Timer.start(2) # переходим в режим атаки на 1сек
		attack_end = false
		attack_on()	

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
			
			
func attack_on():
	if dead == false:	
#		print("Attacking pressed before atack")
		var a = load("res://Scenes/Damage/DamageArea.tscn").instance()
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
		count_attack -= 1
		if count_attack < 0:
			die1()
func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout():
	attack_end = true