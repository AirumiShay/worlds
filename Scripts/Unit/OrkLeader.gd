extends "res://Scripts/Stickman.gd"

var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 60
var	attack_end = true #  строим если  true
var max_build = 2 # максимум зданий для постройки
var build = 0 # сколько осталось построить зданий
var main_town # координаты, где появился этот юнит Ork Leader  и куда возвращаться.
var builds_count = 0
var build_time = 600 # через сколько секунд строить новое здание

func search_for_target():
	var pl = main_town
	if pl:
		if position.distance_to(pl.position) < 750:

			cancel_movement()
			speed = default_speed * 2 if speed == default_speed else speed
			target = pl
			print("go to home")
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
	speed = default_speed
	self.hp = 1000
	self.max_hp = 1000
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.animal_group)
	$StandingTimer.start(5)
#	print ("ready for build")
	build = max_build
	attack_on()
#	$TimerNewBuild.start(30)
	main_town = position
	print("main_town")
	main_town = self.position #$Sprite.global_position # 
	print (main_town)
	$TimerNewBuild.start(build_time)
	
func _process(delta):

	if velocity:
		prev_pos = position
		move_and_slide(velocity)
	wander()
#	search_for_target()
	$DamagePos.position = position

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
#	print("there position for go worker  farm blue")
#	print(pos)
	if stands:
		randomize()
		x = int(rand_range(pos.x - 550, pos.x + 550))
		y = int(rand_range(pos.y - 550, pos.y + 550))
		
#		x = clamp(x, -25500, 20000)
#		y = clamp(y, -1500, 1500)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()

		else:

			if pos.distance_to(destination) <= 0.6:
				cancel_movement()
			
			

	
func attack_on_server():
	if is_network_master():
#		attack_on()
		rpc_spawn_HomeOrk()		
	return false
func rpc_spawn_HomeOrk():
	if get_tree().is_network_server():	 
		var object_path = 'res://Scenes/Build/HomeOrk.tscn'
#		Global_DataParser.build_farm += 1		
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,position,"HomeOrk",Global_DataParser.join_race,Global_DataParser.location_number)

func attack_on():
	if build > 0:
		build -= 1
#		print(build)
		if build == 0:
			search_for_target() # возвращаемся на место появления

			return
		rpc_spawn_HomeOrk()			
#		var a = load("res://Scenes/Build//HomeOrk.tscn").instance()
#		$'/root/Game/Dark'.add_child(a)
#		a.position = position #разброс попадания в цель
		builds_count += 1
#		print("all builds from worker = ")
#		print(builds_count)
	else:
#		print("Not building")
		return
		
func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout():
	attack_end = true


func _on_TimerNewBuild_timeout():
	build = max_build #снова можем строить
	attack_on()	
	$TimerNewBuild.start(build_time)	# Replace with function body.
