#extends Area2D
extends "res://Scripts/Stickman.gd"

const MAX_CARRY_WEIGHT:float = 42.00 # maximum player carry weight with no items
const MAX_MOVE_SPEED_BY_FOOT:float = 30.00 # maximum player move speed with no items

export (int) var max_move_speed = 25 # km/h
export (int) var max_health = 100 # max health points by percentage for simplicity
export (int) var max_mana = 100 # max health points by percentage for simplicity
export (int) var max_level = 10000 # max health points by percentage for simplicity

export (int) var max_weight = 43 # max weight for human without any bag is roughly 30 kilos

var move_speed:int = max_move_speed
var speed_multiplier:float = 1 # if player has food move at normal speed
var health:float = max_health
var water:float = 0.00
var food:float = 0.00
var mana:float = 0.00
var damage_power = 1 #  увеличение урона в зависимости от уровня персонажа
#var expirience = 0
#var level = 0
#var energy = 0
var weight:float = 0.00

var velocity = Vector2()
onready var timer = $InfoTimer

puppet var slave_position = Vector2()
puppet var slave_movement = Vector2(0.0, 0.0)

var is_other_focused = false setget set_is_other_focused, get_is_other_focused

onready var _bag_url:String = $NicknameLabel.text

onready var _inventory = $Inventory
onready var _inventory_button = $InventoryButton
onready var _info_label = $InfoLabel
onready var _map_button = $MapButton
onready var _map_v_slider = $MapVSlider
onready var _map_zoom_out_label = $MapZoomOutLabel
onready var _map_button_position:Vector2 = _map_button.rect_position
onready var _map_v_slider_position:Vector2 = _map_v_slider.rect_position
onready var _map_zoom_out_label_position:Vector2 = _map_zoom_out_label.rect_position
onready var _map_camera_zoom:Vector2 = Vector2(2,2)


var _data_player:Dictionary
#onready var _data_player:Dictionary = Dictionary()

var bag

var	dead_damage = false
#var dead = false
#onready var hp = 100

var damage_health = 0
var town
var enter_towns = false # персонаж внутри поселения?

func _ready():
	set_process(false)
	set_process_input(false)
	return	
	if(!is_network_master()):
		print("This is Client")
		for child in get_children():
			if child.has_method('hide'):
				child.hide()
		$Health.visible = true
		$Sprite.visible = true
		$NicknameLabel.visible = true
	else:
		print("This is Server")
	add_to_group(Global_DataParser.entity_group)
	add_to_group(Global_DataParser.animal_group)
	add_to_group(Global_DataParser.players_group)

func up_power():
	max_health = int(max_health * 1.1)
	health = max_health
	max_mana = int(max_mana * 1.05)
	damage_power  = damage_power * 1.20 # повышаем характеристики персонажа
#	$HP_bar.max_value = max_health	
#	$HP_bar.value = max_health	
	_update_stats()			
	Global_DataParser.set_energy()
	
func _input(event):
	if is_network_master():
		if event is InputEventScreenTouch:
			if event.is_pressed():
				velocity = get_local_mouse_position().normalized()
			else:
				velocity = Vector2(0.0, 0.0)
		elif event is InputEventScreenDrag:
			velocity = get_local_mouse_position().normalized()
		elif event is InputEventKey:
			velocity = Vector2(0.0, 0.0)
			if Input.is_action_pressed('ui_right'):
				velocity.x += 1
			if Input.is_action_pressed('ui_left'):
				velocity.x -= 1
			if Input.is_action_pressed('ui_down'):
				velocity.y += 1
			if Input.is_action_pressed('ui_up'):
				velocity.y -= 1
		velocity = velocity.normalized()
	else:
		position = slave_position
	
	rset_unreliable('slave_position', position)
#	rset('slave_movement', velocity)
	
	if get_tree().is_network_server():
		Global_Network.update_position(int(name), position)
		
func _unhandled_input(event):
	return
