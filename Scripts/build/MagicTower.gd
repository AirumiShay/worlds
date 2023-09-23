#extends "res://Scripts/Stickman.gd"
extends "res://Scripts/Unit/npc_player_control.gd"


onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String
var spawn_position = Vector2(-21000.0,300.0)
var spawn = false
var spawn_time = 30 #время рождения магов огня
var npc_god = false
var location_number = 0
func _ready():
	set_process(false)
	set_process_input(false)
#	speed = default_speed
#	self.dead = false
	self.hp = 2000
	self.max_hp = 2000
#	print("before start hp")
#	print(hp)
	set_start_hp(self.hp, self.max_hp)
#	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
#	print("ready to spawn_mobs")
#	spawn_mobs_local("AngryAnimal", position)
#	print("after spawn")
	$SpawnTimer.start(spawn_time)	
	spawn = true
#	rpc_spawn_mobs()
#	spawn_mobs_local("MagFire", position)
	update_hp()		
	$TimerLife.start(120)	
	Global_DataParser.build_magtower += 1
	$TimerBegin.start(5)
	$SpriteBegin.visible = true
	location_number = Global_DataParser.location_number		
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

func rpc_spawn_mobs(): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		if self.hp > 100:
#		print("prepare spawn")
#		print(position)
			rpc("spawn_mobs", "Mag", position)
	
#		kobold_count += 1
#		print("all spawning MagFire in Temple =")
#		print(kobold_count)


sync func spawn_mobs(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
#	print("spawning stage 1")
#	var town = load('res://Scenes/Race/Paladin.tscn').instance()
#	town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning stage 2")
#	bag.name = nickname
#	$'/root/Game/Animal'.add_child(town)
#	town.position = $Sprite.global_position
	var town1 = load('res://Scenes/Race/Mag.tscn').instance()
	town1.name = nickname + "_" + str(Global_DataParser.rng.randi())
#	print(town.name)
#	print("spawning Mag Fire")
#	bag.name = nickname
	$'/root/Game/Animal'.add_child(town1)
	town1.position = $Sprite.global_position
	Global_DataParser.inc_magfire(1)		
#	var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
#	Global_DataParser.write_data(bag_url_data, data)
#	town.init(_inventory, town.name, data, die_position, bag_url_data)
#	town.reload_data_by_inventory(_inventory)

func spawn_mobs_local(nickname:String, die_position:Vector2): #, url_data:String="") -> void:
	if is_network_master():
		var town = load('res://Scenes/Race/MagFire.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		print(town.position)
#		print("spawning Ork end ")
#		kobold_count += 1


		$'/root/Game/Empire'.add_child(town)
		town.position = die_position
		
#		print("all spawning Local MagFire in Magic Tower =")
		Global_DataParser.inc_magfire(1)	
#		print(Global_DataParser.get_magfire())















sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
	_data = inventory.load_data_town(name, "Tower")
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
	_data = inventory.load_data_town(_name, "Tower")
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
	spawn = false
	spawn_mobs_local("MagFire", position)


func _on_SpawnTimer_timeout():
	spawn = false
	rpc_spawn_mobs()



func _on_TimerLife_timeout():
	print("MagicTower Life End") # Replace with function body.
	rpc_destroy_self()
	get_parent().remove_child(self)
	queue_free()
	
func get_data():
	var  _new_data = get_data_all()
	_new_data["positionX"] = $Sprite.global_position.x
	_new_data["positionY"] = $Sprite.global_position.y		
	_new_data["whoiam"] ="res://Scenes/Build/MagicTower.tscn"
	_new_data["nickname"] ="MagicTower"
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
	


func _on_TimerBegin_timeout():
	$SpriteBegin.visible = false
