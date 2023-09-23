extends "res://Scripts/Stickman.gd"

var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 45
var	attack_end = true #  строим бесли  true
var max_build = 2 # максимум зданий для постройки
var build = 0 # сколько осталось построить зданий
var main_town # координаты, где появился этот юнит и куда возвращаться.
var build_position
var builds_count = 0 # всего построено зданий

func search_for_target():
	var pl = main_town
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

func _ready():
	build_position = $DamagePos.position
#	print(build_position)
	speed = default_speed
	self.hp = 100
	self.max_hp = 100
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.animal_group)
	$StandingTimer.start(5)
#	print ("ready for build")
	build = max_build
	attack_on()
	$TimerNewBuild.start(300)

func _process(delta):

	if velocity:
		prev_pos = position
		move_and_slide(velocity)
	wander()
#	search_for_target()
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
	$StandingTimer.start(5)
	speed = default_speed
#	if attack_end == true:
#		print ("building in progress...")
#		$Timer.start(1) # перsеходим в режим атаки на 1сек
#		attack_end = false
#		attack_on()	

func wander():
	var pos = position
	if stands:
		randomize()
		x = int(rand_range(pos.x - 150, pos.x + 150))
		y = int(rand_range(pos.y - 150, pos.y + 150))
		
#		x = clamp(x, -25500, 2000)
#		y = clamp(y, -1500, 1500)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()

		else:

			if pos.distance_to(destination) <= 0.6:
				cancel_movement()
			
			
func attack_on():

	if build > 0:
		build -= 1
#		print(build)
		if build == 0:
			search_for_target() # возвращаемся на место появления

			return
#		print("Attacking pressed before atack")
#		var a = load("res://Scenes/DamageAreaLight.tscn").instance()
		if get_tree().is_network_server():
			var object_path ='res://Scenes/Build/FarmVampire.tscn'
			Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"FarmVampire",Global_DataParser.join_race,Global_DataParser.location_number)

##		var a = load("res://Scenes/Build/FarmVampire.tscn").instance()
#		var dmg = 2
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
#		a.set_damage(dmg)
#		get_parent().add_child(a)

##		$'/root/Game/Empire'.add_child(a)
#		a.position = $DamagePos.position #разброс попадания в цель
#		a.position = build_position
#		print(a.position)
#		print("Farm position")
#		a.position.x = 256* int(position.x/256) #разброс попадания в цель
#		a.position.y = 256* int(position.y/256)
#		print(a.position)		
#		a.position = $Sprite.global_position   #.position + $DamagePos.position
		print("Vampire-Worker builded farm vampire")	
#		print(build)
		builds_count += 1
#		print("all builds from alchemist = ")
#		print(builds_count)
#		print(a.position)
#		print("Alchemist position")
#		print(self.position)		
	else:
#		print("Not building")
#		print("Нечего строить")
		return
		
func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout():
	attack_end = true


func _on_TimerNewBuild_timeout():
	build = max_build #снова можем строить
	attack_on()	
	$TimerNewBuild.start(300)	# Replace with function body.