#	if event.is_action_pressed("Alt"):
#		print("I pressed Alt")
#		toggle_hp_bar()
#	if Input.is_action_pressed("enter_chat"):
#		print("Enter_to_chat")
#		if $Chat.visible == false:
#			$Chat.visible = true
#		else:
#			$Chat.visible = false	
#					$Chat._on_LineEdit_focus_entered()		
	if Input.is_action_pressed('teleport'):
		print("pressed teleport")
		position = Vector2(0.0,0.0)
		rset_unreliable('slave_position', position)
	if Input.is_action_pressed('teleport1'):
		print("pressed teleport1")
		position = Vector2(-22370.0,740.0)
		rset_unreliable('slave_position', position)
	if Input.is_action_pressed('spell_1'):
		print("pressed attack key 1")
		attack_on(0,1)
	if Input.is_action_pressed('spell_2'):
		print("pressed attack key 2")
		attack_on(1,25)
	if Input.is_action_pressed('spell_3'):
		print("pressed attack key 3")
		attack_on(2,50)

func enter_to_town():
				print("pressed enter_town")
#				attack_on(0,10)
				enter_towns = true
				if(!is_network_master()):
					print("Enter to town")
					for child in get_children():
						if child.has_method('hide'):
							child.hide()
#					$Health.visible = true
					$Sprite.visible = true
					$NicknameLabel.visible = true
					$Camera2D.current = true
					update_vars()
					$InfoLabel.visible = false
					_map_zoom_out_label.visible = false
					_map_v_slider.visible = false

				get_tree().change_scene('res://Scenes/Map/MapLocalMain.tscn')

func attack_on(type,dmg):
	var a
#	var b = 1
	if type == 0:
			dmg = 400 * damage_power
			a = load("res://Scenes/Damage/DamageAreaFire.tscn").instance()
#			b = 1 # наносим урон
			a.set_damage(dmg)
			a.position = position #$DamagePos.разброс попадания в цель
			get_parent().add_child(a)

	if (mana - dmg) >= 0:
		mana -= dmg
		$Mana.value = int(mana)
		dmg *= damage_power

		if type == 1:	
			a = load("res://Scenes/DamageAreaDark.tscn").instance()

		#		print("Attacking area instance")
		elif type == 2:
			a = load("res://Scenes/DamageAreaLight.tscn").instance()
			a.set_heal(dmg)
			a.position = position #$DamagePos.разброс попадания в цель
#			mana -= dmg
			get_parent().add_child(a)
			#лечим своего персонажа тоже
			damage_health = 20

			health += damage_health
			if health >= max_health:
				health = max_health
				$Health.value = health 
				damage_health = 0
			return

		a.set_damage(dmg)
		a.position = position #$DamagePos.разброс попадания в цель
		
		get_parent().add_child(a)
#		print("Attacking area add child")		
#		print("Attacking 1 pressed after atack")

func die():
	print("die player")
	if self.dead == false:
		randomize()
#		for i in inventory.get_items():
		var x_coord = rand_range(-2, 2) * 10 + self.position.x
		var y_coord = rand_range(-2, 2) * 10 + self.position.y
#		add_lying_item(x_coord, y_coord)
		get_parent().remove_child(self)
		queue_free()
		self.dead = true

func update_hp():
	print("player = hp")
	print(hp)
	
	$HP_bar.value = hp

func reduce_hp(val):
	print("player - hp")
	print(hp)
	if self.hp > 0:
		self.hp -= val
	if self.hp > 0:
		update_hp()
	if self.hp <= 0:
		die()
		return false
	return true
func _process1(delta):
	if !is_network_master():
		position = slave_position
		print("slave udpate position")	
		print(slave_position)
		rset_unreliable('slave_position', position)
#	rset('slave_movement', velocity)
	
		if get_tree().is_network_server():
			print(position)
			print("server udpate position")
			Global_Network.update_position(int(name), position)
		
#	if get_tree().is_network_server():
#		print("update position")
#		Global_Network.update_position(int(name), position)
	
