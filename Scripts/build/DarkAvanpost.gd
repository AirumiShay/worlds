#extends "res://Scripts/Stickman.gd"
extends "res://Scripts/Unit/npc_player_control.gd"

#DarkAvanpost
onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
onready var spawn = true
var _name:String
var spawn_position = Vector2(-21000.0,300.0)
#var spawn = true
var spawn_time = 12 #время рождения крестьян и строительства хуторов
var spawn_time2 = 36 #время рождения животных и строительства поселков и замка
var npc_god = false
var new_position = 0
var already_build = false
var who_spawn = 0
var wave_spawn = -1 #равен количеству лет жизни этого хутора
var build_village = true
var peasant_count = 0
var energy_farm = 50
var resource = 0 # накоплено ресурсов
var level_farm = 0 # равен количеству лет жизни этого хутора
var level_farm2 = 0 # равен количеству построенных зданий этим хутора
var res_add = 0 #кол-во ресурсов, добываемых за один заход равно кол-ву крестьян
var name_farm = "Avanpost"
var owner_name = "DARK EMPIRE"
var founder = "Server" # основатель поселения
var what_do = 0
var can_spawn = 0 # если 0 - пришло время строить
var can_spawn2 = 1 #  сколько раз пропустить  перед постройкой
var now_city = 0 # 0 - это хутор, 1 - это поселок 2 - это город
func _ready():
	set_process(false)
	set_process_input(false)
#	wave_spawn = new_position
	self.hp = 250
	self.max_hp = 250
	Global_DataParser.build_farm += 1	
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.builds_group)	
	add_to_group(Global_DataParser.build_remove_group)
	add_to_group(Global_DataParser.build_repare_group)	
#	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
#	if what_do > 0:
#		$SpawnTimer.start(spawn_time)
#		print("Start WhatTimer in Farm")
#		$WhatTimer.start(spawn_time)		
	$Level.text = str(what_do) #
	$Year.text = str(wave_spawn)
#	$Owner.text = owner_name + ":" + name_farm
	rpc_spawn_mobs()
	update_hp()
	$New_Generation.value  = level_farm2 
	if get_tree().is_network_server():	
		$Timer.start(spawn_time)
	Global_DataParser.build_farm += 1
	$TimerBegin.start(5)
	$SpriteBegin.visible = true
	Global_DataParser.build_avanpost_dark = Global_DataParser.build_avanpost_dark + 1	
func _process(delta):
#	rpc("destroy_self")
#	if spawn == false:
#		spawn == true
	
	if hp > 0:
		print(hp)
		hp -= 10	
		$HP_bar.value = hp

		if hp < 0:
			rpc("destroy_self")	# уничтожаем это поселение
	else:
		print ("village destroyed!!!")	
		print (hp)			

#		print("spawn_mobs")
#		rpc_spawn_mobs()
func get_data_build():
	var data_build = {
		"Resource":0,
		"People":0,
		"Level":0,
		"Generation":0,
		"Name":"Farm"
	}
	data_build["Resource"] = resource
	data_build["People"] = peasant_count
	data_build["Level"] = wave_spawn
	data_build["Generation"] = peasant_count
	data_build["Name"] = name_farm	
	
	return data_build
func set_what_do(what):
	rpc("set_mode",what)
sync func set_mode(what):
	if what > 0:
		if get_tree().is_network_server():		
			$WhatTimer.start(spawn_time2)
			$SpawnTimer.start(spawn_time)
			spawn = true
		already_build = false
	what_do = what
	$Level.text = str(what_do)	
func increase_hp(val):
	self.hp = min(self.hp + val, self.max_hp)
	update_hp()
#	print("increase hp. HP = %s" % self.hp)
	
						
func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if get_tree().is_network_server():
		var object_path ='res://Scenes/Race//DarkElf.tscn'
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"Peasant",Global_DataParser.join_race,Global_DataParser.location_number)

#	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
#		rpc("spawn_mobs", "Peasant", position)
	
#	rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)
#		kobold_count += 1
#		print("all spawning Paladin in Temple =")
#		print(kobold_count)


sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Race/Peasant.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning from Farm Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = $Sprite.global_position
	print(self.position)
	Global_DataParser.inc_mobs(8,1)
	peasant_count += 1		
