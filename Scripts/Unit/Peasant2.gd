extends "res://Scripts/Stickman.gd"
# скрипт для существа  Peasant -  Крестьянин

onready var _url_data:String = ""
#onready var _data:Dictionary = Dictionary()
onready var _inventory = $Inventory


var url_data:String
var INVENTORY_MAX_SLOTS = 100
var stands = false

var destination = Vector2()
var velocity = Vector2()
var prev_pos = Vector2()

var x 

var y
var target = null
var default_speed = 30
var	attack_end = true

var count_attack = 60
var restore_time = 12 #через сколько времени ремонтируем здания
var mine_time = 12  #через сколько времени добываем пищу
#var dead = false
var dead_time = 60 # время существования трупа крестьянина
var life_time = 600 # # время жизни крестьянина
onready var _data:Dictionary  = {"inventory":{}}
# {
#		"inventory":[]
#		} # инвентарь

func _ready():
	dead = false
	speed = default_speed
	self.hp = 100
	self.max_hp = 100
	set_start_hp(self.hp, self.max_hp)
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.empire_group)
	$StandingTimer.start(mine_time)
#	add_bag()
	$TimerDie.start(life_time)
	$Timer.start(restore_time)
	attack_on()
#	attack_on()
#	attack_on()	
	
func add_bag():
	var	bag = load('res://Scenes/Bag.tscn').instance()
	bag.name = "Bag_NPC_" + str(Global_DataParser.rng.randi())
#	print(bag.name) #= nickname
	$Inventory.add_child(bag)
	_data = load_data_bag_player("default")	
	
	
	
func die1():
	Global_DataParser.peasant_count -= 1	
	dead = true	
#	print("Paladin Dead")
	Global_DataParser.dec_mobs(10,1)
	cancel_movement()
	set_process(false)
	$Sprite.texture = load("res://Assets/units/mob/drow_f.png")	
#	die()
	self.hp = 0	
	toggle_hp_bar()	

func _process(delta):
	if dead == false:
		if velocity:
			prev_pos = position
			move_and_slide(velocity)
		wander()
#		search_for_target()
#		$DamagePos.position = position
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
	$StandingTimer.start(3)
	speed = default_speed
	if attack_end == true:
		$Timer.start(2) # переходим в режим атаки на 1сек
		attack_end = false
		attack_on()	

func wander():
	var pos = position
	if stands:
		randomize()
		x = int(rand_range(pos.x - 150, pos.x + 150))
		y = int(rand_range(pos.y - 150, pos.y + 150))
		
#		x = clamp(x, -25500, -22000)
#		y = clamp(y, -1500, 1000)
		
		set_destination(Vector2(x,y))
		
	elif velocity != Vector2():
		if pos.distance_to(destination) <= speed:
			cancel_movement()

		else:

			if pos.distance_to(destination) <= 5:
				cancel_movement()
			
func attack_on():
	if 	dead == false:				
		attack_on1()
		
func attack_on1():
#		var inventory1 = $Inventory  #get_parent().get_parent().get_player().get_node("Inventory")
#		var inventory = get_parent().get_parent().get_player().get_node("Inventory")  #.get_node("Inventory")
		
#		var inventory3 = inventory1.Inventory	
#		_data = load_data(name, "Village")
#		_data = inventory_add_item(1,10,_data)
###	_data = inventory_add_item(4,3,_data)

#		return	
	
#		print("Area for Restore Build create")
		var a = load("res://Scenes/Damage/DamageAreaBuildRestore.tscn").instance()
		var dmg = 500
#		if ($DamagePos.position.x < 80 or $DamagePos.position.y < 80):
#			dmg = 10
#			elif ($DamagePos.position.x < 128 or $DamagePos.position.y < 128):
#				dmg = 5
		a.set_damage(dmg)
		get_parent().add_child(a)
#		a.position = $DamagePos.position #разброс попадания в цель
		a.position = $Sprite.global_position  #position #+ $DamagePos.position
#		print("attaking pressed until atack ")	
		count_attack -= 1
#		if count_attack < 0:
#			die1()

func inventory_add_item(item_id:int, amount:int, data) -> Dictionary:
	var item_data:Dictionary = Global_ItemDatabase.get_item(str(item_id))
	if (item_data.empty()): 
		return Dictionary()
	if (int(item_data["stack_limit"]) <= 1):
		var slot = inventory_get_empty_slot(data)
		if (slot < 0): 
			return Dictionary()
		data.inventory[String(slot)] = {"id": String(item_id), "amount": amount}
		return data

	for slot3 in data:
		if slot3 != "inventory": # or data.inventory: #slot3 == "Inventory":
			for slot4 in data[slot3]:
#				put_item(slot4,amount,item_id)				
				for slot in range (0, INVENTORY_MAX_SLOTS):
					if (int(data[slot3].inventory[String(slot)]["id"]) == int(item_id)):
						if (int(item_data["stack_limit"]) > int(data[slot3].inventory[String(slot)]["amount"])):
							data[slot3].inventory[String(slot)]["amount"] = int(data[slot3].inventory[String(slot)]["amount"] + amount)
							return slot4 #data
				var slot = inventory_get_empty_slot(data)
				if (slot < 0): 
					return Dictionary()
				data[slot3].inventory[String(slot)] = {"id": String(item_id), "amount": amount}
				return data[slot3]

		else:
#			put_item(data,amount,item_id)	
			for slot in range (0, INVENTORY_MAX_SLOTS):
				if (int(data.inventory[String(slot)]["id"]) == int(item_id)):
					if (int(item_data["stack_limit"]) > int(data.inventory[String(slot)]["amount"])):
						data.inventory[String(slot)]["amount"] = int(data.inventory[String(slot)]["amount"] + amount)
						return data

	var slot = inventory_get_empty_slot(data)
	if (slot < 0): 
		return Dictionary()
	data.inventory[String(slot)] = {"id": String(item_id), "amount": amount}
	return data
	for slot3 in data:
		if slot3 != "inventory":
			return data[slot3]
		else:
			return data	
#func put_item(data,amount,item_id):
#	for slot in range (0, INVENTORY_MAX_SLOTS):
#		if (int(data.inventory[String(slot)]["id"]) == int(item_id)):
#			if (int(item_data["stack_limit"]) > int(data.inventory[String(slot)]["amount"])):
#				data.inventory[String(slot)]["amount"] = int(data.inventory[String(slot)]["amount"] + amount)
#				return data
#		
func inventory_get_empty_slot(data) -> int:
	if(data):
		for slot3 in data:
			if slot3 != "inventory": # or data.inventory: #slot3 == "Inventory":
				for slot4 in data[slot3]:
					for slot in range(0, INVENTORY_MAX_SLOTS):
						if (int(data[slot3].inventory[str(slot)]["id"]) == 0): 
							return int(slot)
					print ("Inventory is full!")
					get_parent().show_info("Inventory is full!")
	return -1
			
			
func load_data(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data peasant")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	print(url_data)
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 100}

			elif(int(slot) == 0 && !is_clear_items):
				print("load town")
				dict["inventory"][str(slot)] = {"id": "3", "amount": 7}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 12}


			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
#		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	return data
			
			
			
func _on_StandingTimer_timeout():
	stands = true
#	if 	dead == false:
#		attack_on()

func _on_Timer_timeout():
	attack_end = true
#	attack_on()
	if 	dead == false:	
		$Timer.start(restore_time)


func _on_TimerDie_timeout():
	if dead == false:	
		die1() #смерть персонажа, остается труп
		$TimerDie.start(dead_time) # запускаем таймер для трупа персонажа
	else:
#		rpc_spawn_bag(self.name, _data, $Sprite.global_position)				 
		
#		die() # окончательно удаляем существо
		randomize()
#		for i in inventory.get_items():
		var x_coord = rand_range(-2, 2) * 10 + self.position.x
		var y_coord = rand_range(-2, 2) * 10 + self.position.y
#		add_lying_item(x_coord, y_coord)
		get_parent().remove_child(self)
		queue_free()
#		self.dead = true
		
func rpc_spawn_bag(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_bag", nickname, data, die_position, url_data)
	else:
		spawn_bag(nickname, data, die_position, url_data)	


sync func spawn_bag(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
		var bag = load('res://Scenes/Race/Bag_Mob.tscn').instance()
		bag.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
#		$'/root/Game/'.add_child(bag)
		var b = get_parent().get_parent()
#		b.add_child(bag)
		$'/root/Game/Empire'.add_child(bag)		
		var bag_url_data = "res://Database//data_bag_" + bag.name + ".json"
#		Global_DataParser.write_data(bag_url_data, data)
		Utility.saveDictionary(GlobalData.path + "player_"+ str(bag.name) + "_bag.json", data)		

		bag.init(_inventory, bag.name, data, die_position, bag_url_data)
#		bag.reload_data_by_inventory(_inventory)
func load_data_bag_player(_name):
	var _bag_data = {
		"inventory": []
	}
	_bag_data = Utility.loadDictionary(GlobalData.path +  "player_"+ str(_name) + "_bag.json")
	return	_bag_data	