func _physics_process1(delta):
	if(velocity && speed_multiplier && !is_other_focused):
		move_speed = max_move_speed * speed_multiplier
		position += velocity * delta * (move_speed * 10)
	else:
		move_speed = 0
	if Global_DataParser.level_up == true:
		_update_level()
		up_power() # повышаем характеристики персонажа
		Global_DataParser.level_up = false
	if Global_DataParser.level_exp == true:
		_update_exp()
		Global_DataParser.level_exp = false		
	if(water > 0):
		water -= delta * 0.002
		$Stats/WaterLabel.modulate = Color(1, 1, 1)
		if(int(health) != int(max_health)):
			health += delta
			$Health.value = int(health)
	else:
		water = 0
		$Stats/WaterLabel.modulate = Color(1, 0, 0)
		health -= delta * 0.01
		show_info("My health is going down. I need some water fast!")
		$Health.value = int(health)
		if($Health.value < 0):
			print("need water 1")
			if dead_damage == true:
				print("need water 2")
				dead_damage = false
				rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)
	
	if(food > 0):
		food -= delta * 0.001
		$Stats/FoodLabel.modulate = Color(1, 1, 1)
		speed_multiplier = 1
	else:
		food = 0
		$Stats/FoodLabel.modulate = Color(1, 0, 0)
		speed_multiplier = 0.5
		show_info("I am moving 2x slower. I need food!")

	if(mana > 0):
		mana -= delta * 0.001
		$Stats/ManaLabel.modulate = Color(1, 1, 1)
#		speed_multiplier = 1
		if(int(mana) != int(max_mana)):
			mana += delta
			$Mana.value = int(mana)
		
	else:
		mana = 0
		$Stats/ManaLabel.modulate = Color(1, 0, 0)
#		speed_multiplier = 0.5
#		mana -= delta * 0.01
		$Mana.value = int(mana)

		show_info("I don't cast spell. I need mana!")
	
	if(weight < max_weight):
		$Stats/WeightLabel.modulate = Color(1, 1, 1)
	else:
		$Stats/WeightLabel.modulate = Color(1, 0, 0)
		speed_multiplier = 0
		show_info("I carry to much and cant move. I need to loose some items!")


	if damage_health > 0: #  уменьшаем здоровье персонажа на величину урона  damage или увеличиваем на величину лечения
		print("damage")
		print(damage_health)
		damage_health -= 1
		if damage_health < 0: 
			print("damage < 0 , Healing +20")
			$Health.value -= damage_health
			health -= damage_health
			damage_health = 0
		if damage_health > 0:	
			print("health - 1")
			health -= 1
			$Health.value -= 1
			print (health)
			if(health <= 0):
				if $Health.value <= 0:
					print("damage 0  health < 0")
					damage_health = 0
					dead_damage = true
					rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)
#	else:
#		print("no damage")
	if enter_towns == false:
		if(int(water) < int(_inventory.get_water())):
			_inventory.remove_item_amount_by_id(3, 1, _data_player) # 3 is water bottle item id
			_inventory.load_items() # without arguments it reloads player items by default
		
		if(int(food) < int(_inventory.get_food())):
			_inventory.remove_item_amount_by_id(1, 1, _data_player) # 1 is insect food item id
			_inventory.load_items() # without arguments it reloads player items by default

		if(int(mana) < int(_inventory.get_mana())):
			_inventory.remove_item_amount_by_id(4, 1, _data_player) # 4 is mana flask item id
			_inventory.load_items() # without arguments it reloads player items by default
	
	_update_stats()

func init(nickname, start_position, is_slave):
	
	
	$NicknameLabel.text = nickname
#устанавливаем расу игрока	
#	if is_network_master():
	if Global_DataParser.join_race == 0:	
		_data_player = load_data_empire(nickname, "Player")
		position = Vector2(-22370.0,740.0)
	elif Global_DataParser.join_race == 1:	
		_data_player = load_data_dark(nickname, "Player")
		position = Vector2(-22000,-1480)
	elif Global_DataParser.join_race == 2:	
		_data_player = load_data_exile(nickname, "Player")
		position = start_position
		rset_unreliable('slave_position', position)
	else:
