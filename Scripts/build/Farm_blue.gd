#extends "res://Scripts/Stickman.gd"
extends "res://Scripts/Unit/npc_player_control.gd"


#onready var inventory = get_parent().get_player().$Inventory
onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String
var spawn_position = Vector2(-21000.0,300.0)
var spawn = false
var spawn_time = 10 #время рождения орков
var client = 0
var npc_god = false

func _ready():
	set_process(false)
	set_process_input(false)
#	speed = default_speed
#	self.dead = false
	self.hp = 500
	self.max_hp = 500
#	print("before start hp")
#	print(hp)
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.neutral_group)
	add_to_group(Global_DataParser.build_remove_group)
	add_to_group(Global_DataParser.builds_group)	
#	print("ready to spawn_mobs")
#	spawn_mobs_local("AngryAnimal", position)
#	print("after spawn")
#	$SpawnTimer.start(spawn_time)	
	spawn = true
#	rpc_spawn_mobs()
	if !get_tree().is_network_server():		
		client = 1 # это экземпляр программы запущен как клиент
	update_hp()		
	$SpawnTimer.start(spawn_time)		
	rpc_spawn_mobs()		
func _process(delta):
#	rpc("destroy_self")
#	if spawn == false:
#		spawn == true
	
	if hp > 0:
#		print(hp)
		hp -= 10	
		$HP_bar.value = hp

		if hp < 0:
			rpc("destroy_self")	# уничтожаем это поселение
	else:
		print ("village destroyed!!!")	
#		print (hp)			

#		print("spawn_mobs")
#		rpc_spawn_mobs()

func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if get_tree().is_network_server():
		var object_path ='res://Scenes/Race/Zombi_low.tscn'
		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,self.position,"Zombi",Global_DataParser.join_race,Global_DataParser.location_number)

#	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
#		rpc("spawn_mobs", "Zombie", position)
	
#		kobold_count += 1
#		print("all spawning Ork in Farm =")
#		print(kobold_count)


sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
#	var town = load('res://Scenes/AngryAnimal.tscn').instance()
	var	town = load('res://Scenes/Race/Zombi.tscn').instance()	
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning stage 2")
#	bag.name = nickname
	$'/root/Game/Neutral'.add_child(town)
	town.position = $Sprite.global_position	
#	var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
#	Global_DataParser.write_data(bag_url_data, data)
#	town.init(_inventory, town.name, data, die_position, bag_url_data)
#	town.reload_data_by_inventory(_inventory)
	Global_DataParser.inc_ork(1)	
func spawn_mobs_local(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if is_network_master():
		var town = load('res://Scenes/Race/Ork.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		print(town.position)
#		print("spawning Ork end ")
#		kobold_count += 1


		$'/root/Game/Ork'.add_child(town)
		town.position = die_position
		
#		print("all spawning Local Ork in farm blue =")
		Global_DataParser.inc_ork(1)	
#		print(Global_DataParser.get_ork())

		var inventory1 = get_parent().get_parent().get_player().get_node("Inventory")
		
#		var inventory3 = inventory1.Inventory	
#		_data = inventory1.load_data_village(name, "Village")
#		_data = inventory1.inventory_add_item(1,1,_data)
		pass
sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
	_name = name
	_url_data = url_data
	_data = inventory.load_data_village(name, "Village")
	position = spawn_position

func reload_data_by_inventory(inventory:Control) -> Dictionary:
	_data = inventory.load_data_village(_name, "Village")
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

func _on_Timer_timeout():
	spawn = false
	if client == 2: 		
		print("Farm blue spawn Ork Local")
		spawn_mobs_local("AngryAnimal", position)


func _on_SpawnTimer_timeout():
	spawn = false
#	print("Farm blue spawn Ork rpc")	
#	rpc_spawn_mobs()
	if get_tree().is_network_server():		
		$SpawnTimer.start(spawn_time)		
		rpc_spawn_mobs()


func _on_TimerLife_timeout():
	print("Farm Blue Life End") # Replace with function body.
	rpc_destroy_self()
	get_parent().remove_child(self)
	queue_free()
	
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = self.position.x
	_new_data["positionY"] = self.position.y		

	_new_data["nickname"] = self.name
	_new_data["whoiam"] ="res://Scenes/Build/Grimeyard.tscn"	
	print(self.name)
	print(self.name)	
	return _new_data
func set_data(_new_data):
	set_data_all(_new_data)
func reduce_hp(val):
	if self.hp > 0:
		self.hp -= val
#		print("Healt -= %s" % val)
#		print(hp)
	if self.hp > 0:
		update_hp()
	if self.hp <= 0:
		die()
		return false
	return true
	