#	return
	var town1 = load('res://Scenes/Nature/Grass2.tscn').instance()
	town1.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning grass 2")
#	bag.name = nickname
	$'/root/Game/Empire/Grass'.add_child(town1)
	town1.position = $Sprite.global_position #die_position
#	Global_DataParser.inc_mobs(7,1)		
#	var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
#	Global_DataParser.write_data(bag_url_data, data)
#	town.init(_inventory, town.name, data, die_position, bag_url_data)
#	town.reload_data_by_inventory(_inventory)
func rpc_spawn_farm(posXY):
	if get_tree().is_network_server():	 
		var object_path = 'res://Scenes/Build/DarkAvanpost.tscn'
#		Global_DataParser.build_farm += 1		
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"FarmEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#	spawn_farm("Farm",posXY)
sync func spawn_farm(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/FarmEmpire.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning from Farm Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
#	print(die_position)	
	town.set_New_Generation(int(new_position),Global_DataParser._player_name, die_position)
#	print(int(new_position))
	Global_DataParser.build_farm += 1	
func rpc_spawn_fortress(posXY): 
	if get_tree().is_network_server():	 
		var object_path = "res://Scenes/Build/FortressDarkElf.tscn"
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"FortressDarkElf",Global_DataParser.join_race,Global_DataParser.location_number)
func rpc_spawn_avanpost_troll(posXY):
	if get_tree().is_network_server():	 
		var object_path = "res://Scenes/Build/Avanpost.tscn"
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"FortressDarkElf",Global_DataParser.join_race,Global_DataParser.location_number)
	
#	spawn_fortress("Fortress",posXY)
sync func spawn_fortress(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/Fortress.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning Fortress  from Farm Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
#	print(die_position)	
#	town.set_New_Generation(int(new_position),Global_DataParser._player_name, die_position)
#	print(int(new_position))
	Global_DataParser.build_fortress += 1	
func rpc_spawn_storage(posXY): 
	if get_tree().is_network_server():	 
		var object_path = "res://Scenes/Build/Storage.tscn"
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"Storage",Global_DataParser.join_race,Global_DataParser.location_number)

#	spawn_storage("Storage",posXY)
sync func spawn_storage(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/Storage.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning from Farm  Storage Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
#	print(die_position)	
#	town.set_New_Generation(int(new_position),Global_DataParser._player_name, die_position)
#	print(int(new_position))
	Global_DataParser.build_storage += 1	

func rpc_spawn_magtower(posXY): 
	if get_tree().is_network_server():	 
		var object_path = "res://Scenes/Build/MagicTower.tscn"
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"MagicTower",Global_DataParser.join_race,Global_DataParser.location_number)

#	spawn_magtower("MagTower",posXY)
sync func spawn_magtower(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/MagicTower.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning from Farm MagicTower Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
#	print(die_position)	
#	town.set_New_Generation(int(new_position),Global_DataParser._player_name, die_position)
#	print(int(new_position))
	Global_DataParser.build_magtower += 1	

	


			
#sync 
func spawn_village(posXY): #nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if get_tree().is_network_server():	 
		var object_path = "res://Scenes/Build/VillageEmpire.tscn"
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"FortressEmpire",Global_DataParser.join_race,Global_DataParser.location_number)
	return
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
#	var town = load('res://Scenes/Build/VillageEmpire.tscn').instance()
#	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning Village Empire")
#	bag.name = nickname

#	$'/root/Game/Empire'.add_child(town)
#	town.position = die_position
#	print(die_position)	
#	town.set_New_Generation(int(new_position))
#	print(int(new_position))
#	Global_DataParser.build_village += 1	
#	return
func rpc_spawn_temple(posXY): 
	if get_tree().is_network_server():	 
		var object_path = "res://Scenes/Build/Temple_old.tscn"
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"TempleEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#	spawn_temple("Temple",posXY)		
sync func spawn_temple(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/Temple_old.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning Temple Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
#	print(die_position)	
#	town.set_New_Generation(int(new_position))
#	print(int(new_position))
	Global_DataParser.build_temple += 1
	return
func rpc_spawn_capital(posXY): 
	if get_tree().is_network_server():	 
		var object_path = 'res://Scenes/Build/DarkFortress.tscn'
		Global_DataParser.build_capital += 1			
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"CastleEmpire",Global_DataParser.join_race,Global_DataParser.location_number)
	