#		if Global_DataParser.join_race == 3:	
#			_data_player = load_data(nickname, "Player")
#			position = Vector2(-22370,-740)
#			rset_unreliable('slave_position', position)
#		else:
		_data_player = load_data_dark(nickname, "Player")		
	
		position = start_position
		rset_unreliable('slave_position', position)
	
#	if is_slave:
#		$Sprite.texture = load('res://player/character-alt.png')
	if is_network_master():
		$Camera2D.current = true
		update_vars()
		$InfoLabel.visible = false
		_map_zoom_out_label.visible = false
		_map_v_slider.visible = false
#		position = Vector2(-22370.0,740.0)
#		rset_unreliable('slave_position', position)


func _update_stats():
	$Stats/HealthCountLabel.text = str(health).pad_decimals(0) + "/" + str(max_health) + " HP"

	$Stats/ManaCountLabel.text = str(mana).pad_decimals(0) + "/" + str(max_mana) + " MP"

	$Stats/WaterCountLabel.text = str(water).pad_decimals(2) + " l"
	$Stats/FoodCountLabel.text = str(food).pad_decimals(2) + " kCal"
	$Stats/SpeedCountLabel.text = str(move_speed) + " km/h"
	$Stats/WeightCountLabel.text = str(weight).pad_decimals(2) + "/" + str(max_weight) + " kg"


sync func _die_and_loose_items(nickname:String, data:Dictionary, die_position:Vector2):
#	$RespawnTimer.start()
	print(" Die and loose items ")
#	health -= 1
	print(health)
#	$Health.value = health
#	_update_stats()
#	if $Health.value < 0:
	set_physics_process(false)

	if(is_network_master()):
		if dead_damage == true:
			print(" Die Health 2")
#			for child in get_children():
#				if child.has_method('hide'):
			print(" Die hide ")
#					print(child)
#					child.hide()
			print(" Die end hide")
			print(health)
			print($Health.value)# = health
#	if(is_network_master()):
#	if health < 0:
#		if	$Health.value <= 0:
			print(" Die Health 3")
#		return
#		rset("nickname", nickname)
			print(var2str(data))
#			rpc("rpc_spawn_bag", nickname, data, die_position) #NO WORK!!!
			rpc_spawn_bag(nickname, data, die_position) # IT IS WORK!!!
#			rpc("rpc_clear_items", nickname, "Player")
			rpc_clear_items(nickname, "Player")
			show_info("You character have died and lost all items. AAAAAAAAHHH!! *Death*: Now, respawn !!!")
			dead_damage = false
			position = Vector2(-30.0,-200.0)
			rset_unreliable('slave_position', position)
		
	set_physics_process(true)


