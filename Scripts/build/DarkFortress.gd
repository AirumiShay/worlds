extends "res://Scripts/Stickman.gd"



onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String
var spawn_position = Vector2(-21000.0,300.0)
var spawn = false
var spawn_time = 60 #время рождения темных эльфов
var client = 0
var spawn_boss = 300
var spawn_boss_yes = false
func _ready():
	set_process(false)
	set_process_input(false)
#	speed = default_speed
#	self.dead = false
	self.hp = 505
	self.max_hp = 5000
#	print("before start hp")
#	print(hp)
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.animal_group)
	add_to_group(Global_DataParser.build_remove_group)
	add_to_group(Global_DataParser.build_repare_group)	
#	print("ready to spawn_mobs")
#	spawn_mobs_local("AngryAnimal", position)
#	print("after spawn")
#	$SpawnTimer.start(spawn_time)	
#	spawn = true
#	rpc_spawn_mobs()
	if get_tree().is_network_server():		
		$SpawnTimer.start(spawn_time)	
	else:
		client = 1	
#if Global_DataParser.singleplay == true:
	set_spawn_time()
	set_spawn_boss_time()		
	update_hp()		
func set_spawn_boss_time():
	if self.hp > 4750:
		$SpawnBoss.start(spawn_boss)		
		spawn_boss_yes = true
	elif self.hp > 2500:
		$SpawnBoss.start(spawn_boss*4)
		spawn_boss_yes = true			
func set_spawn_time():
	if self.hp > 4750:
		$Timer.start(spawn_time)
		$SpawnBoss.start(spawn_boss)		
	elif self.hp > 2500:
		$Timer.start(spawn_time*2)
		$SpawnBoss.start(spawn_boss*4)		
	elif self.hp > 500:
		$Timer.start(spawn_time*4)
	else:
		$Timer.start(spawn_time*8)					
func rpc_spawn_boss(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
		rpc("spawn_boss", "DarkLeader", position)
#		Global_DataParser.inc_darkelf(1)
sync func spawn_boss(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Race/DarkLeader.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())

	$'/root/Game/Empire'.add_child(town)
	town.position = $Sprite.global_position

	Global_DataParser.inc_darkelf(1)
func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
		rpc("spawn_mobs", "DarkElf", position)
#		Global_DataParser.inc_darkelf(1)
sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
	var town = load('res://Scenes/Race/DarkElf.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())

	$'/root/Game/Dark'.add_child(town)
	town.position = $Sprite.global_position

	Global_DataParser.inc_darkelf(1)
	
func spawn_mobs_local(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if is_network_master():
		var town = load('res://Scenes/Race/DarkElf.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		print(town.position)
#		print("spawning Ork end ")
#		kobold_count += 1


		$'/root/Game/Dark'.add_child(town)
		town.position = die_position
		
		print("all spawning Local Dark Elf in Dark Fortress =")
		Global_DataParser.inc_darkelf(1)	
#		print(Global_DataParser.get_paladin())
		town = load('res://Scenes/Race/Ghost.tscn').instance()
		town.name = "Ghost" + "_" + str(Global_DataParser.rng.randi())
#		print(town.position)
#		print("spawning Ork end ")
#		kobold_count += 1
		Global_DataParser.inc_mobs(6,1)

		$'/root/Game/Dark'.add_child(town)
		town.position = die_position
		
#		print("all spawning Local Ghost in Dark Fortress =")
		Global_DataParser.inc_darkelf(1)	
#		print(Global_DataParser.get_paladin())



sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
	_name = name
	_url_data = url_data
	_data = inventory.load_data_fortress(name, "Fortress")
	position = spawn_position

func reload_data_by_inventory(inventory:Control) -> Dictionary:
	_data = inventory.load_data_fortress(_name, "Fortress")
	return _data


func is_data_empty_by_inventory(inventory:Control) -> bool:
	return inventory.is_inventory_empty_by_data(_data)


func rpc_destroy_self():
	rpc("destroy_self")


sync func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
	Global_DataParser.delete_file(_url_data)
	die()
	
func _on_Timer_timeout():
	spawn = false
	if Global_DataParser.singleplay == true:
		spawn_mobs_local("DarkElf", position)
		$Timer.start(spawn_time)

func reduce_hp(val):
	if self.hp > 0:
		self.hp -= val
#		print("Healt -= %s" % val)
#		print(hp)
	if self.hp > 0:
		update_hp()
		if	spawn_boss_yes == false:
			set_spawn_boss_time()			
	if self.hp <= 0:
		die()
		return false
	return true
	
func _on_SpawnTimer_timeout():
	spawn = false
#	print("Farm blue spawn Ork rpc")	
#	rpc_spawn_mobs()
#	if get_tree().is_network_server():		
	set_spawn_time()		
	rpc_spawn_mobs()

#func _on_SpawnTimer_timeout():
#	spawn = false
#	$SpawnTimer.start(spawn_time)	
#	rpc_spawn_mobs()
#	if client == false:
#		print("dark elf local")
#	spawn_mobs_local("DarkElf", position)		


func _on_SpawnBoss_timeout():
	rpc_spawn_boss()
	set_spawn_boss_time()		