func rpc_spawn_castle(posXY): 
	if get_tree().is_network_server():	 
		var object_path = 'res://Scenes/Build/FortressDarkElf.tscn'
		Global_DataParser.build_castle += 1			
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,posXY,"CastleEmpire",Global_DataParser.join_race,Global_DataParser.location_number)
	
#	spawn_castle("Castle",posXY)		
sync func spawn_castle(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/Castle.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning Castle Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
#	print(die_position)	
#	town.set_New_Generation(int(new_position))
#	print(int(new_position))
	Global_DataParser.build_castle += 1	
	return				
func spawn_mobs_local(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if is_network_master():
		var town = load('res://Scenes/Animal/Pig.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())

		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Pig in EmpireFarm")
		Global_DataParser.animal_count += 1	
func spawn_mobs_local1(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if is_network_master():
		var town = load('res://Scenes/Animal/Sheep.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())

		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Sheep in EmpireFarm")
		Global_DataParser.animal_count += 1	
func spawn_mobs_local2(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if is_network_master():
		var town = load('res://Scenes/Animal/Cow.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())

		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Cow in EmpireFarm")
		Global_DataParser.animal_count += 1	
func spawn_mobs_local3(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if is_network_master():
		var town = load('res://Scenes/Animal/Horse.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())

		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Horse in EmpireFarm")
		Global_DataParser.animal_count += 1		

func spawn_mobs_local4(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if is_network_master():
		var town = load('res://Scenes/Animal/Hen.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())

		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Hen in EmpireFarm")
		Global_DataParser.animal_count += 1	

func spawn_mobs_local5(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if is_network_master():
		var town = load('res://Scenes/Animal/Dog_combat.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())

		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Dog in EmpireFarm")
		Global_DataParser.animal_count += 1		


func set_New_Generation(posXY,owner, die_position):
	new_position = posXY 
	founder = owner
	owner_name = owner + ":" + name_farm #str(self.name)
	$Owner.text = owner_name	
sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
	_data = inventory.load_data(name, "Farm")
	position = spawn_position


#func load_data(inventory:Control, filename:String, item_list_label:String = "Bag", data_player:Dictionary = Dictionary()) -> Dictionary:
##	if(item_list_label == "Bag"):
#	url_data = "res://Database//data_bag_" + filename + ".json"
#	data = Global_DataParser.load_data(url_data)
#	if ((data.empty() && item_list_label == "Bag" && !data_player.empty())):
#		Global_DataParser.write_data(url_data, data_player)
#		data = data_player
#	return data


func reload_data_by_inventory(inventory:Control) -> Dictionary:
	_data = inventory.load_data(_name, "Temple")
	return _data


func is_data_empty_by_inventory(inventory:Control) -> bool:
	return inventory.is_inventory_empty_by_data(_data)


func rpc_destroy_self():
#	return 1
	rpc("destroy_self")


sync func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
	Global_DataParser.delete_file(_url_data)


func _on_Timer_timeout():
	if hp > 50:
		if 	resource < 5001:
			resource += res_add
			res_add = peasant_count
		if 	peasant_count < 17:
			peasant_count += 1
		wave_spawn += 1
		$Year.text = str(wave_spawn)	
	#	spawn_time2 *= 2	
		$Resource.text = str(resource)
		$Level.text = str(what_do)#str(wave_spawn)
		$People.text = str(peasant_count)
		Global_DataParser.add_energy(energy_farm)		
		if who_spawn == 0:
			who_spawn += 1
			if build_village == true:
				build_village = false
				var c = int(new_position/9 - 1)	
				if c ==0:
					spawn_mobs_local1("Sheep", position)
					Global_DataParser.animal_count += 1		
				elif c == 1:
					spawn_mobs_local("Pig", position)			

					Global_DataParser.animal_count += 1			
				elif c == 2:
					spawn_mobs_local2("Cow", position)
					Global_DataParser.animal_count += 1	
				elif c == 3:
					spawn_mobs_local3("Horse", position)
					Global_DataParser.animal_count += 1	
				elif c == 4:
					spawn_mobs_local4("Hen", position)
					Global_DataParser.animal_count += 1	
			#	elif new_position == 5 and build_village: # and get_tree().is_network_server():
			#		rpc_spawn_village()		
				elif c == 5:
					spawn_mobs_local5("Dog", position)
					Global_DataParser.animal_count += 1
				elif c == 6:			
		#			rpc_spawn_mobs()			
					spawn_mobs_local5("Hen", position)
					Global_DataParser.animal_count += 1			

				elif c == 7:			
					spawn_mobs_local1("Sheep", position)
					Global_DataParser.animal_count += 1			
	#	if (who_spawn == 7) and (build_village == true):
		else:
			if who_spawn < 8:
	#		if build_village == true:			
				who_spawn += 1
				if who_spawn == 7:
	#				if resource > 100:
	#					resource -= 100
					rpc_spawn_village()
	#				energy_farm = 100		
	#				$Sprite.texture = load("res://Assets/builds_new/empire/unit_bld_archery_upg.png")														

		new_position += 1
	elif peasant_count > 2:
		hp += 1		
	$Timer.start(spawn_time)	
func spawn_all_farm():	
#	if spawn == true:	
#		spawn = false

			Global_DataParser.add_energy(energy_farm)		 	
#		if(already_build == false): #get_tree().is_network_server() and 
#			already_build = true	
			var a
			var b
			var x = int(position.x/256) - 1
			var y = int(position.y/256)	- 1
			randomize()
	#		for i in inventory.get_items():
			var x_coord = rand_range(-2, 3) # + self.position.x
			var y_coord = rand_range(-2, 3) # + self.position.y		
			a = (x_coord *4 + x + 3)  * 256
			b = (y_coord *4 + y + 2)  * 256
			var c = int(new_position/9 - 1)
			if c < 8:
				if c == 0: # строим соседний хутор
					a = int(x_coord *4 + x + 3)  * 256
					b = int(y_coord *4 + y + 2)  * 256
					new_position += 1
					if what_do == 1:
						rpc_spawn_farm(Vector2(a,b))
						level_farm2 += 1
						$New_Generation.value  = level_farm2 
	#				$SpawnTimer.start(spawn_time)							
					SoundPlayer.play(preload("res://audio/sounds/preload_sfx/frost_cast1.wav"))	
	#			if new_position == 1:
	#				a = (x + 2)  * 256
	#				b = (y + 2) * 256
	#				new_position += 1
	#				rpc_spawn_farm(Vector2(a,b))
					return				
				if c == 1:
					a = int(x_coord *4 + x + 2)  * 256
					b = int(y_coord *4 + y + 2)  * 256
				if c == 2:
					a = int(x_coord *4 + x + 1) * 256
					b = int(y_coord *4 + y + 2)  * 256
				if c == 3:
					a = int(x - 1 - x_coord *4)  * 256
					b = int(y_coord *4 + y + 2)  * 256
				if c == 4:
					a = int(x - 1 - x_coord *4)  * 256
					b = int(y_coord *4 + y)  * 256
				if c == 5:
					a = int(x_coord *4 + x) * 256
					b = int(y - 1 - x_coord *4)  * 256
				if c == 6:
					a = int(x_coord *4 + x + 2)  * 256
					b = int(y_coord *4 + y) * 256
				if c == 7:
					a = int(x_coord + x + 3)  * 256
					b = int(y_coord + y + 3) * 256
																																										
				print ("Farm position")	
				print(a)
				print(b) 
				new_position += 1
				if what_do == 1:
					rpc_spawn_farm(Vector2(a,b))
					level_farm2 += 1
					$New_Generation.value  = level_farm2 					
				elif what_do == 2:
					if now_city == 0:
#						$Sprite.texture = load("res://Assets/builds_new/empire/unit_city.png")														
						now_city = 1
						energy_farm = 1500		
						
					elif level_farm2 < 3:
						rpc_spawn_avanpost_troll(Vector2(a,b))
						level_farm2 += 1
						$New_Generation.value  = level_farm2 					

					else:
						what_do = 0	
						$Level.text = str(what_do)					
				elif what_do == 3:
					rpc_spawn_mobs()# (Vector2(a,b))
					level_farm2 += 1
					$New_Generation.value  = level_farm2 					

				elif what_do == 4:
					rpc_spawn_fortress(Vector2(a,b))															
					level_farm2 += 1
					$New_Generation.value  = level_farm2 					

				SoundPlayer.play(preload("res://audio/sounds/preload_sfx/frost_cast1.wav"))	
			else:
	#	else:
				print ("Farm building after end")
				if what_do == 1:
					rpc_spawn_farm(Vector2(a,b))
					level_farm2 += 1
					$New_Generation.value  = level_farm2 					
				elif what_do == 4 and level_farm2 < 3:
					rpc_spawn_fortress(Vector2(a,b))
					$New_Generation.value  = level_farm2 					
					level_farm2 += 1
				elif what_do == 3:
					rpc_spawn_mobs() #(Vector2(a,b))
					level_farm2 += 1
					$New_Generation.value  = level_farm2 					

				elif what_do == 2 and level_farm2 < 3:
					level_farm2 += 1
					$New_Generation.value  = level_farm2 					

					rpc_spawn_avanpost_troll(Vector2(a,b))															
				SoundPlayer.play(preload("res://audio/sounds/preload_sfx/frost_cast1.wav"))	
				
	#		$Timer.start(12)
func rpc_spawn_village():
#	if build_village == true:
#		wave_spawn += 1	
#	if(get_tree().is_network_server()): 
			var a
			var b
			var x = int(position.x/256) - 1
			var y = int(position.y/256)	- 1
			randomize()
	#		for i in inventory.get_items():
			var x_coord = rand_range(-2, 2) # + self.position.x
			var y_coord = rand_range(-2, 2) # + self.position.y		
		
#		if (resource > 100) and (peasant_count > 4) and (new_position < 10):
##			resource -= 100
#			peasant_count -= 4
			var c = int(new_position/9 - 1)			
			if c == 1:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = int(x_coord *4 + x)  * 256
				b = int(y - 1 - y_coord *2) * 256
				spawn_village(Vector2(a,b))
				level_farm2 += 1	
			if c == 2:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = int(x - 2 - x_coord *2)  * 256
				b = int(y_coord *2 + y)  * 256
				spawn_village(Vector2(a,b))
				level_farm2 += 1	
			if c == 3:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = int(x_coord *2 + x) * 256
				b = int(y_coord *2 + y + 4)  * 256
				spawn_village(Vector2(a,b))
				level_farm2 += 1	
			if c == 4:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = int(x_coord *2 + x + 2)  * 256
				b = int(y_coord *2 + y + 4)  * 256
				spawn_village(Vector2(a,b))
				level_farm2 += 1	
			if c == 6:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = int(x_coord *2 + x + 2)  * 256
				b = int(y_coord *2 + y + 3)  * 256
				spawn_village(Vector2(a,b))
#				print("village building end now")
				level_farm2 += 1								
			if c == 5:
#				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x_coord *4 + x) * 256
				b = (y_coord *4 + y)  * 256
#				new_position += 1
				SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
				level_farm2 += 1
				rpc_spawn_capital(Vector2(a,b))
#				$SpawnTimer.start(spawn_time)								
#				return				
#			a = (x + new_position - 1)  * 256
#			print ("Village position")	
#			print(a)
			
#			b = (y + new_position + 1 )  * 256
#			print(b) 

#			wave_spawn += 1
#			rpc_spawn_farm(Vector2(a,b))
#		else:
#			print("Need 100 resource")

		
func die1():
	Global_DataParser.build_avanpost_dark -= 1	
	$Timer.stop()
	$TimerLife.stop()
	$SpawnTimer.stop()
	rpc_destroy_self()	
	get_parent().remove_child(self)
	queue_free()		
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = self.position.x
	_new_data["positionY"] = self.position.y		
	_new_data["whoiam"] ="res://Scenes/Build/DarkAvanpost.tscn"
	_new_data["nickname"] ="DarkAvanpost"
	_new_data["new_position"] = new_position
	_new_data["resource"] = resource
	_new_data["peasant_count"] = peasant_count
	return _new_data
func set_data(_new_data):
	set_data_all(_new_data)
	new_position = _new_data["new_position"]
	resource = 	_new_data["resource"]
	peasant_count = _new_data["peasant_count"]
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
	


func _on_TimerLife_timeout():
		die1()


func _on_SpawnTimer_timeout():
	if hp > 50:
#	if spawn == true:
#		if(already_build == false):			
#			spawn_all_farm()
#			spawn = false
#			already_build = true
#	resource += res_add
#	res_add *= 2
#	peasant_count += 1
#	wave_spawn += 1
		if 	resource < 10001:
			resource += peasant_count
	#		res_add += peasant_count
		if 	peasant_count < 16:
			peasant_count += 1
		wave_spawn += 1		
		$Resource.text = str(resource)
	#	$Level.text = str(wave_spawn)
		$Year.text = str(wave_spawn)
		$People.text = str(peasant_count)
		$Generation.text = str(level_farm2)
	#	$SpawnTimer.start(spawn_time)

		_on_WhatTimer_timeout()
	elif peasant_count > 2:
		hp += 1
func _on_WhatTimer_timeout():
	if get_tree().is_network_server() and hp > 50:
		if what_do > 0 and can_spawn > 0:
			can_spawn -= 1
			$SpawnTime.text = str(int(can_spawn*spawn_time2))		
			return
		if what_do > 0 and can_spawn == 0:				
			can_spawn = can_spawn2
			$SpawnTime.text = str(int(can_spawn*spawn_time2))			
			can_spawn2 += 1
			if resource > 100 and (peasant_count > 8) and level_farm2 < 3:
				resource -= 100
				peasant_count -= 4
	#			if(already_build == false):			
	#				spawn = false
	#				already_build = true
				spawn_all_farm()						
	#	$WhatTimer.start(spawn_time)	
			elif what_do == 1 and resource > 300 and (peasant_count > 16) and level_farm2 == 3:
					resource -= 300
					peasant_count -= 13
					var x = int(position.x/256) - 1
					var y = int(position.y/256)	- 1
					randomize()
			#		for i in inventory.get_items():
					var x_coord = rand_range(-2, 2) # + self.position.x
					var y_coord = rand_range(-2, 2) # + self.position.y		

					var a = (x_coord *2 + x) * 256
					var b = (y_coord *2 + y)  * 256
	#				new_position += 1
					SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
					level_farm2 += 1

					rpc_spawn_castle(Vector2(a,b))

			elif what_do == 1 and resource >300 and (peasant_count > 16) and level_farm2 == 4:
					resource -= 300
					peasant_count -= 8
					var x = int(position.x/256) - 1
					var y = int(position.y/256)	- 1
					randomize()
			#		for i in inventory.get_items():
					var x_coord = rand_range(-2, 2) # + self.position.x
					var y_coord = rand_range(-2, 2) # + self.position.y		

					var a = (x_coord *2 + x) * 256
					var b = (y_coord *2 + y)  * 256
	#				new_position += 1
					SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
					level_farm2 += 1
#					$Sprite.texture = load("res://Assets/builds_new/empire/unit_city.png")														
					now_city = 3 #теперь это город
#					name_farm = "Town"
					energy_farm = 5000		
#					$Owner.text = founder + ":" + name_farm #str(self.name)
					what_do = 0	#прекращаем увеличение населения и расширение поселений 						
					rpc_spawn_fortress(Vector2(a,b))
					$Level.text = str(what_do)				
#					print("Farm now village================================================")
		elif what_do == 0 and resource > 150 and (peasant_count > 16) and now_city < 2:
					resource -= 150
	#				peasant_count -= 8
	#				var x = int(position.x/256) - 1
	#				var y = int(position.y/256)	- 1
	#				randomize()
			#		for i in inventory.get_items():
	#				var x_coord = rand_range(-2, 2) # + self.position.x
	#				var y_coord = rand_range(-2, 2) # + self.position.y		

	#				var a = (x_coord *2 + x) * 256
	#				var b = (y_coord *2 + y)  * 256
	#				new_position += 1
					SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
					level_farm2 += 1
#					$Sprite.texture = load("res://Assets/builds_new/empire/unit_castle_village.png")														
					now_city = 2 #теперь это посёлок
#					name_farm = "Village"
					energy_farm = 2500						
#					$Owner.text = founder + ":" + name_farm #str(self.name)

		$WhatTimer.stop()
	#	if level_farm2 < 5:	 #
	#		spawn_time2 = spawn_time2 + 12
	#		$WhatTimer.start(spawn_time2)


func _on_TimerBegin_timeout():
	$SpriteBegin.visible = false