func rpc_spawn_bag(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_bag", nickname, data, die_position, url_data)
	


sync func spawn_bag(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		bag = load('res://Scenes/Bag.tscn').instance()
		bag.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Bags'.add_child(bag)
		var bag_url_data = "res://Database//data_bag_" + bag.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		bag.init(_inventory, bag.name, data, die_position, bag_url_data)
		bag.reload_data_by_inventory(_inventory)

func rpc_spawn_town(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_town", nickname, data, die_position, url_data)
	


sync func spawn_town(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Town.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/'.add_child(town)
		var bag_url_data = "res://Database//data_town_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_fortress(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_fortress", nickname, data, die_position, url_data)
	


sync func spawn_fortress(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Fortress.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildFortress/'.add_child(town)
		var bag_url_data = "res://Database//data_fortress_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_village(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_village", nickname, data, die_position, url_data)
	


sync func spawn_village(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Village.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildVillage/'.add_child(town)
		var bag_url_data = "res://Database//data_village_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_villageExile(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_villageExile", nickname, data, die_position, url_data)
	


sync func spawn_villageExile(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/VillageExile.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildVillage'.add_child(town)
		var bag_url_data = "res://Database//data_villageexile_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)

func rpc_spawn_magictower(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_magictower", nickname, data, die_position, url_data)
	


sync func spawn_magictower(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/MagicTower.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildMagicTower'.add_child(town)
		var bag_url_data = "res://Database//data_magictower_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_storage(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_storage", nickname, data, die_position, url_data)
	


sync func spawn_storage(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Storage.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildVillage'.add_child(town)
		var bag_url_data = "res://Database//data_storage_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_temple(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_temple", nickname, data, die_position, url_data)
	


sync func spawn_temple(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Temple.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildTemple'.add_child(town)
		var bag_url_data = "res://Database//data_temple_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)

func rpc_spawn_start_town(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_start_town", nickname, data, die_position, url_data)
	


sync func spawn_start_town(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Start_Town.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildTemple'.add_child(town)
		var bag_url_data = "res://Database//data_start_town_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)

func rpc_spawn_castle(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_castle", nickname, data, die_position, url_data)
	


sync func spawn_castle(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Castle.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildCastle'.add_child(town)
		var bag_url_data = "res://Database//data_castle_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_capital(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_capital", nickname, data, die_position, url_data)
	


sync func spawn_capital(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Capital.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildCapital'.add_child(town)
		var bag_url_data = "res://Database//data_capital_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_dark_fortress(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_dark_fortress", nickname, data, die_position, url_data)
	


sync func spawn_dark_fortress(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Fortress.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildFortress'.add_child(town)
		var bag_url_data = "res://Database//data_dark_fortress_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_farm(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_farm", nickname, data, die_position, url_data)
	


sync func spawn_farm(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Farm_blue.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/BuildFarm'.add_child(town)
		var bag_url_data = "res://Database//data_farm_blue_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)



func _remove_bag_by_area2d(area) -> void:
	area.get_parent().rpc_destroy_self()


func set_is_other_focused(is_focused) -> void:
	is_other_focused = is_focused


func get_is_other_focused() -> bool:
	return is_other_focused

func load_data_empire(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data_empire(name, item_list_label)
func load_data_dark(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data_dark(name, item_list_label)
func load_data_exile(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data_exile(name, item_list_label)

func load_data(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data_village(name, item_list_label)
	
func load_data_shop(name, item_list_label:String = "Shop") -> Dictionary:
	return _inventory.load_data(name, item_list_label)

func load_data_capital(name, item_list_label:String = "Capital") -> Dictionary:
	return _inventory.load_data_capital(name, item_list_label)
	
func load_data_castle(name, item_list_label:String = "Castle") -> Dictionary:
	return _inventory.load_data_castle(name, item_list_label)

func load_data_fortress(name, item_list_label:String = "Fortress") -> Dictionary:
	return _inventory.load_data_fortress(name, item_list_label)
	
func load_data_temple(name, item_list_label:String = "Temple") -> Dictionary:
	return _inventory.load_data_builds(name, item_list_label)

func load_data_storage(name, item_list_label:String = "Storage") -> Dictionary:
	return _inventory.load_data_village(name, item_list_label)
	
func load_data_tower(name, item_list_label:String = "Tower") -> Dictionary:
	return _inventory.load_data_town(name, item_list_label)



func rpc_clear_items(name, item_list_label:String = "Player") -> void:
	rpc("clear_items", name, item_list_label)


remote func clear_items(name, item_list_label:String = "Player") -> Dictionary:
#	return _inventory.load_data_village(name, item_list_label, true)
	return _inventory.load_data_dark(name, item_list_label, true)


func show_info(text:String):
	if(_info_label.text == "" && is_network_master() && $Camera2D.zoom == Vector2(1,1)):
		_info_label.text = text
		_info_label.visible = true
		
		timer.connect("timeout",self,"_on_timer_show_info_timeout")
		timer.wait_time = 5
	#	timer.one_shot = true
		timer.start() #to start


func _update_water() -> void:
	water = stepify(float(_inventory.get_water()), 0.01) + 0.01 # adding 0.01 for extra assurance that delta time wont remove 1 int item


func _update_food() -> void:
	food = stepify(float(_inventory.get_food()), 0.01) + 0.01 # adding 0.01 for extra assurance that delta time wont remove 1 int item

func _update_mana() -> void:
	mana = stepify(float(_inventory.get_mana()), 0.01) + 0.01 # adding 0.01 for extra assurance that delta time wont remove 1 int item

func _update_weight() -> void:
	weight = stepify(float(_inventory.get_weight()), 0.01)


func _update_max_weight() -> void:
	max_weight = stepify(float(_inventory.get_max_weight()), 0.01) + MAX_CARRY_WEIGHT


func _update_vehicle_speed() -> void:
	var vehicle_speed:float = _inventory.get_vehicles_min_speed()
	if(int(vehicle_speed) > 0):
		max_move_speed = vehicle_speed
	else:
		max_move_speed = MAX_MOVE_SPEED_BY_FOOT


func update_vars() -> void:
	_update_water()
	_update_food()
	_update_mana()	
	_update_weight()
	_update_max_weight()
	_update_vehicle_speed()
	_update_level()
	_update_exp()
func _update_level():
	$Stats/LevelCountLabel.text = str(Global_DataParser.get_level())	
func _update_exp():
	$Stats/ExpCountLabel.text = str(Global_DataParser.get_expirience())	
func _update_energy():
	$Stats/EnergyCountLabel.text = str(Global_DataParser.get_energy())		
func _on_timer_show_info_timeout():
	$InfoLabel.text = ""
	$InfoLabel.visible = false


func _on_Player_area_entered(area):
	if(area.is_in_group("builds")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data(area.name, "Village")
		_inventory.button_multi.text = "Take"
	if(area.is_in_group("shops")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_shop(area.name, "Shop")
		_inventory.button_multi.text = "Sell"
	if(area.is_in_group("temple")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_temple(area.name, "Temple")
		_inventory.button_multi.text = "Take"
	if(area.is_in_group("tower")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_tower(area.name, "Tower")
		_inventory.button_multi.text = "Take"
	if(area.is_in_group("fortress")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_fortress(area.name, "Fortress")
		_inventory.button_multi.text = "Take"
	if(area.is_in_group("castle")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_castle(area.name, "Castle")
		_inventory.button_multi.text = "Take"
	if(area.is_in_group("capital")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_capital(area.name, "Capital")
		_inventory.button_multi.text = "Take"

	if(area.is_in_group("bags")):
		_inventory_button.modulate = Color(1,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data(area.get_parent().name, "Bag")
		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("players") && area.get_node("Sprite").is_visible_in_tree()):
		print("Fight!")
#		health -= 1
		print("Health -3")
		damage_health = 12
		print(damage_health)
		_send_health(damage_health)		
#		$Health.value = health
#		_update_stats()
#		rset_unreliable('slave_position', position)		
#		if $Health.value < 0:
#			print ("Healt.value <0")
#		if(area.get_node("Stats/HealthCountLabel").text > $Stats/HealthCountLabel.text):
#			rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)
#		if health < 0:
#			print ("healt <0")
#		if(area.get_node("Stats/HealthCountLabel").text > $Stats/HealthCountLabel.text):
		if(area.get_node("Health").value > $Health.value):
			area.get_node("Health").value -= 1
			print ("get node healt <0")
#
			print(area.get_node("Health").value)
			print($Health.value)
			rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)

func _send_health(msg):
	var _health_input = $Health.value
	rpc("receive_health", get_parent().name, $NicknameLabel.text, msg)


sync func receive_health(id, player_name, msg):
	for player in get_tree().get_nodes_in_group("players"):
		if(msg != 0):
#			player.get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += str(player_name) + ": " + msg + "\n"
	#		player.$Health.value -= msg    #get_node("Panel").get_node("RichTextLabel").text += str(player_name) + ": " + msg + "\n"
#			print(player.$Health.value)
			damage_health = msg
			print("NEW HEALTH for player")
			print(id)
			print(player_name)

func _on_Player_area_exited(area):
	_inventory_button.modulate = Color(1,1,1,0.5)
	_inventory.button_multi.text = "Drop"
	_inventory.set_other_visible(false)
	_inventory.set_center_item_visible(false)
	if(area.is_in_group("bags")):
#		if(get_tree().is_network_server()):
#			rset("_inventory",_inventory)
		area.get_parent().reload_data_by_inventory(_inventory)
		var _is_bag_empty:bool = area.get_parent().is_data_empty_by_inventory(_inventory)
		rset("_is_bag_empty", _is_bag_empty)
		if(_is_bag_empty):
			_remove_bag_by_area2d(area)


func _on_InventoryButton_button_down():
	set_is_other_focused(true)
	if(_inventory.is_visible()):
		_inventory_button.modulate = Color(1, 1, 1, 0.5)
		_inventory.visible = false
		set_is_other_focused(false)
	else:
		_inventory_button.modulate = Color(1, 1, 1, 1)
		_inventory.visible = true


func _on_InventoryButton_mouse_entered():
	_inventory_button.modulate = Color(1, 1, 1, 1)


func _on_InventoryButton_mouse_exited():
	if(!_inventory.is_visible()):
		_inventory_button.modulate = Color(1, 1, 1, 0.5)


func _on_MapButton_mouse_entered():
		_map_button.modulate = Color(1, 1, 1, 1)


func _on_MapButton_mouse_exited():
	if($Camera2D.zoom == Vector2(1,1)):
		_map_button.modulate = Color(1, 1, 1, 0.5)


func _on_MapButton_button_down():
	set_is_other_focused(true)
	if($Camera2D.zoom != Vector2(1,1)):
		$Camera2D.zoom = Vector2(1,1)
		set_is_other_focused(false)
		
		for child in get_children():
			if child.has_method('show'):
				child.show()
		
		_map_v_slider.set_scale($Camera2D.zoom)
		_map_v_slider.set_position(_map_v_slider.rect_position)
		
		_map_zoom_out_label.visible = false
		_map_v_slider.visible = false
		_inventory.visible = false
		_map_button.set_scale($Camera2D.zoom)
		_map_button.set_position(_map_button_position)
		_inventory_button.modulate = Color(1, 1, 1, 0.5)
	else:
		_map_zoom(_map_camera_zoom)
		_inventory_button.modulate = Color(1, 1, 1, 1)


func _on_MapVSlider_value_changed(value):
	_map_camera_zoom = Vector2(value, value)
	_map_zoom(_map_camera_zoom)


func _map_zoom(zoom:Vector2 = Vector2(1,1)):
	_map_zoom_out_label.text = "Zoom out: x" + str(zoom.x)
	$Camera2D.zoom = zoom
	_inventory.visible = true
	
	for child in get_children():
		if child.has_method('hide'):
			child.hide()
	
	$Sprite.show()
	
	_map_zoom_out_label.show()
	_map_zoom_out_label.set_scale($Camera2D.zoom)
	_map_zoom_out_label.set_position(_map_zoom_out_label_position * $Camera2D.zoom)
	
	_map_v_slider.show()
	_map_v_slider.set_scale($Camera2D.zoom)
	_map_v_slider.set_position(_map_v_slider_position * $Camera2D.zoom)
	
	_map_button.show()
	_map_button.set_scale($Camera2D.zoom)
	_map_button.set_position(_map_button_position * $Camera2D.zoom)


func _on_MapButton_pressed():
	if($Camera2D.zoom == Vector2(1,1)):
		_map_button.modulate = Color(1, 1, 1, 0.5)
	else:
		_map_button.modulate = Color(1, 1, 1, 1)
