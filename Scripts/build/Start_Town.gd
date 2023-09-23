#extends "res://Scripts/Stickman.gd"
extends "res://Scripts/Unit/npc_player_control.gd"


onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String
var spawn_position = Vector2(-300.0,-1500.0)
var spawn = false
var spawn_time = 10 #время рождения кобольдов
var life = true # здание пока живёт
var life_time = 30 #	время жизни здания
var npc_god = false

func _ready():
	spawn = true	
	set_process(true)
	set_process_input(false)
	self.hp = 1000
	self.max_hp = 1000
#	$HP_bar.value = self.hp	
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.animal_group)
	$SpawnTimer.start(spawn_time)	
#	$TimerLife.start(life_time)
			
func _process(delta):

	if life == false or self.hp < 0:
#		print("village blue dead")
		set_process(false)		
		die()
		life = true

func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
#		print("prepare spawn Village on position:")
#		print(spawn_position)
		rpc("spawn_mobs", "AngryAnimal", spawn_position) # position)
#		ork_count += 1
#		print("All spawning Kobold in Fortress = ")
#		print (ork_count)
		Global_DataParser.inc_kobold(1)	
#		print(Global_DataParser.get_kobold())
		self.hp -= 10
		$HP_bar.value = self.hp
#		print(self.hp)
		update_hp()	


sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	var town = load('res://Scenes/AngryAnimal.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
	$'/root/Game/Animal'.add_child(town)
#	print("village spawning rpc end")
#	print(town.position)
	town.position = spawn_position
#	print("add item to village")
#	var inventory1 = get_parent().get_player().get_node("Inventory")
		
#		var inventory3 = inventory1.Inventory	
#	_data = inventory1.load_data_village(name, "Village")
#	_data = inventory1.inventory_add_item(1,1,_data)
#	print("load village")
	

func spawn_mobs_local(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if !is_network_master():
		return false
#	print(die_position)
#	print("spawning local stage 1")
	var town = load('res://Scenes/AngryAnimal.tscn').instance()
	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)

	$'/root/Game/Animal'.add_child(town)
#	print("All spawning Local Kobold in Fortress = ")
	town.position = spawn_position
#	ork_count += 1
#	print (ork_count)

sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
	_data = inventory.load_data(name, "Village")
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
	_data = inventory.load_data(_name, "Village")
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
	spawn_mobs_local("AngryAnimal", position)


func _on_SpawnTimer_timeout():
	spawn = false
	rpc_spawn_mobs()


func _on_TimerLife_timeout():
	life = false #здание уничтожается
	
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = self.position.x
	_new_data["positionY"] = self.position.y		
	_new_data["whoiam"] ="res://Scenes/Build/Start_Town.tscn"
	_new_data["nickname"] = "Temple_" + self.name
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
#		die1()
		return false
	return true
	
