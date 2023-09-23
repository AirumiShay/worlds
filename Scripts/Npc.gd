extends Area2D

const MAX_CARRY_WEIGHT:float = 42.00 # maximum player carry weight with no items
const MAX_MOVE_SPEED_BY_FOOT:float = 30.00 # maximum player move speed with no items

export (int) var max_move_speed = 25 # km/h
export (int) var max_health = 100 # max health points by percentage for simplicity
export (int) var max_weight = 43 # max weight for human without any bag is roughly 30 kilos

var move_speed:int = max_move_speed
var speed_multiplier:float = 1 # if player has food move at normal speed
var health:float = max_health
var water:float = 0.00
var food:float = 0.00
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

var damage_health = 0
var town

func _ready():
	set_process(true)
	set_process_input(true)
	
	if(!is_network_master()):
		print("This is Client")
		for child in get_children():
			if child.has_method('hide'):
				child.hide()
#		$Health.visible = true
#		$Sprite.visible = true
#		$NicknameLabel.visible = true
	else:
		print("This is Server")

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
			if Input.is_action_pressed('teleport'):
				print("pressed die")
				position = Vector2(0.0,0.0)
				rset_unreliable('slave_position', position)
			if Input.is_action_pressed('die'):
				print("pressed die")
				position = Vector2(-22370.0,740.0)
				rset_unreliable('slave_position', position)

#				rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)
#				_die_and_loose_items($NicknameLabel.text, _data_player, $Sprite.global_position)
		
		velocity = velocity.normalized()
	else:
		position = slave_position
	
	rset_unreliable('slave_position', position)
#	rset('slave_movement', velocity)
	
	if get_tree().is_network_server():
		Global_Network.update_position(int(name), position)


func _physics_process(delta):
	if(velocity && speed_multiplier && !is_other_focused):
		move_speed = max_move_speed * speed_multiplier
		position += velocity * delta * (move_speed * 10)
	else:
		move_speed = 0

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
	
	if(weight < max_weight):
		$Stats/WeightLabel.modulate = Color(1, 1, 1)
	else:
		$Stats/WeightLabel.modulate = Color(1, 0, 0)
		speed_multiplier = 0
		show_info("I carry to much and cant move. I need to loose some items!")


	if damage_health > 0: #  уменьшаем здоровье персонажа на величину урона  damage
		print("damage")
		print(damage_health)
		damage_health -= 1
		if damage_health < 0: 
			print("damage < 0")
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
	if(int(water) < int(_inventory.get_water())):
		_inventory.remove_item_amount_by_id(3, 1, _data_player) # 3 is water bottle item id
		_inventory.load_items() # without arguments it reloads player items by default
	
	if(int(food) < int(_inventory.get_food())):
		_inventory.remove_item_amount_by_id(1, 1, _data_player) # 1 is insect food item id
		_inventory.load_items() # without arguments it reloads player items by default
	
	_update_stats()

#	if get_tree().is_network_server():
#		print("update position")
#		Global_Network.update_position(int(name), position)

func init(nickname, start_position, is_slave):
	$NicknameLabel.text = nickname
	_data_player = load_data(nickname, "Player")
	
	position = start_position
	rset_unreliable('slave_position', position)
	
#	if is_slave:
#		$Sprite.texture = load('res://player/character-alt.png')
	if is_network_master():
#		$Camera2D.current = 1
		update_vars()
		$InfoLabel.visible = false
		_map_zoom_out_label.visible = false
		_map_v_slider.visible = false
#		position = Vector2(-22370.0,740.0)
#		rset_unreliable('slave_position', position)


func _update_stats():
	$Stats/HealthCountLabel.text = str(health).pad_decimals(0) + "/" + str(max_health) + " HP"
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
#		rpc("rpc_spawn_bag", nickname, data, die_position)
			rpc_spawn_bag(nickname, data, die_position)
#		rpc("rpc_clear_items", nickname, "Player")
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
		$'/root/Game/'.add_child(bag)
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
		$'/root/Game/'.add_child(town)
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
		$'/root/Game/'.add_child(town)
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
		$'/root/Game/'.add_child(town)
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
		$'/root/Game/'.add_child(town)
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
		$'/root/Game/'.add_child(town)
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
		$'/root/Game/'.add_child(town)
		var bag_url_data = "res://Database//data_temple_" + town.name + ".json"
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
		$'/root/Game/'.add_child(town)
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
		$'/root/Game/'.add_child(town)
		var bag_url_data = "res://Database//data_capital_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)



func _remove_bag_by_area2d(area) -> void:
	area.get_parent().rpc_destroy_self()


func set_is_other_focused(is_focused) -> void:
	is_other_focused = is_focused


func get_is_other_focused() -> bool:
	return is_other_focused


func load_data(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data_village(name, item_list_label)
	
func load_data_shop(name, item_list_label:String = "Village") -> Dictionary:
	return _inventory.load_data(name, item_list_label)



func rpc_clear_items(name, item_list_label:String = "Player") -> void:
	rpc("clear_items", name, item_list_label)


remote func clear_items(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_data_village(name, item_list_label, true)


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
	_update_weight()
	_update_max_weight()
	_update_vehicle_speed()


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
	elif(area.is_in_group("bags")):
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

			print ("get node healt <0")
#
			print(area.get_node("Health").value)
			print($Health.value)
			rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)


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
	
#	$Sprite.show()
	
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
