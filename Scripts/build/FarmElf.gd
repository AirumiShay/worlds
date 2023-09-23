#extends "res://Scripts/Stickman.gd"
extends "res://Scripts/Unit/npc_player_control.gd"

#Это лесной поселок светлых эльфов
onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
onready var spawn = true
var _name:String
var spawn_position = Vector2(-21000.0,300.0)
#var spawn = true
var spawn_time = 300 #время рождения эльфов лучников и строительства поселков эльфов
var spawn_time2 = 600 #время рождения животных и строительства эльфийских башен
var npc_god = false
var new_position = 0
var already_build = false
var who_spawn = 0
var wave_spawn = -1 #равен количеству лет жизни этого хутораs
var build_village = true
var peasant_count = 0
var energy_farm = 50
var resource = 0 # накоплено ресурсов
var level_farm = 0 # равен количеству лет жизни этого хутора
var res_add = 1
var name_farm = "Farm"
var owner_name = "ELF"
var can_spawn = 0 # если 0 - пришло время строить
var can_spawn2 = 1 #  сколько раз пропустить  перед постройкой
func _ready():
	set_process(false)
	set_process_input(false)
#	wave_spawn = new_position
	self.hp = 100
	self.max_hp = 100

	set_start_hp(self.hp, self.max_hp)
#	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)

	$SpawnTimer.start(spawn_time)	
	$Level.text = str(wave_spawn)
	$Owner.text = owner_name
	rpc_spawn_mobs()
	update_hp()
	$New_Generation.value  = new_position 
	$Timer.start(spawn_time2)
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
func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
#	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
		rpc("spawn_mobs", "Elf_Ranger", position)
	
#		kobold_count += 1
#		print("all spawning Paladin in Temple =")
#		print(kobold_count)


sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Race/Elf_Ranger.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning from Farm Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = $Sprite.global_position
	print(self.position)
	Global_DataParser.inc_mobs(13,1)
	peasant_count += 1		
#	return
	var town1 = load('res://Scenes/Nature/Grass2.tscn').instance()
	town1.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning grass 2")
#	bag.name = nickname
	$'/root/Game/Empire/Grass'.add_child(town1)
	town1.position = $Sprite.global_position - Vector2(256,256)#die_position
#	Global_DataParser.inc_mobs(7,1)		
#	var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
#	Global_DataParser.write_data(bag_url_data, data)
#	town.init(_inventory, town.name, data, die_position, bag_url_data)
#	town.reload_data_by_inventory(_inventory)
func rpc_spawn_farm(posXY): 
	spawn_farm("FarmElf",posXY)
