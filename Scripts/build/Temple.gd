#extends "res://Scripts/Stickman.gd"
extends "res://Scripts/Unit/npc_player_control.gd"

#это Храм Империи, в нём живут и обучаются священники-целители
onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String
var spawn_position = Vector2(-21000.0,300.0)
var spawn = false
var spawn_time = 60 #время рождения священников,увеличивается в 2 раза автоматически
var npc_god = false
var paladin_count = 0
var energy_temple = 500
var resource = 0 # накоплено ресурсов
var level_temple = 0
var res_add = 100
var	farm_already = 0
var spawn_time2 = 12 #время получения энергии и ресурсов
var wave_spawn = -0 #равен количеству лет жизни этого храма
func _ready():
	set_process(false)
	set_process_input(false)

	self.hp = 2000
	self.max_hp = 2000

	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.build_remove_group)
	add_to_group(Global_DataParser.build_repare_group)
#	add_to_group(Global_DataParser.builds_group)	
	$SpawnTimer.start(spawn_time2)
	$Spawn2.start(spawn_time)			
	spawn = true
#	rpc_spawn_mobs()
	update_hp()		
	Global_DataParser.build_temple += 1		

func GiveEnergy(res_add):
	resource +=  res_add	
	$Resource.text = str(resource)
func TakeEnergy(level):
	var a = resource 
	var b
	var c = level * 25
	print(a)	
	print("------------------------")

	print("resource")
	print(c)
	print("------------------------")
	b = a - c
	print(b)	
	if b >= 0:
		resource = b
		$Resource.text = str(resource)
		print(b)
		print("resource c:")
		print(c)
		return c
	else:
		resource = 0
		$Resource.text = str(resource)		
		print("resource a:")
		print(a)
		return a
	$Resource.text = str(resource)	
#	return 1		
func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if get_tree().is_network_server():
		var object_path ='res://Scenes/Race/PriestEmpire.tscn'
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)
#	rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)
		if farm_already == 0:
			farm_already = 1
			object_path = 'res://Scenes/Build/FarmEmpire.tscn'

			var x = int($Sprite.global_position.x + 256)
			var y = int($Sprite.global_position.y)
			var spawn_position = Vector2(x,y)
			Global_DataParser.build_farm += 1		

			Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"FarmEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

	Global_DataParser.inc_paladin(1)

sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")

	 
#	var town = load('res://Scenes/Race/PriestEmpire.tscn').instance()
#	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning stage 2")
#	bag.name = nickname

#	$'/root/Game/Empire'.add_child(town)
#	town.position = $Sprite.global_position
	if farm_already == 0:
		farm_already = 1
		var town1 = load('res://Scenes/Build/FarmEmpire.tscn').instance()
		town1.name = "FarmEmpire" + "_" + str(Global_DataParser.rng.randi())
	#	print(town.name)
		print("spawning FarmEmpire")
	#	bag.name = nickname
		$'/root/Game/Empire'.add_child(town1)
		town1.position.x = int($Sprite.global_position.x + 256)
		town1.position.y = int($Sprite.global_position.y)

		Global_DataParser.build_farm += 1		

		var town2 = load('res://Scenes/Build/Grimeyard.tscn').instance()
		town2.name = "Grymeyard" + "_" + str(Global_DataParser.rng.randi())
	#	print(town.name)
		print("spawning grimeyard")
	#	bag.name = nickname
		$'/root/Game/Dark'.add_child(town2)
#		town2.position = int($Sprite.global_position + Vector2(-256, -768))
#		Global_DataParser.build_farm += 1		
		town2.position.x = int($Sprite.global_position.x - 256)
		town2.position.y = int($Sprite.global_position.y - 768)

		town2.set_target($Sprite.global_position)
		print("Grymeyard")
		print(die_position + Vector2(-512, -512))
		var	town3 = load('res://Scenes/Race/Zombi.tscn').instance()	
		town3.name = "Zombi" + "_" + str(Global_DataParser.rng.randi())
	#	print(town.name)
	#	print("spawning Ghost in Grimeyard")
	#	bag.name = nickname
		$'/root/Game/Empire'.add_child(town3)
