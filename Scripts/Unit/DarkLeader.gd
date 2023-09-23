extends "res://Scripts/Stickman.gd"

var printdbg = false
var stands = false
var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()
var x 
var y
var target = null
var default_speed = 30
var	attack_end = true # закончилась атака
var	attack = true # снова можно атаковать
var spawn = false
var spawn_time = 30 #время рождения Темных рейдеров



func search_for_target():
	var pl = get_parent().get_player()
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
	speed = default_speed
	self.hp = 60
	self.max_hp = 60
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
	if get_tree().is_network_server():	
		$StandingTimer.start(25)
		$SpawnTimer.start(spawn_time)	
	
	spawn = true
	rpc_spawn_mobs()
	update_hp()		

func _process(delta):
	if get_tree().is_network_server():	
		if velocity:
			prev_pos = position
			move_and_slide(velocity)
		wander()
	#	if get_tree().is_network_server():
	#		search_for_target()
		$DamagePos.position = position
	#	print("Цель рядом - атакуем")
		if 	attack_end == true:
			attack_end = false
			attack_on()
			$Timer.start(10)
		
func _unhandled_input(event):
	if event.is_action_pressed("Alt"):
#		print("I pressed Alt")
		toggle_hp_bar()
				
func set_destination(dest):
		rpc("_move_mob",dest)
		
remote func _move_mob(dest):
		print("Server moved Dark Leader")	
#		a.position = position
		var destination = Vector2() 	
		destination = dest
		velocity = (destination - position).normalized() * speed
		stands = false
func set_velocity(dest):
		rpc("_velocity_mob",dest)
		
remote func _velocity_mob(dest):
		print("Server moved Dark Leader")	
#		a.position = position
		var velocity = dest 	
#		destination = dest
#		velocity = (destination - position).normalized() * speed
#		stands = false

func cancel_movement():
#	velocity = Vector2()#
#	destination = Vector2()
	if get_tree().is_network_server():
		set_destination(Vector2())
		set_velocity(Vector2())
	$StandingTimer.start(5)
	speed = default_speed
#	if attack_end == true:
#		$Timer.start(2) # переходим в режим атаки на 1сек
#		attack_end = false
#		attack_on()	

func wander():
	if get_tree().is_network_server():		
	
		var pos = position
		if stands:
			
			randomize()
			x = int(rand_range(pos.x - 150, pos.x + 150))
			y = int(rand_range(pos.y - 150, pos.y + 150))
			
			x = clamp(x, -25500, -22000)
			y = clamp(y, -1500, 1000)
			set_destination(Vector2(x,y))
			
		elif velocity != Vector2():
			if pos.distance_to(destination) <= speed:
				cancel_movement()

			else:

				if pos.distance_to(destination) <= 0.5:
					cancel_movement()
func printdebug(val):
	if printdbg == true:
		print(val)		
		

func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if get_tree().is_network_server():
		var object_path = 'res://Scenes/Dungeon/Mobs/Mobs1.tscn' #'res://Scenes/Race/DarkRider.tscn'
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"Peasant2",Global_DataParser.join_race,Global_DataParser.location_number)

	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
		rpc("spawn_mobs", "DarkMob", position)
	
#		kobold_count += 1
#		print("all spawning Dark Rider =")
#		print(kobold_count)


sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Dungeon/Mobs/Mobs1.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning stage 2")
#	bag.name = nickname
	add_npc_on_location(town)
	town.position = $Sprite.global_position	
#	var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
#	Global_DataParser.write_data(bag_url_data, data)
#	town.init(_inventory, town.name, data, die_position, bag_url_data)
#	town.reload_data_by_inventory(_inventory)

		
func attack_on():
	

		var a = load("res://Scenes/Damage/DamageAreaFire.tscn").instance()

		get_parent().add_child(a)
			
		a.position = $DamagePos.position #разброс попадания в цель
		printdebug(a.position)		


func _on_StandingTimer_timeout():
	stands = true


func _on_Timer_timeout(): #снова можно атаковать
	attack_end = true


func _on_SpawnTimer_timeout():
	spawn = false
	rpc_spawn_mobs()


func _on_TimerAttack_timeout():
	attack = true # снова можно атаковать