sync func spawn_farm(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/FarmElf.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning from Farm Elf Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
	print(die_position)	
	town.set_New_Generation(int(new_position),Global_DataParser._player_name, die_position)
	print(int(new_position))
	Global_DataParser.build_farm += 1	
	return
func rpc_spawn_village1():
#	if(get_tree().is_network_server()): 
		var a
		var b
		var x = int(position.x/256) - 1
		var y = int(position.y/256)	- 1
		if new_position < 9:
			if new_position == 1:
				a = x  * 256
				b = (y - 1) * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 2:
				a = (x - 2)  * 256
				b = y  * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 3:
				a = (x) * 256
				b = (y + 4)  * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 4:
				a = (x + 2)  * 256
				b = (y + 4)  * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 6:
				a = (x)  * 256
				b = (y + 3)  * 256
				spawn_village("Village",Vector2(a,b))
				print("village building end now")								
			if new_position == 5:
				a = x * 256
				b = (y)  * 256
#				new_position += 1
				rpc_spawn_castle(Vector2(a,b))
#				$SpawnTimer.start(spawn_time)								
#				return				
#			a = (x + new_position - 1)  * 256
			print ("Village position")	
			print(a)
			
#			b = (y + new_position + 1 )  * 256
			print(b) 
			new_position += 1
#			rpc_spawn_farm(Vector2(a,b))
	

			
sync func spawn_village(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/TowerElf.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning Village Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
	print(die_position)	
	town.set_New_Generation(int(new_position))
	print(int(new_position))
	Global_DataParser.build_village += 1	
	return
func rpc_spawn_temple(posXY): 
	spawn_temple("Temple",posXY)		
sync func spawn_temple(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/Temple_old.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning Temple Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
	print(die_position)	
#	town.set_New_Generation(int(new_position))
	print(int(new_position))
	Global_DataParser.build_temple += 1
	return
func rpc_spawn_castle(posXY): 
	spawn_castle("Temple",posXY)		
sync func spawn_castle(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Build/CapitalElf.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
	print("spawning Castle Empire")
#	bag.name = nickname

	$'/root/Game/Empire'.add_child(town)
	town.position = die_position
	print(die_position)	
#	town.set_New_Generation(int(new_position))
	print(int(new_position))
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
	owner_name = owner + ":" + str(self.name)
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
#	spawn = false
	if 	resource < 10001:
		resource += res_add
		res_add *= 2
	if 	peasant_count < 25:
		peasant_count += 1
	wave_spawn += 5	
	$Resource.text = str(resource)
	$Level.text = str(wave_spawn)
	$People.text = str(peasant_count)
	Global_DataParser.add_energy(energy_farm)		
	if who_spawn == 0:
		who_spawn += 1
		if build_village == true:
			build_village = false
			if new_position ==0:
				spawn_mobs_local1("Sheep", position)
				Global_DataParser.animal_count += 1		
			elif new_position == 1:
				spawn_mobs_local("Pig", position)			

				Global_DataParser.animal_count += 1			
			elif new_position == 2:
				spawn_mobs_local2("Cow", position)
				Global_DataParser.animal_count += 1	
			elif new_position == 3:
				spawn_mobs_local3("Horse", position)
				Global_DataParser.animal_count += 1	
			elif new_position == 4:
				spawn_mobs_local4("Hen", position)
				Global_DataParser.animal_count += 1	
		#	elif new_position == 5 and build_village: # and get_tree().is_network_server():
		#		rpc_spawn_village()		
			elif new_position == 5:
				spawn_mobs_local5("Dog", position)
				Global_DataParser.animal_count += 1
			elif new_position == 6:			
	#			rpc_spawn_mobs()			
				spawn_mobs_local5("Hen", position)
				Global_DataParser.animal_count += 1			

			elif new_position == 7:			
				spawn_mobs_local1("Sheep", position)
				Global_DataParser.animal_count += 1			
#	if (who_spawn == 7) and (build_village == true):
	else:
		if who_spawn < 8:
#		if build_village == true:			
			who_spawn += 1
			if who_spawn == 7:
				rpc_spawn_village()
				energy_farm = 100		
#				$Sprite.texture = load("res://Assets/builds_new/empire/unit_bld_archery_upg.png")														
#	$Timer.start(spawn_time2)
func _on_SpawnTimer_timeout1():
	if spawn == true:
		if(already_build == false):			
			spawn_all_farm()
			spawn = false
			already_build = true
#	resource += res_add
#	res_add *= 2
#	peasant_count += 1
#	wave_spawn += 1	
	$Resource.text = str(resource)
	$Level.text = str(wave_spawn)
	$People.text = str(peasant_count)
	$Generation.text = str(new_position)	
func spawn_all_farm():	
	if spawn == true:	
		spawn = false

		Global_DataParser.add_energy(energy_farm)		 	
		if(already_build == false): #get_tree().is_network_server() and 
			already_build = true	
			var a
			var b
			var x = int(position.x/256) - 1
			var y = int(position.y/256)	- 1
			randomize()
	#		for i in inventory.get_items():
			var x_coord = rand_range(-2, 3) # + self.position.x
			var y_coord = rand_range(-2, 3) # + self.position.y		
			
			if new_position < 8:
				if new_position == 0: # строим соседний хутор
					a = (x_coord *4 + x + 1)  * 256
					b = (y_coord *4 + y + 1)  * 256
					new_position += 1
					rpc_spawn_farm(Vector2(a,b))
	#				$SpawnTimer.start(spawn_time)							
					SoundPlayer.play(preload("res://audio/sounds/preload_sfx/frost_cast1.wav"))	
	#			if new_position == 1:
	#				a = (x + 2)  * 256
	#				b = (y + 2) * 256
	#				new_position += 1
	#				rpc_spawn_farm(Vector2(a,b))
					return				
				if new_position == 1:
					a = (x_coord *4 + x + 2)  * 256
					b = (y_coord *4 + y + 2)  * 256
				if new_position == 2:
					a = (x_coord *4 + x + 1) * 256
					b = (y_coord *4 + y + 2)  * 256
				if new_position == 3:
					a = (x - 1 - x_coord *4)  * 256
					b = (y_coord *4 + y + 2)  * 256
				if new_position == 4:
					a = (x - 1 - x_coord *4)  * 256
					b = (y_coord *4 + y)  * 256
				if new_position == 5:
					a = (x_coord *4 + x) * 256
					b = (y - 1 - x_coord *4)  * 256
				if new_position == 6:
					a = (x_coord *4 + x + 2)  * 256
					b = (y_coord *4 + y) * 256
				if new_position == 7:
					a = (x_coord + x + 3)  * 256
					b = (y_coord + y + 3) * 256
																																										
				print ("Farm position")	
				print(a)
				print(b) 
				new_position += 1
				rpc_spawn_farm(Vector2(a,b))
				SoundPlayer.play(preload("res://audio/sounds/preload_sfx/frost_cast1.wav"))	

	#	else:
	#		print ("Farm building end")	
	#		$Timer.start(12)
func rpc_spawn_village():
#	if build_village == true:
		wave_spawn += 1	
#	if(get_tree().is_network_server()): 
		var a
		var b
		var x = int(position.x/256) - 1
		var y = int(position.y/256)	- 1
		randomize()
#		for i in inventory.get_items():
		var x_coord = rand_range(-2, 2) # + self.position.x
		var y_coord = rand_range(-2, 2) # + self.position.y		
		
		if new_position < 10:
			if new_position == 1:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x_coord *4 + x)  * 256
				b = (y - 1 - y_coord *2) * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 2:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x - 2 - x_coord *2)  * 256
				b = (y_coord *2 + y)  * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 3:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x_coord *2 + x) * 256
				b = (y_coord *2 + y + 4)  * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 4:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x_coord *2 + x + 2)  * 256
				b = (y_coord *2 + y + 4)  * 256
				spawn_village("Village",Vector2(a,b))
			if new_position == 6:
				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x_coord *2 + x)  * 256
				b = (y_coord *2 + y + 3)  * 256
				spawn_village("Village",Vector2(a,b))
				print("village building end now")								
			if new_position == 5:
#				SoundPlayer.play(preload("res://audio/sounds/click.wav"))

				a = (x_coord *4 + x) * 256
				b = (y_coord *4 + y)  * 256
#				new_position += 1
				SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	

				rpc_spawn_castle(Vector2(a,b))
#				$SpawnTimer.start(spawn_time)								
#				return				
#			a = (x + new_position - 1)  * 256
			print ("Village position")	
			print(a)
			
#			b = (y + new_position + 1 )  * 256
			print(b) 
			new_position += 1
			wave_spawn += 1
#			rpc_spawn_farm(Vector2(a,b))
	

		
func die1():
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
	_new_data["whoiam"] ="res://Scenes/Build/FarmElf.tscn"
	_new_data["nickname"] ="FarmElf"
	_new_data["new_position"] = new_position
	return _new_data
func set_data(_new_data):
	set_data_all(_new_data)
	new_position = _new_data["new_position"]
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
	if can_spawn > 0:
		can_spawn -= 1
#		$SpawnTime.text = str(int(can_spawn*spawn_time2))		
		return
	if can_spawn == 0:				
		can_spawn = can_spawn2
		can_spawn2 *= 2		
		if spawn == true:
			if(already_build == false):			
				spawn_all_farm()
				spawn = false
				already_build = true
#	resource += res_add
#	res_add *= 2
#	peasant_count += 1
#	wave_spawn += 1	
	$Resource.text = str(resource)
	$Level.text = str(wave_spawn)
	$People.text = str(peasant_count)
	$Generation.text = str(new_position)
	$SpawnTimer.start(spawn_time)