#		town3.position = int($Sprite.global_position + Vector2(-256, -704)) #$Sprite.global_position
		town3.position.x = int($Sprite.global_position.x - 256)
		town3.position.y = int($Sprite.global_position.y - 768)

		town3.set_target($Sprite.global_position)		
	#	var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
	#	Global_DataParser.write_data(bag_url_data, data)
	#	town.init(_inventory, town.name, data, die_position, bag_url_data)
	#	town.reload_data_by_inventory(_inventory)
		Global_DataParser.inc_mobs(9,1)			
func spawn_mobs_local(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if is_network_master():
		var town = load('res://Scenes/Race/Paladin.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		print(town.position)
#		print("spawning Ork end ")
#		kobold_count += 1


		$'/root/Game/Paladin'.add_child(town)
		town.position = die_position
		
#		print("all spawning Local Paladin in Temple =")
		Global_DataParser.inc_mobs(7,1)	


sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
	_data = inventory.load_data(name, "Temple")
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
	return 1
#	rpc("destroy_self")


sync func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
	Global_DataParser.delete_file(_url_data)


func _on_Timer_timeout():
	spawn = false
	spawn_mobs_local("AngryAnimal", position)

func get_resource():
	return resource
func _on_SpawnTimer_timeout():
	if hp <= 0:
		rpc("destroy_self")	# уничтожаем это поселение
		return		
	spawn = false
	if 	hp > 400 and resource < 5000001:	
		resource += res_add
#		SoundPlayer.play(preload("res://audio/sounds/click.wav"))
		wave_spawn += 1
	elif paladin_count > 0:
		hp += 1
		
	$Year.text = str(wave_spawn)
	 
	$Resource.text = str(resource)
	Global_DataParser.add_energy(energy_temple)
	if paladin_count == 10:
		level_temple += 1
		$Level.text = str(level_temple)
		res_add *= 2
		energy_temple = 2000
		$Sprite.texture = load("res://Assets/builds_new/empire/unit_bld_church.png")	
	if paladin_count == 25:
		level_temple += 1		
		res_add *= 2
		$Level.text = str(level_temple)			
		energy_temple = 5000
		$Sprite.texture = load("res://Assets/builds_new/empire/unit_bld_church_cathedral.png")	
	if paladin_count == 75:
		level_temple += 1		
		res_add *= 2
		$Level.text = str(level_temple)			
		energy_temple = 10000
	if paladin_count == 150:
		level_temple += 1		
		res_add *= 2
		$Level.text = str(level_temple)			
		energy_temple = 20000		
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = self.position.x
	_new_data["positionY"] = self.position.y		
	_new_data["whoiam"] ="res://Scenes/Build/Temple_old.tscn"
	_new_data["nickname"] ="Temple"
	_new_data["resource"] = resource
	_new_data["energy_temple"] = energy_temple
	_new_data["paladin_count"] = paladin_count		
	return _new_data
func set_data(_new_data):
	set_data_all(_new_data)
	resource = _new_data["resource"] 
	energy_temple = _new_data["energy_temple"] 
	paladin_count = _new_data["paladin_count"] 	
func reduce_hp(val):
	if self.hp > 0:
		self.hp -= val
#		print("Healt -= %s" % val)
#		print(hp)
	if self.hp > 0:
		update_hp()
	if self.hp <= 0:
#		die1()
		return false
	return true
	


func _on_Spawn2_timeout():
	if hp > 400:	
		spawn_time *= spawn_time
		rpc_spawn_mobs()
		paladin_count += 1
		$Paladins.text = str(paladin_count)
	#	SoundPlayer.play(preload("res://audio/sounds/click.wav"))
	elif paladin_count > 1:
		hp += 1
