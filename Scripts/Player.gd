extends Area2D

const MAX_CARRY_WEIGHT:float = 90.00 # maximum player carry weight with no items
const MAX_MOVE_SPEED_BY_FOOT:float = 30.00 # maximum player move speed with no items

export (int) var max_move_speed = 25 # km/h
export (int) var max_health = 100 # max health points by percentage for simplicity
export (int) var max_mana = 100 # max health points by percentage for simplicity
export (int) var max_level = 10000 # max health points by percentage for simplicity

export (int) var max_weight = 67 # max weight for human without any bag is roughly 30 kilos

var move_speed:int = max_move_speed
var speed_multiplier:float = 1 # if player has food move at normal speed
var health:float = max_health
var water:float = 0.00
var food:float = 0.00
var mana:float = 100.00
var damage_power = 1 #  увеличение урона в зависимости от уровня персонажа
#var expirience = 0
#var level = 0
#var energy = 0
var hardcore_level = 0 #  уровент сложности игры 0(обучение)...7(максимальная сложность)
var weight:float = 0.00
var world_now_load = false
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
onready var area_type = 0 #игрок не в зоне поселений/мешков с вещами
onready var area_type_id #ссылка на область с обьектами, куда вошел игрок
var build_area_type_id	
	
var _data_player:Dictionary


var bag
var last_build_id = 0
var	dead_damage = false
var dead = false
onready var hp = 100

var damage_health = 0 # на сколько уменьшать здоровье персонажа
var damage_mana = 0   # на сколько уменьшать ману персонажа
var town
var enter_towns = true # персонаж внутри поселения?
var player_return = true #уже вернули управление персонажем ?
var location_number # номер локации, где персонаж игрока

func _ready():
	set_process(true)
	set_process_input(true)
	Global_DataParser.hardlevel = hardcore_level	
	if(!is_network_master()):
		print("This char is Other player")
		for child in get_children():
			if child.has_method('hide'):
				child.hide()
#		$Health.visible = true
		$Sprite.visible = true
		$NicknameLabel.visible = true

	else:
		print("This char is My char")
		if !get_tree().is_network_server():
			print("load data world server skiped")
#			rpc("load_data_world_server")			
	add_to_group(Global_DataParser.entity_group)
#	add_to_group(Global_DataParser.animal_group)
	add_to_group(Global_DataParser.players_group)
	if Global_DataParser.join_race == 0: 
				get_parent().get_node("Empire").visible = true
	if Global_DataParser.join_race == 1:				
				get_parent().get_node("Dark").visible = true
	if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:			
				get_parent().get_node("Neutral").visible = true
				get_parent().get_node("Animal").visible = true
func up_power():
	max_health = int(max_health * 1.1)
	health = max_health
	max_mana = int(max_mana * 1.05)
	damage_power  = damage_power * 1.20 # повышаем характеристики персонажа
#	$HP_bar.max_value = max_health	
#	$HP_bar.value = max_health	
#	Global_DataParser.set_energy()
	_update_stats()			
	
func _input(event):
	if is_network_master():
		if Global_DataParser.player_control == false:
			if player_return == false:
#			$Camera2D.current = true
				player_return = true
				player_show()
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
				if Input.is_action_pressed("enter_to"):	
#					if area_type != 0:
					if area_type_id != null:					
						if area_type_id.get_parent().has_method('toggle_player_control'):
							player_hide()
							velocity = Vector2(0.0, 0.0)								
							player_return = false
							area_type_id.get_parent().toggle_player_control()
							return
			velocity = velocity.normalized()
			
			if !get_is_other_focused():
				
				if Input.is_action_pressed('spell_1'):
					print("pressed attack key 1")
					attack_on(1,25)
				if Input.is_action_pressed('spell_2'):
					print("pressed attack key 2")
					attack_on(2,50)
				if Input.is_action_pressed('spell_3'):
					print("pressed restore build key 3")
					attack5(250)
				if Input.is_action_pressed('spell_4'):
					print("pressed attack Fire key 4")
					attack_on(0,1)					
				if Input.is_action_pressed('spell_5'):
					print("pressed destroy build key 5")
					attack4(250)

				if Input.is_action_pressed('spell_6'):
					print("pressed destroy build key 6")
					attack6(Global_DataParser.join_race)
				if Input.is_action_pressed('spell_7'):
					print("pressed restore build key 7")
					attack7(Global_DataParser.join_race)
				if Input.is_action_pressed('spell_8'):
					print("pressed restore build key 8")
					attack8(Global_DataParser.join_race)
				if Input.is_action_pressed('spell_9'):
					print("pressed attack key 9")
					attack9(Global_DataParser.join_race)
				if Input.is_action_pressed('spell_0'):
					print("pressed restore build key 0")
					attack0(Global_DataParser.join_race)					
				if Input.is_action_pressed('spell_10'):
					print("pressed attack key -")
					attack10(Global_DataParser.join_race)
				if Input.is_action_pressed('spell_11'):
					print("pressed destroy build key =")
					attack11(Global_DataParser.join_race)

#			return
				if event.is_action_pressed("Alt"):

#		print("I pressed Alt")
					print("player Global position")	
					Global_DataParser.player_position1 = position #$Sprite.global_position
	
					print(Global_DataParser.player_position1)			

		if event.is_action_pressed("ui_cancel"):
			if $MidleMenu2.visible == true:
				$MidleMenu.visible = false
#				get_parent().get_node("MidleMenu").visible = false
				$MidleMenu2.visible = false
			else:
#				$Camera2D.zoom = Vector2(1,1)
				$MidleMenu.visible = true
				update_all_count()
#				get_parent().get_node("MidleMenu").visible = true
				$MidleMenu2.visible = true
				player_stats_save1()
		
	else:
		position = slave_position
#	rset_unreliable('slave_position', position)
#	rpc_spawn_player(position)
##	rset('slave_movement', velocity)
	
	if get_tree().is_network_server():
		Global_Network.update_position(int(name), position)
func rpc_spawn_player(posXY):
	if is_network_master():
		rpc("spawn_player_slave", posXY)
	
sync func spawn_player_slave(posXY):
	slave_position = posXY
func _unhandled_input(event):
#	if event.is_action_pressed("alt"):

#		print("I pressed Alt")
#		Global_DataParser.player_position = get_local_mouse_position() #position
#		pass
#		toggle_hp_bar()
#	if Input.is_action_pressed("enter_chat"):
#		print("Enter_to_chat")
#		if $Chat.visible == false:
#			$Chat.visible = true
#		else:
#			$Chat.visible = false	
#					$Chat._on_LineEdit_focus_entered()	
	if is_network_master():
			
		if Input.is_action_pressed('teleport'):
			print("pressed teleport")
	#		player_hide()
			position = Vector2(0.0,0.0) # to neutral lands
	#		player_show()
	#		rset_unreliable('slave_position', position)
		if Input.is_action_pressed('teleport1'):
			print("pressed teleport1")
	#		player_hide()
			position = Vector2(-22370.0,740.0) #to empire
	#		player_show()
#		if Input.is_action_pressed('teleport2'):
#			enter_to_town()
#			teleport_dark() #to dark empire
	#		rset_unreliable('slave_position', position)
	#	if Input.is_action_pressed('spell_1'):
	#		print("pressed attack key 4")
	#		attack_on(0,1)
		if Input.is_action_pressed('teleport3'):			
				teleport_gungeon()
		if Input.is_action_pressed('teleport4'):			
				teleport_exit_dungeon()	
		if Input.is_action_pressed("map_view"):
				call_map()						
func teleport_empire(location):
	teleport_all(location,Vector2(-3000.0,100.0))
func teleport_all(location,go_position):	
	if(is_network_master()):
#		player_hide()
		position = go_position
#		player_show()
		if Global_DataParser.location_number != 1:
			del_location_number("name")
			add_location_empire()
			get_parent().get_node("Empire").visible = true
			get_parent().get_node("Dark").visible = false
			get_parent().get_node("Neutral").visible = false
			get_parent().get_node("Animal").visible = false	
	else:
#		if Global_DataParser.location_number != location:
		player_hide()
#		else:
#			player_show()
func teleport_dark():
	if(is_network_master()):
#		player_hide()
		position = Vector2(-1200.0,-100.0)
#		player_show()
		if Global_DataParser.location_number != 2:
			del_location_number("name")
			add_location_dark_empire()
			get_parent().get_node("Empire").visible = false
			get_parent().get_node("Dark").visible = true
			get_parent().get_node("Neutral").visible = false
			get_parent().get_node("Animal").visible = false			
func teleport_neutral():

#		player_hide()
	if(is_network_master()):
		position = Vector2(0,0)
#		player_show()
		if Global_DataParser.location_number != 3:
			del_location_number("name")
			add_location_neutral_lands()
			get_parent().get_node("Empire").visible = false
			get_parent().get_node("Dark").visible = false
			get_parent().get_node("Neutral").visible = true
			get_parent().get_node("Animal").visible = false
func teleport_gungeon():
	if(is_network_master()):
#		position = Vector2(0,0)		
		if Global_DataParser.location_number != 4:		
			del_location_number("location_name")					
			add_location_dungeon(1)
			get_parent().get_node("Empire").visible = false
			get_parent().get_node("Dark").visible = false
			get_parent().get_node("Neutral").visible = false
			get_parent().get_node("Animal").visible = false		
#		player_hide()
			position = Vector2(18000.0,20000.0)
#		position = area_type_id #Vector2(15000,-10800)
#		player_show()	
func teleport_exit_dungeon():
	if(is_network_master()):
#		player_hide()
		position = Vector2(-325,900)
#		player_show()	
sync func player_hide():
					$Sprite.visible = false
					$NicknameLabel.visible = false
					$Camera2D.current = false
#					update_vars()
					$InfoLabel.visible = false
					_map_zoom_out_label.visible = false
					_map_v_slider.visible = false
					for child in get_children():
						if child.has_method('hide'):
#			print(" Die hide ")
#					print(child)
							child.hide()		
func player_show():
				if(is_network_master()):
					$Sprite.visible = true
					$NicknameLabel.visible = true
					$Camera2D.current = true
					update_vars()
					$InfoLabel.visible = true
					for child in get_children():
						if child.has_method('show'):
#			print(" Die hide ")
#					print(child)
							child.show()						
					_map_zoom_out_label.visible = false
					_map_v_slider.visible = false
					$MidleMenu.visible = false
					if(_inventory.is_visible()):
						_inventory_button.modulate = Color(1, 1, 1, 0.5)
						_inventory.visible = false
						set_is_other_focused(false)					
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
					$Sprite.visible = false
					$NicknameLabel.visible = false
					$Camera2D.current = false
					update_vars()
					$InfoLabel.visible = false
					_map_zoom_out_label.visible = false
					_map_v_slider.visible = false

				get_tree().change_scene('res://Scenes/Map/MapLocalMain.tscn')

func attack_on(type,dmg):
	if is_network_master():
		attack_on1(type,dmg)
func attack_on1(type,dmg):		
	var a
#	var b = 1
	if (type == 0 and Global_DataParser.join_race == 1):
		var energy = Global_DataParser.get_energy()
	#	print (energy)
		if (energy > 100):		
			Global_DataParser.reduce_energy(100)
			dmg = 400 * damage_power
#			add_location_neutral_lands()
#			return
			a = load("res://Scenes/Damage/DamageAreaFire.tscn").instance()
#			b = 1 # наносим урон
			a.set_damage(dmg)

			a.position = position #$DamagePos.разброс попадания в цель
			get_parent().add_child(a)
		else:
			return false
	elif (type == 0 and Global_DataParser.join_race == 0):
			var energy = Global_DataParser.get_energy()		
			if (energy > 10):		
				Global_DataParser.reduce_energy(10)		
				a = load("res://Scenes/Damage/MagFire.tscn").instance()
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
	elif (type == 0 and Global_DataParser.join_race == 2 ):
		var energy = Global_DataParser.get_energy()
	#	print (energy)
		if (energy > 100):		
			Global_DataParser.reduce_energy(100)
#			dmg = 400 * damage_power
			a = load("res://Scenes/Race/PriestExile.tscn").instance()
#			b = 1 # наносим урон
#			a.set_damage(dmg)
			add_npc_on_location(a)
#			$'/root/Game/Neutral'.add_child(a)
			a.position = position #$DamagePos.разброс попадания в цель
#			get_parent().add_child(a)
		else:
			return false
	elif (type == 0 and Global_DataParser.join_race == 3):
		var energy = Global_DataParser.get_energy()
	#	print (energy)
		if (energy > 25):		
			Global_DataParser.reduce_energy(25)
			dmg = 400 * damage_power
#			a = load("res://Scenes/Race/DarkLeader.tscn").instance()
			if get_tree().is_network_server():	 
#				var object_path = "res://Scenes/Build/FarmEmpire.tscn"
				var object_path = "res://Scenes/Dungeon/Mobs/Mobs1.tscn"
				Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"DarkLeader",Global_DataParser.join_race,Global_DataParser.location_number)

#			b = 1 # наносим урон
#			a.set_damage(dmg)
#			add_npc_on_location(a)
#			$'/root/Game/Neutral'.add_child(a)
#			a.position = position #$DamagePos.разброс попадания в цель
#			get_parent().add_child(a)
		else:
			return false			
	if Global_DataParser.energy > 10:
		Global_DataParser.reduce_energy(10)
#	if (mana - dmg) >= 0:
#		mana -= dmg
#		$Mana.value = int(mana)
		dmg *= damage_power

		if type == 1 and Global_DataParser.join_race == 2:	
			a = load("res://Scenes/Damage/DamageAreaDark.tscn").instance()
			a.set_damage(dmg)
			a.position = position #$DamagePos.разброс попадания в цель

			add_npc_on_location(a)
		elif type == 1 and Global_DataParser.join_race == 0:
			attack13(Global_DataParser.join_race)
		elif type == 1 and Global_DataParser.join_race == 1:	
			a = load("res://Scenes/Damage/DamageArea.tscn").instance()			
			a.set_damage(dmg)
			add_npc_on_location(a)
			a.position = position #$DamagePos.разброс попадания в цель
#			print($Sprite.global_position)
#			print(get_global_mouse_position())
#			print(get_local_mouse_position())
#			print(position)
#			print(Position2D)
		elif type == 1 and Global_DataParser.join_race == 3:	
#			a = load("res://Scenes/Race/PriestExile.tscn").instance()			
			a = load("res://Scenes/Damage/DamageArea.tscn").instance()
			a.set_damage(dmg)
			a.position = position #$DamagePos.разброс попадания в цель

			add_npc_on_location(a)
		elif type == 2 and Global_DataParser.join_race !=1:
			a = load("res://Scenes/Damage/DamageAreaLightResurect.tscn").instance()
			a.set_heal(dmg)
			a.position = position #$DamagePos.разброс попадания в цель

			add_npc_on_location(a)
			#лечим своего персонажа тоже
			damage_health = 20 * damage_power

			var health1
			health1 = health
			health1 += damage_health
			if health1 >= max_health:
				health1 = max_health
			health = health1	
			$Health.value = health 
			damage_health = 0
			return
		elif type == 3:
			a = load("res://Scenes/Damage/DamageAreaLight.tscn").instance()
			a.set_heal(dmg)
			a.position = position #$DamagePos.разброс попадания в цель
#			mana -= dmg
			add_npc_on_location(a)
#			get_parent().add_child(a)

func add_npc_on_location(npc):
		if  Global_DataParser.location_number == 1:
			$'/root/Game/Empire'.add_child(npc)
		elif  Global_DataParser.location_number == 2:
			$'/root/Game/Dark'.add_child(npc)
		elif  Global_DataParser.location_number == 3:
			$'/root/Game/Neutral'.add_child(npc)
		else:
			$Chat/Panel/RichTextLabel.text += "Can't do it!!!\n"	
func attack4(dmg):
	if is_network_master() and (Global_DataParser.get_energy() > 1000):		
		Global_DataParser.reduce_energy(1000)
	
		var	a = load("res://Scenes/Damage/DamageAreaRemove.tscn").instance()
		a.set_damage(100 * damage_power)
#		a.position = position #$DamagePos.разброс попадания в цель
#		print("position remove damage")
#		print($Sprite.global_position)
#		print(get_global_mouse_position())
#		print(get_local_mouse_position())
#		print(position)
#		print(Position2D)
#		add_npc_on_location(a)


#		a.new_position = get_global_mouse_position()


		a.new_position = position				
#			mana -= dmg
		get_parent().add_child(a)
#		print("restore build")
#		print("attack damage build")
		return
func attack5(dmg):
		var	a = load("res://Scenes/Damage/DamageAreaBuildRestore.tscn").instance()
		a.set_damage(100 * damage_power)
		a.position = position #$DamagePos.разброс попадания в цель
#			mana -= dmg
		get_parent().add_child(a)
#		print("attack damage build")
		print("restore build")
func attack13(dmg):
	if (Global_DataParser.energy > 1000):		
		Global_DataParser.reduce_energy(1000)
		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
func attack14(dmg):
	if (Global_DataParser.energy > 1000):		
		Global_DataParser.reduce_energy(1000)
		var object_path = "res://Scenes/Damage/Damage_High_NPC.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"DamageHighNPC",Global_DataParser.join_race,Global_DataParser.location_number)
func call_unit(dmg):
	if is_network_master() and (Global_DataParser.energy > 10000):		
		Global_DataParser.reduce_energy(10000)
		var object_path
		var name_unit
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_castle <= 0:
				return			
			object_path = "res://Scenes/Race/Paladin.tscn"
			name_unit = "Paladin"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_avanpost_dark <= 0:
				return				
			object_path = "res://Scenes/Race/DarkElf.tscn"
			name_unit = "DarkElf"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_farm_vampire <= 0:
				return
			object_path = "res://Scenes/Race/Rogue.tscn"
			name_unit = "Rogue"		
#		object_path = "res://Scenes/Race/Rogue.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,name_unit)
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,name_unit,Global_DataParser.join_race,Global_DataParser.location_number)
func attack16(dmg):
	if is_network_master() and (Global_DataParser.energy > 100000):		
		Global_DataParser.reduce_energy(100000)
		var object_path
		var object_name			
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_magtower <= 0:
				return			
			object_path = "res://Scenes/Race/MagFire.tscn"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_fortress_dark < 5:
				return			
			object_path = "res://Scenes/Race/DarkLeader.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_castle_vampire > 0:
				if Global_DataParser.count_elite_vampire < Global_DataParser.build_castle_vampire:
					object_path = "res://Scenes/Race/Vampire_High.tscn"
				else:
					return		
			else:
				return
#		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"Vampire_DarkLeader_MagFire")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Vampire_DarkLeader_MagFire",Global_DataParser.join_race,Global_DataParser.location_number)
func unit1(dmg):
	if is_network_master() and (Global_DataParser.energy > 50000):		
		Global_DataParser.reduce_energy(50000)
		var object_path
		var object_name		
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_village <=0:
				return			
			object_path = 'res://Scenes/Race/Peasant.tscn'
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_avanpost_dark <= 0:
				return			
			object_path = "res://Scenes/Race/OrkLeader.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_farm_vampire <= 0:
				return
			object_path = "res://Scenes/Race/Warlock.tscn"

#		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"Warlock_OrkLeader_Peasant")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Warlock_OrkLeader_Peasant",Global_DataParser.join_race,Global_DataParser.location_number)

func unit4(dmg):
	if is_network_master() and (Global_DataParser.energy > 25000):		
		Global_DataParser.reduce_energy(25000)
		var object_path
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_magtower <= 0:
				return			
			object_path = "res://Scenes/Race/PriestEmpire.tscn"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_fortress_dark <= 0:
				return			
			object_path = "res://Scenes/Race/Ork_Warrior.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_storage <= 0:
				return
			object_path = "res://Scenes/Race/Lich.tscn"

		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"Lich_Ork_Priest")
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Lich_Ork_Priest",Global_DataParser.join_race,Global_DataParser.location_number)
func unit3(dmg):
	if is_network_master() and (Global_DataParser.energy > 1000):		
		Global_DataParser.reduce_energy(1000)
		var object_path
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_farm <= 0:
				return			
			object_path = "res://Scenes/Race/Elf_Ranger.tscn"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_fortress_dark <= 0:
				return			
			object_path = "res://Scenes/AngryAnimal.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_farm_vampire <= 0:
				return
			object_path = "res://Scenes/Race/Skeleton.tscn"

#		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"Skeleton_Elf_Demon")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Skeleton_Elf_Demon",Global_DataParser.join_race,Global_DataParser.location_number)
func unit2(dmg):
	if is_network_master() and (Global_DataParser.energy > 5000):		
		Global_DataParser.reduce_energy(5000)
		var object_path
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_fortress <= 0:
				return			
			object_path = "res://Scenes/Race/Knight.tscn"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_avanpost_dark <= 0:
				return			
			object_path = "res://Scenes/Race/Troll.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_farm_vampire <= 0:
				return
			object_path = "res://Scenes/Race/Zombi.tscn"

#		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"Zombi_Troll_Knight")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Zombi_Troll_Knight",Global_DataParser.join_race,Global_DataParser.location_number)
func unit5(dmg):
	if is_network_master() and (Global_DataParser.energy > 75000):		
		Global_DataParser.reduce_energy(75000)
		var object_path
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_magtower <= 0:
				return			
			object_path = "res://Scenes/Race/MagFire.tscn"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_fortress_dark <= 0:
				return			
			object_path = "res://Scenes/Race/DarkLeader.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_castle_vampire <=0:
				return
			object_path = "res://Scenes/Race/PriestExile.tscn"

#		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"PriestExile_DarkLeader_MagFire")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"PriestExile_DarkLeader_MagFire",Global_DataParser.join_race,Global_DataParser.location_number)
func unit6(dmg):
	if is_network_master() and (Global_DataParser.energy > 100000):		
		Global_DataParser.reduce_energy(100000)
		var object_path
		if Global_DataParser.join_race == 0:
			if Global_DataParser.build_magtower <= 0:
				return			
			object_path = "res://Scenes/Race/MagFire.tscn"
		if Global_DataParser.join_race == 1:
			if Global_DataParser.build_fortress_dark <= 0:
				return			
			object_path = "res://Scenes/Race/DarkLeader.tscn"
		if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
			if Global_DataParser.build_castle_vampire > 0:
				if Global_DataParser.vampire_elite_count < Global_DataParser.build_castle_vampire:
					object_path = "res://Scenes/Race/Vampire_High.tscn"
				else:
					return		
			else:
				return
			object_path = "res://Scenes/Race/Vampire_High.tscn"

#		var object_path = "res://Scenes/Damage/Damage_High.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"Vampire_DarkLeader_MagFire")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Vampire_DarkLeader_MagFire",Global_DataParser.join_race,Global_DataParser.location_number)

func attack13_1(dmg):						
		var	a = load("res://Scenes/Damage/Damage_High.tscn").instance()
	
#		var	a = load("res://Scenes/Walls/Grane.tscn").instance()
#		a.set_damage(1000)
		print(a.position.x)
		print(a.position.y)		
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		a.position.x = x * 64	
		print(a.position.x)
		print(a.position.y)		
		a.position.y = y * 64
#		a.position = position #$DamagePos.разброс попадания в цель
#			mana -= dmg
		$'/root/Game/Empire'.add_child(a)
#		print("restore build")

		print("Damage_High build")
func attack6(dmg):
	if (Global_DataParser.get_energy() > 950):		
			Global_DataParser.reduce_energy(950)
			var object_path
			var	object_name = "FarmVampire"			
			if Global_DataParser.join_race == 0:
				object_path = "res://Scenes/Build/Temple_old.tscn"
				object_name = "Temple_old"					
			if Global_DataParser.join_race == 1:
				object_path = "res://Scenes/Build/DarkAvanpost.tscn"
				object_name = "DarkAvanpost"				
			if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:
				object_path = "res://Scenes/Build/FarmVampire.tscn"
				object_name = "FarmVampire"
			if get_tree().is_network_server():	
#			rpc("_call_mob",6,1,dmg,$Sprite.global_position)
				Global_Network.spawn_object(1,object_path,$Sprite.global_position,object_name,Global_DataParser.join_race,Global_DataParser.location_number)

	#		print("call Farm")
			else:
	
				Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,object_name)

func attack7(dmg):
	if (Global_DataParser.get_energy() >9999):		
		Global_DataParser.reduce_energy(9999)
		var object_path = "res://Scenes/Walls/Grane.tscn"
		# var object_path = "res://Scenes/Build/TownEmpire.tscn"
		var x = int(position.x/64) - 1
		var y = int(position.y/64)	- 1
		var spawn_position = Vector2(x * 64,y * 64)		
		if not get_tree().is_network_server():
#		Global_Network.spawn_object(get_tree().get_network_unique_id(),object_path,$Sprite.global_position,"PriestEmpire",Global_DataParser.join_race,Global_DataParser.location_number)

#			spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
#			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh")			
			Global_Network.rpc_spawn_object(get_tree().get_network_unique_id(),object_path,spawn_position,"TownEmpire")
#			rpc_id(1,"spawn_object",get_tree().get_network_unique_id(),object_path,spawn_position,"DamageHigh",Global_DataParser.join_race,Global_DataParser.location_number)
		else:
			Global_Network.spawn_object(1,object_path,spawn_position,"Grane",Global_DataParser.join_race,Global_DataParser.location_number)
	
	
#		rpc("_call_mob",7,1,dmg,$Sprite.global_position)

func attack8(dmg):
	if (Global_DataParser.get_energy() > 5000):		
		Global_DataParser.reduce_energy(5000)
	
#	if get_tree().is_network_server():	
		rpc("_call_mob",8,1,dmg,$Sprite.global_position)
#		print("attack damage build")
#		print("call 8 Dark Leader",$Sprite.global_position)
func attack9(dmg):
	if (Global_DataParser.get_energy() > 5000):		
		Global_DataParser.reduce_energy(5000)
	
#	if get_tree().is_network_server():	
		rpc("_call_mob",9,1,dmg,$Sprite.global_position)
#		print("attack damage build")
#		print("call Dark Leader")
func attack0(dmg):
	if (Global_DataParser.get_energy() > 2500):		
		Global_DataParser.reduce_energy(2500)
	
#	if get_tree().is_network_server():	
		rpc("_call_mob",0,1,Global_DataParser.join_race,$Sprite.global_position)
#		print("attack damage build")
#		print("call Dark Leader")
func attack10(dmg):
#		var a = $Sprite.global_position
#		print("sprite position")
#		print (a)
	if (Global_DataParser.get_energy() > 100000):		
		Global_DataParser.reduce_energy(100000)
			
#	if get_tree().is_network_server():	
		rpc("_call_mob",10,1,dmg,$Sprite.global_position)
#		print("attack damage build")
#		print("call Dark Leader")
func attack11(dmg):
	if (Global_DataParser.get_energy() > 1000000):		
		Global_DataParser.reduce_energy(1000000)
	
#	if get_tree().is_network_server():	
		rpc("_call_mob",11,1,dmg,$Sprite.global_position)
#		print("attack damage build")
#		print("call build 11")
func attack12(dmg):
	if (Global_DataParser.get_energy() > 2500):		
		Global_DataParser.reduce_energy(2500)
	
#	if get_tree().is_network_server():	
		rpc("_call_mob",0,1,dmg,$Sprite.global_position)
#		print("attack damage build")
#		print("call mob 6")
		
sync func _call_mob(race,b,dmg,build_position):
		var	a
#		print("prc build position 8")
#		print (build_position)

		if race == 6:
			print("Server called Temple_Elf 6")	
			a = load("res://Scenes/Build/Temple_Elf.tscn").instance()
			a.position = build_position #$DamagePos.разброс попадания в цель
#			mana -= dmg
			$'/root/Game/Empire'.add_child(a)	

		if race == 7: #and (Global_DataParser.get_energy() > 250):		
#			Global_DataParser.reduce_energy(250)
			print("Server called Town Empire 7")	
			a = load("res://Scenes/Build/TownEmpire.tscn").instance()
			a.position = build_position#$DamagePos.разброс попадания в цель
			a.set_target(build_position)		
#			mana -= dmg
			$'/root/Game/Empire'.add_child(a)	
		
		if race == 8:# and (Global_DataParser.get_energy() > 150):		
#			Global_DataParser.reduce_energy(150)
			print("Server Vampire Castle 8")	
			a = load("res://Scenes/Build/VampireCastle.tscn").instance()
#			a = load("res://Scenes/Damage/DamageAreaFireLight.tscn").instance()
	
			a.position = build_position #$DamagePos.разброс попадания в цель
#			mana -= dmg
			$'/root/Game/Empire'.add_child(a)	


		if race == 9: # and (Global_DataParser.get_energy() > 100):		
#			Global_DataParser.reduce_energy(100)
			if dmg == 0:
				print("Server called Temple")	
				a = load("res://Scenes/Build/Temple.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)	
			if dmg == 1:
				print("Server called HomeOrk")	
				a = load("res://Scenes/Build/HomeOrk.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Dark'.add_child(a)	
			if dmg == 2:
				print("Server called HomeTroll")	
				a = load("res://Scenes/Build/HomeTroll.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)	
			if dmg == 3:
				print("Server called HomeKobold")	
				a = load("res://Scenes/Build/HomeKobold.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Neutral'.add_child(a)	
			


		if race == 10: #and (Global_DataParser.get_energy() > 500):		
#			Global_DataParser.reduce_energy(500)
			
			if dmg == 0:
				print("Server called Outpost")	
				a = load("res://Scenes/Build/Outpost.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)	
			if dmg == 1:
				print("Server called Grymeyard")	
				a = load("res://Scenes/Build/TowerGuard.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Dark'.add_child(a)	
			if dmg == 2:
				print("Server called Avanpost")	
				a = load("res://Scenes/Build/Avanpost.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)	
			if dmg == 3:
				print("Server called Magic Tower")	
				a = load("res://Scenes/Build/MagicTower.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)
					
		if race == 11:
			print ("rpc call 11")			
			if dmg == 0:
				print("Server called Temple Elf 11")	
				a = load("res://Scenes/Build/Temple_Elf.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)	
			if dmg == 1:
				print("Server called Grymeyard")	
				a = load("res://Scenes/Build/Grimeyard.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Dark'.add_child(a)	
			if dmg == 2:			

#			if (Global_DataParser.get_energy() > 350):		
#				Global_DataParser.reduce_energy(350)
				print("Server called DarkFortress 11")	
				a = load("res://Scenes/Build/DarkFortress.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)	
			if dmg == 3:
				print("Server called Magic Tower")	
				a = load("res://Scenes/Build/Capital.tscn").instance()
				a.position = build_position #$DamagePos.разброс попадания в цель
	#			mana -= dmg
				$'/root/Game/Empire'.add_child(a)

		if race == 0:
			if dmg == 1:
#				if (Global_DataParser.get_energy() >= 100):		
#					Global_DataParser.reduce_energy(100)

					print("Server called Dark Elf")	
					a = load("res://Scenes/Race/DarkElf.tscn").instance()
					#		a.set_damage(1000)
					a.position = build_position #$DamagePos.разброс попадания в цель
		#			mana -= dmg
					$'/root/Game/Dark'.add_child(a)	
			if dmg == 2 or dmg == 3:
#					print("Server called Ghost")
#				if (Global_DataParser.get_energy() > 50):		
#					Global_DataParser.reduce_energy(50)

					print("Server called Ghost")	
					a = load("res://Scenes/Race/Skeleton.tscn").instance()
					
			#		a.set_damage(1000)
					a.position = build_position #$DamagePos.разброс попадания в цель
			#			mana -= dmg
					$'/root/Game/Neutral'.add_child(a)
			if dmg == 0:
#					print("Server called Knight")
#				if (Global_DataParser.get_energy() > 50):		
#					Global_DataParser.reduce_energy(50)

					print("Server called Knight")	
					a = load("res://Scenes/Race/Knight.tscn").instance()
					
			#		a.set_damage(1000)
					a.position = build_position #$DamagePos.разброс попадания в цель
			#			mana -= dmg
					$'/root/Game/Empire'.add_child(a)	
func die():
	print("die player")
	if self.dead == false:
#		randomize()
#		for i in inventory.get_items():
#		var x_coord = rand_range(-2, 2) * 10 + self.position.x
#		var y_coord = rand_range(-2, 2) * 10 + self.position.y
#		add_lying_item(x_coord, y_coord)
		get_parent().remove_child(self)
		queue_free()
		self.dead = true

func update_hp():
#	print("player = hp")
#	print(hp)
	
	$HP_bar.value = hp

func reduce_hp(val):
#	print("player - hp")
#	print(hp)
	if self.hp > 0:
		self.hp -= val
	if self.hp > 0:
		update_hp()
	if self.hp <= 0:
		die()
#		_die_and_loose_items()
		return false
	return true
	
	
func _process(delta):
#	if Global_DataParser.world_already_load == false and (!get_tree().is_network_server()) and is_network_master():
#
#		load_data_world_client(Global_DataParser._new_data)
#		rpc("load_data_world_server")
#		Global_DataParser.world_already_load = true	
	if Global_DataParser.player_control == false:
		
#		$Camera2D.current = true
#		player_show()	
		Global_DataParser.player_position = $Sprite.global_position
		if (!is_network_master() and Global_DataParser.hardlevel == 0):
			position = slave_position

			$Health.visible = true
##			rset_unreliable('slave_position', position)

			rpc_spawn_player(position)				
	#	rset('slave_movement', velocity)
		
			if get_tree().is_network_server():

				Global_Network.update_position(int(name), position)
		else:
			rpc_spawn_player(position)		
			
#	if get_tree().is_network_server():
#		print("update position")
#		Global_Network.update_position(int(name), position)
	
func _physics_process(delta):
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
	if !get_is_other_focused() and hardcore_level == 0:
#	if !get_is_other_focused():			
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
				if dead_damage == true and Global_DataParser.player_control == false:
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
			speed_multiplier = 0.75
			show_info("I am moving 2x slower. I need food!")

		if(mana > 0):
			mana -= delta * 0.001
			$Stats/ManaLabel.modulate = Color(1, 1, 1)

			if(int(mana) != int(max_mana)):
				mana += delta
				$Mana.value = int(mana)
			
		else:
			mana = 0
			$Stats/ManaLabel.modulate = Color(1, 0, 0)

			$Mana.value = int(mana)

			show_info("I don't cast spell. I need mana!")
		
	if(weight < max_weight): # and hardcore_level != 0:
		$Stats/WeightLabel.modulate = Color(1, 1, 1)
		speed_multiplier = 1
	else:
		$Stats/WeightLabel.modulate = Color(1, 0, 0)
		speed_multiplier = 0.5
		show_info("I carry to much and cant move faster. I need to loose some items!")


	if damage_health != 0 and Global_DataParser.player_control == false: #  уменьшаем здоровье персонажа на величину урона  damage или увеличиваем на величину лечения
		print("damage")
		print(damage_health)

		if damage_health < 0: 
			print("damage < 0 , Healing +20")

			health -= damage_health
			if health >= max_health:
				health = max_health
			$Health.value = health 			
			$Stats/HealthCountLabel.text = str(health) 
			damage_health = 0
		if damage_health > 0:
			damage_health -= 1	
			print("health - 1")
			health -= 1
#			$Stats/HealthCountLabel.value -= 1
			$Health.value -= 1
			$Stats/HealthCountLabel.text = str($Health.value)			
			print (health)
			if(health <= 0):
				if $Health.value <= 0:
					print("damage 0  health < 0")
					damage_health = 0
					dead_damage = true
					rpc("_die_and_loose_items", $NicknameLabel.text, _data_player, $Sprite.global_position)
	if damage_mana != 0 and Global_DataParser.player_control == false: #  уменьшаем здоровье персонажа на величину урона  damage или увеличиваем на величину лечения
		print("restore mana")
		print(damage_mana )
		print(mana)
		if damage_mana  < 0: 
			print("damage < 0 , mana +50%")
#			$Health.value -= damage_health
			mana  -= damage_mana 
			if mana  >= max_mana :
				mana  = max_mana 
			$Stats/ManaCountLabel.text = str(mana)  			
			damage_mana  = 0
			print(mana)
			print("mana")

		if damage_mana  > 0:
#			damage_mana  -= 1	
			print("mana  +50%")
			mana  -= damage_mana 
			$Stats/ManaCountLabel.text = str(mana) 
			print (mana )
#	else:
#		print("no damage")
	if enter_towns == false and hardcore_level == 0:
		if(int(water) < int(_inventory.get_water())):
			_inventory.remove_item_amount_by_id(3, 1, _data_player) # 3 is water bottle item id
			_inventory.load_items() # without arguments it reloads player items by default
		
		if(int(food) < int(_inventory.get_food())):
			_inventory.remove_item_amount_by_id(1, 1, _data_player) # 1 is insect food item id
			_inventory.load_items() # without arguments it reloads player items by default

#		if(int(mana) < int(_inventory.get_mana())):
#			_inventory.remove_item_amount_by_id(4, 1, _data_player) # 4 is mana flask item id
#			mana = max_mana
#			_inventory.load_items() # without arguments it reloads player items by default
	
	_update_stats()
func init_world(_world_data):
	Global_DataParser._new_data = _world_data
	Global_DataParser.world_already_load = false	
	print("init world complete")
func add_location_world():
		var location = load('res://Scenes/Location/World.tscn').instance()
		location.name = "Worlds" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_id = location
		$'/root/Game/Location'.add_child(location)
		Global_DataParser.location_number = 0
func add_location_empire():
		var location = load('res://Scenes/Location/EmpireLands.tscn').instance()
		location.name = "EmpireLands" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_id = location
		$'/root/Game/Location'.add_child(location)
		Global_DataParser.location_number = 1
		
func add_location_dark_empire():
		var location = load('res://Scenes/Location/DarkLands.tscn').instance()
		location.name = "DarkLands" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_id = location
		$'/root/Game/Location'.add_child(location)
		Global_DataParser.location_number = 2
func add_location_neutral_lands():
		var location = load('res://Scenes/Location/NeutralLands.tscn').instance()
		location.name = "NeutralLands" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_id = location
		$'/root/Game/Location'.add_child(location)
		Global_DataParser.location_number = 3
func add_location_dungeon(number_location):
	var location 	
	if number_location == 1:
		location = load('res://Scenes/Dungeon/Dungeon_Sklep.tscn').instance()
		location.name = "Dungeon" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_number = 4
	if number_location == 2:
		location = load('res://Scenes/Dungeon/Dungeon_Farm.tscn').instance()
		location.name = "EmpireFarm" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_number = 5
	if number_location == 3:
		location = load('res://Scenes/Dungeon/Dungeon_Village.tscn').instance()
		location.name = "EmpireFarm" #nickname + "_" + str(Global_DataParser.rng.randi())
		Global_DataParser.location_number = 6
		
	Global_DataParser.location_id = location
	$'/root/Game/Location'.add_child(location)
func add_location_dungeon_name(name_location,number):
	var location 	
	location = load(name_location).instance()
	location.name = "Dungeon" #nickname + "_" + str(Global_DataParser.rng.randi())
	Global_DataParser.location_number = number
	Global_DataParser.location_id = location
	$'/root/Game/Location'.add_child(location)

func del_location_number(location_name):
	for child in $'/root/Game/Location'.get_children():
		$'/root/Game/Location'.remove_child(child)
	return
func del_location_object(location_name):	
	if Global_DataParser.location_number == 1:
#		for location in $'/root/Game/Location':
			$'/root/Game/Location'.remove_child(Global_DataParser.location_id)
	elif Global_DataParser.location_number == 1:
#		for location in $'/root/Game/Location':
			$'/root/Game/Empire'.remove_child(Global_DataParser.location_id)
	elif Global_DataParser.location_number == 3:
#		for location in $'/root/Game/Location':
			$'/root/Game/Dark'.remove_child(Global_DataParser.location_id)
	elif Global_DataParser.location_number == 4:
			$'/root/Game/Neutral'.remove_child(Global_DataParser.location_id)
	elif Global_DataParser.location_number == 5:

			$'/root/Game/Location'.remove_child(Global_DataParser.location_id)			
	Global_DataParser.location_number = 0				
func init(nickname, start_position, is_slave):
	$NicknameLabel.text = nickname
#	Global_DataParser.join_race = race	
#устанавливаем расу игрока	
	if is_network_master():
		Global_DataParser.IS_LOAD_FROM_FILE_ENABLED = true
		if Global_DataParser.join_race == 0:
			$Sprite.texture = load('res://Assets/units2/human/silver-mage.png')				
			_data_player = load_data_empire(nickname, "Player")
			position = Vector2(-5000.0,1100.0)
			rset_unreliable('slave_position', position)
			add_to_group(Global_DataParser.empire_group)					
			if(is_network_master()):
				add_location_empire()
				Global_DataParser.location_number = 1
	#		else:	
			location_number = 1
		elif Global_DataParser.join_race == 1:
			$Sprite.texture = load('res://Assets/units2/human/mage.png')					
#			_data_player = load_data_dark(nickname, "Player")
			_data_player = load_data_empire(nickname, "Player")
			position = Vector2(-220,-148)
			rset_unreliable('slave_position', position)
			if(is_network_master()):
				add_location_world()
				Global_DataParser.location_number = 2
			location_number = 2		
		elif Global_DataParser.join_race == 2:	
#			_data_player = load_data_exile(nickname, "Player")
			_data_player = load_data_empire(nickname, "Player")
			position = start_position
			rset_unreliable('slave_position', position)
			add_to_group(Global_DataParser.darkempire_group)					
			
			if(is_network_master()):
				add_location_neutral_lands()
				Global_DataParser.location_number = 3
			location_number = 3		
		else:
	#		if Global_DataParser.join_race == 3:	
	#			_data_player = load_data(nickname, "Player")
	#			position = Vector2(-22370,-740)
	#			rset_unreliable('slave_position', position)
	#		else:
			_data_player = load_data_empire(nickname, "Player")		
		
			position = start_position
			rset_unreliable('slave_position', position)
			
			if(is_network_master()):
				add_location_neutral_lands()
				Global_DataParser.location_number = 3
			location_number = 3		
		Global_DataParser.IS_LOAD_FROM_FILE_ENABLED = false	
#	if is_slave:
#		$Sprite.texture = load('res://player/character-alt.png')
#	if is_network_master():
		$Camera2D.current = true
		update_vars()
		$InfoLabel.visible = false
		_map_zoom_out_label.visible = false
		_map_v_slider.visible = false
#		position = Vector2(-22370.0,740.0)
#		rset_unreliable('slave_position', position)
		get_player_stats()
		_update_level()	
	print("init player complete")
	print(self.name)	
func get_player_stats():
	Global_DataParser.level = GlobalData.player_info["level"]	
	Global_DataParser.energy = GlobalData.player_info["energy"]
	Global_DataParser.exp_need = GlobalData.player_info["exp_need"]	
	Global_DataParser.expirience = GlobalData.player_info["expirience"]
#	$Sprite.position.x = GlobalData.player_info["posX"]
#	$Sprite.position.y = GlobalData.player_info["posY"]

func _update_stats():
	$Stats/HealthCountLabel.text = str(health).pad_decimals(0) + "/" + str(max_health) + " HP"

	$Stats/ManaCountLabel.text = str(mana).pad_decimals(0) + "/" + str(max_mana) + " MP"
	$Stats/EnergyCountLabel.text = str(Global_DataParser.get_energy()).pad_decimals(0)

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
			show_info("You character have died. AAAAAAAAHHH!! *Death*: Now, you respawn !!!")
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
		$'/root/Game/Empire'.add_child(bag)
		var bag_url_data = "res://Database//data_bag_" + bag.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		bag.init(_inventory, bag.name, data, die_position, bag_url_data)
		bag.reload_data_by_inventory(_inventory)

func rpc_spawn_town(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_town", nickname, data, die_position, url_data)
#		Global_DataParser.build_farm += 1	


sync func spawn_town(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/FarmEmpire.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire'.add_child(town)
		var bag_url_data = "res://Database//data_farm_" + town.name + ".json"
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
		$'/root/Game/Empire/'.add_child(town)
		var bag_url_data = "res://Database//data_fortress_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_village(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_village", nickname, data, die_position, url_data)
#		Global_DataParser.build_village += 1	


sync func spawn_village(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/VillageEmpire.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire/'.add_child(town)
		var bag_url_data = "res://Database//data_village_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_villageExile(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_villageExile", nickname, data, die_position, url_data)
		Global_DataParser.build_village += 1	


sync func spawn_villageExile(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/VillageExile.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire'.add_child(town)
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
		$'/root/Game/Empire'.add_child(town)
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
		$'/root/Game/Neutral'.add_child(town)
		var bag_url_data = "res://Database//data_storage_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)

func rpc_spawn_barack(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_barack", nickname, data, die_position, url_data)
#		Global_DataParser.build_barrack += 1	


sync func spawn_barack(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Temple.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire'.add_child(town)
		var bag_url_data = "res://Database//data_storage_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_temple(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_temple", nickname, data, die_position, url_data)
#		Global_DataParser.temple += 1	


sync func spawn_temple(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Temple_old.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire'.add_child(town)
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
		$'/root/Game/Empire'.add_child(town)
		var bag_url_data = "res://Database//data_start_town_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)

func rpc_spawn_castle(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_castle", nickname, data, die_position, url_data)
##		Global_DataParser.build_castle += 1	


sync func spawn_castle(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Castle.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire'.add_child(town)
		var bag_url_data = "res://Database//data_castle_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_capital(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_capital", nickname, data, die_position, url_data)
#		Global_DataParser.build_capital += 1	


sync func spawn_capital(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/Capital.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Empire'.add_child(town)
		var bag_url_data = "res://Database//data_capital_" + town.name + ".json"
		Global_DataParser.write_data(bag_url_data, data)
		town.init(_inventory, town.name, data, die_position, bag_url_data)
		town.reload_data_by_inventory(_inventory)


func rpc_spawn_dark_fortress(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
		rpc("spawn_dark_fortress", nickname, data, die_position, url_data)
	


sync func spawn_dark_fortress(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(!_inventory.is_inventory_empty_by_data(data)):
		town = load('res://Scenes/Build/DarkFortress.tscn').instance()
		town.name = nickname + "_" + str(Global_DataParser.rng.randi())
#		bag.name = nickname
		$'/root/Game/Dark'.add_child(town)
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
		$'/root/Game/Empire'.add_child(town)
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
func load_data_bag_npc(name, item_list_label:String = "Player") -> Dictionary:
	return _inventory.load_datanpc(name, item_list_label)
	
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
	return _inventory.load_data(name, item_list_label, true)


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
#	_update_mana()	
	_update_weight()
	_update_max_weight()
	_update_vehicle_speed()
	_update_level()
	_update_exp()
func _update_level():
	$Stats/LevelCountLabel.text = str(Global_DataParser.get_level())
	$LevelLabel.text = str(Global_DataParser.get_level())		
func _update_exp():
	$Stats/ExpCountLabel.text = str(Global_DataParser.get_expirience())	+ " / " + str(Global_DataParser.get_exp_need()) 
func _update_energy():
	$Stats/EnergyCountLabel.text = str(Global_DataParser.get_energy())		
func _on_timer_show_info_timeout():
	$InfoLabel.text = ""
	$InfoLabel.visible = false
#=============================================
func area_entered_bag_npc(area):
		var IS_LOAD_FROM_FILE_ENABLED = true	
		_inventory_button.modulate = Color(1,0,0,0.5)
		_inventory.set_other_visible(true)
		load_data_bag_npc(area.get_parent().name, "Bag")
		_inventory.button_multi.text = "Take"
		
func area_entered_builds(area):		
		_inventory_button.modulate = Color(0,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data(area.name, "Village")
		_inventory.button_multi.text = "Take"
			
func area_entered_shops(area):
		var IS_LOAD_FROM_FILE_ENABLED = true				
		_inventory_button.modulate = Color(0,0,1,0.5)
		_inventory.set_other_visible(true)
		load_data_shop(area.name, "Shop")
		_inventory.button_multi.text = "Sell"	
		
func area_entered_temple(area):			
		_inventory_button.modulate = Color(1,0,0,0.5)
		_inventory.set_other_visible(true)
		load_data_temple(area.name, "Temple")
		_inventory.button_multi.text = "Take"
		
func area_entered_tower(area):			
		_inventory_button.modulate = Color(0,1,1,0.5)
		_inventory.set_other_visible(true)
		load_data_tower(area.name, "Tower")
		_inventory.button_multi.text = "Take"
		
func area_entered_fortress(area):
		_inventory_button.modulate = Color(1,0,1,0.5)
		_inventory.set_other_visible(true)
		load_data_fortress(area.name, "Fortress")
		_inventory.button_multi.text = "Take"
			
func area_entered_castle(area):
		_inventory_button.modulate = Color(0,1,0,0.5)
		_inventory.set_other_visible(true)
		load_data_castle(area.name, "Castle")
		_inventory.button_multi.text = "Take"
				
func area_entered_capital(area):
		_inventory_button.modulate = Color(0,0,1,0.5)
		_inventory.set_other_visible(true)
		load_data_capital(area.name, "Capital")
		_inventory.button_multi.text = "Take"
		
func area_entered_bags(area):	
		_inventory_button.modulate = Color(1,0,0,0.5)
		_inventory.set_other_visible(true)
		var IS_LOAD_FROM_FILE_ENABLED = true
#		load_data_bag_npc(area.get_parent().name, "Bag")
		load_data_shop(area.get_parent().name, "Bag")		
		_inventory.button_multi.text = "Take"
func area_entered_village(area):	
		_inventory_button.modulate = Color(0,1,1,0.5)
		_inventory.set_other_visible(true)
		load_data_tower(area.name, "Tower")
		_inventory.button_multi.text = "Take"
												
#=============================================
		
func _on_Player_area_entered(area):
	area_type_id = area
	build_area_type_id = self
	last_build_id = self	
#	print("----------------------------")
#	print(build_area_type_id)
#	print("----------------------------")

	if(area.is_in_group("builds")):
		area_type = 2		
		_inventory_button.modulate = Color(0,1,1,0.5)
		build_area_type_id = area		
		if area_type_id.has_method('set_what_do'):
			last_build_id = area_type_id	
	elif(area.is_in_group("ghost")):
		area_type = 11
#		area_entered_bag_npc(area)
		_inventory_button.modulate = Color(0,0,0,0.5)
#		_inventory.set_other_visible(true)
#		load_data_bag_npc(area.get_parent().name, "Bag")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("bag_npc")):
		area_type = 1
		_inventory_button.modulate = Color(1,0,1,0.5)	
	elif(area.is_in_group("builds")):
		area_type = 2
		build_area_type_id = area				
		_inventory_button.modulate = Color(1,0,0,0.5)
		if area_type_id.has_method('set_what_do'):
			last_build_id = area_type_id		
#		_inventory.set_other_visible(true)
#		load_data(area.name, "Village")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("shops")):
		area_type = 3		
		_inventory_button.modulate = Color(0,0,1,0.5)
#		_inventory.set_other_visible(true)
#		load_data_shop(area.name, "Shop")
#		_inventory.button_multi.text = "Sell"
		if area_type_id.has_method('wellcome'):
			area_type_id.wellcome()
	elif(area.is_in_group("temple")):
		area_type = 4
		build_area_type_id = area		
		_inventory_button.modulate = Color(1,0,0,0.5)
#		_inventory.set_other_visible(true)
#		load_data_temple(area.name, "Temple")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("farm")):
		area_type = 5		
		_inventory_button.modulate = Color(0,1,1,0.5)
		if area_type_id.has_method('set_what_do'):
			last_build_id = area_type_id
#		_inventory.set_other_visible(true)
#		load_data_tower(area.name, "Tower")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("fortress")):
		area_type = 6
		_inventory_button.modulate = Color(1,0,1,0.5)
#		_inventory.set_other_visible(true)
#		load_data_fortress(area.name, "Fortress")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("castle")):
		area_type = 7
		_inventory_button.modulate = Color(0,1,0,0.5)
#		_inventory.set_other_visible(true)
#		load_data_castle(area.name, "Castle")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("capital")):
		area_type = 8
		_inventory_button.modulate = Color(0,0,1,0.5)
#		_inventory.set_other_visible(true)
#		load_data_capital(area.name, "Capital")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("village")):
		area_type = 9
		_inventory_button.modulate = Color(1,0,1,0.5)
		if area_type_id.has_method('set_what_do'):
			last_build_id = area_type_id		
	elif(area.is_in_group("bags")):
		area_type = 10
		_inventory_button.modulate = Color(1,0,0,0.5)
#		_inventory.set_other_visible(true)
#		load_data_bag_npc(area.get_parent().name, "Bag")
#		_inventory.button_multi.text = "Take"
	elif(area.is_in_group("enter")):
		_inventory_button.modulate = Color(0,0,0,1)
		area_type = 12
		area_type_id = area
#		area_type_id = area.get_teleport_position()		
#	elif(area.is_in_group("exit")):
#		_inventory_button.modulate = Color(1,0,1,0.5)
#		area_type = 12			
	elif(area.is_in_group("player_damage")):
		_inventory_button.modulate = Color(1,1,1,0.5)
		area_type = 13			
		print("Health -75")
		damage_health = 75
	elif(area.is_in_group("players") && area.get_node("Sprite").is_visible_in_tree()):
		area_type = 0
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
#	if area_type_id.has_method('goodbye'):
#		area_type_id.goodbye()	
	area_type = 0
#	area_type_id = null
	var IS_LOAD_FROM_FILE_ENABLED = false	
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
func go_dungeon():
			if(is_network_master()):
				del_location_number("location_name")					
				add_location_dungeon(2)
				get_parent().get_node("Empire").visible = false
				get_parent().get_node("Dark").visible = false
				get_parent().get_node("Neutral").visible = false
				get_parent().get_node("Animal").visible = false
				position = Vector2(900,900)		


func _on_InventoryButton_button_down():
	if	area_type != 0:
		if area_type == 1:
			area_entered_bag_npc(area_type_id)
		if area_type == 2:
			area_entered_builds(area_type_id)
		if area_type == 3:
			area_entered_shops(area_type_id)
			if area_type_id.has_method('wellcome') and !_inventory.is_visible():
				area_type_id.wellcome()
		if area_type == 4:
			area_entered_temple(area_type_id)
		if area_type == 5:
			area_entered_temple(area_type_id)
#			area_entered_tower(area_type_id)	
		if area_type == 6:
			area_entered_fortress(area_type_id)
		if area_type == 7:
			area_entered_castle(area_type_id)
		if area_type == 8:
			area_entered_capital(area_type_id)
		if area_type == 9:
			area_entered_village(area_type_id)
		if area_type == 10:
			area_entered_bags(area_type_id)	
		if area_type == 11:	
			if(is_network_master()):
				del_location_number("location_name")					
				add_location_dungeon(1)
				get_parent().get_node("Empire").visible = false
				get_parent().get_node("Dark").visible = false
				get_parent().get_node("Neutral").visible = false
				get_parent().get_node("Animal").visible = false		

			#	teleport_gungeon()
			return
#		if area_type == 12:			
#			teleport_exit_dungeon()
#			return																																			
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

func call_map():
	_on_MapButton_button_down()	
	_on_MapButton_pressed()
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
		$MidleMenu.visible = false
		$MidleMenu2.visible = false
		$ActionMenu.visible = false
		$UnitMenu.visible = false
		$WorldMap.visible = false				
	else:
		_map_button.modulate = Color(1, 1, 1, 1)


func _on_ExitMenu_pressed():
	$MidleMenu.visible = false
	$MidleMenu2.visible = false		
	get_tree().change_scene('res://Scenes/Menu.tscn')
func _on_Continue_pressed():
	player_stats_save1()
	$MidleMenu.visible = false
	$MidleMenu2.visible = false	
	$ActionMenu.visible = false
	$UnitMenu.visible = false
	$WorldMap.visible = false				
func player_stats_save1():
	set_player_stats()

	Utility.saveDictionary(GlobalData.path + "player_"+ str($NicknameLabel.text) + "_info.json", GlobalData.player_info)
	Utility.saveDictionary(GlobalData.path + "player_"+ str($NicknameLabel.text) + "_bag.json", _data_player)
		
func player_stats_save():
	set_player_stats()

	Utility.saveDictionary(GlobalData.path + "player_"+ str($NicknameLabel.text) + "_info.json", GlobalData.player_info)
	Utility.saveDictionary(GlobalData.path + "player_"+ str($NicknameLabel.text) + "_bag.json", _data_player)
	get_data_npc_all()
	var _world_data = Global_DataParser._new_data
	Utility.saveDictionary(GlobalData.path + "player_"+ str($NicknameLabel.text) + "_world.json", _world_data)
	
#	GlobalData.savePlayerInfo()			
func set_player_stats():
	GlobalData.player_info["level"] = Global_DataParser.level	
	GlobalData.player_info["energy"] = int(Global_DataParser.energy)
	GlobalData.player_info["exp_need"] = int(Global_DataParser.exp_need)	
	GlobalData.player_info["expirience"] = int(Global_DataParser.expirience)
	GlobalData.player_info["posX"] = int($Sprite.global_position.x)
	GlobalData.player_info["posY"] = int($Sprite.global_position.y)	
func get_data_npc_all():
	return get_parent().get_data_npc()
	
	
sync func load_data_world_server():
	if get_tree().is_network_server():
		var _world_data = Global_DataParser._new_data	
		rpc("load_data_world_client",_world_data)
	else:
		print("not loading data world")	
			
#sync
func load_data_world_client(_world_data):
#	if 	world_now_load == true:
	if is_network_master():
		$Chat/Panel/RichTextLabel.text += "Loading world from server\n"	
		print("from server add  empire")
		load_data_npc(_world_data,"Empire")
#	elif Global_DataParser.location_number == 2:
		print("add  darkempire")
		load_data_npc(_world_data,"DarkEmpire")
		
#	elif Global_DataParser.location_number == 3:		
		print("add neutral")		
		load_data_npc(_world_data,"Neutral")

		print("add animal")		
		load_data_npc(_world_data,"Animal")
		$Chat/Panel/RichTextLabel.text += "Loading world from server completed\n"	
func load_data_npc(_world_data,fraction):
	if _world_data == null:
		return
	var i = 0
	for fract in _world_data:
		
		if fract == fraction:
			for child in _world_data[fraction]:
#				if get_tree().is_network_server():				
#					rpc("spawn_object",child)
#				else:
				spawn_object(child)
			print("added")
			print(fraction)		
			print(i)
			i += 1
		else:
			print("Fraction not fount:")
			print(fraction)	
	print (i)		
	return true
#sync
func spawn_object(child):
		var object = load(child["whoiam"]).instance()

		object.name = child["nickname"] + "_" + str(Global_DataParser.rng.randi())
		$'/root/Game/Empire'.add_child(object)
		object.position.x = child["positionX"]
		object.position.y = child["positionY"]
		object.set_data(child)
		object.position.x = child["positionX"]
		object.position.y = child["positionY"]		
		print("added empire")	
func _on_MenuButton_pressed():
			SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
			if $MidleMenu2.visible == true:
				$MidleMenu.visible = false
#				update_all_count()
#				get_parent().get_node("MidleMenu").visible = false
				$MidleMenu2.visible = false
			else:
				$MidleMenu.visible = true
				update_all_count()
#				get_parent().get_node("MidleMenu").visible = true
				$MidleMenu2.visible = true				
				player_stats_save1()				
#			return

func update_all_count():
#	var a = get_parent().get_node("MidleMenu").get_node("Panel")
	var a = $MidleMenu2/Panel
	a.get_node("KnightCount").text = str(Global_DataParser.knight_count)
#	var b = get_parent().get_node("MidleMenu").get_node("Panel").get_node("DarkElfCount")
	a.get_node("DarkElfCount").text = str(Global_DataParser.darkelf_count)
#	var c = get_parent().get_node("MidleMenu").get_node("Panel").get_node("OrkCount")
	a.get_node("OrkCount").text = str(Global_DataParser.ork_count)
#	var d = get_parent().get_node("MidleMenu").get_node("Panel").get_node("KoboldCount")
	a.get_node("KoboldCount").text = str(Global_DataParser.ghost_count)
#	var e = get_parent().get_node("MidleMenu").get_node("Panel").get_node("KoboldCount")
	a.get_node("AllNPCcount").text = str(Global_DataParser.get_count_mobs())
	a.get_node("TROLLCount").text = str(Global_DataParser.cyclop_count)
	a.get_node("PaladinCount").text = str(Global_DataParser.paladin_count)
	a.get_node("ZombieCount").text = str(Global_DataParser.zombie_count)
	a.get_node("PeasantCount").text = str(Global_DataParser.peasant_count)
	a.get_node("GhostCount").text = str(Global_DataParser.ghost_count)
	a.get_node("VampireCount").text = str(Global_DataParser.vampire_count)
	a.get_node("MagFireCount").text = str(Global_DataParser.magfire_count)
	a.get_node("VampireHCount").text = str(Global_DataParser.vampire_elite_count)
	a.get_node("ElfCount").text = str(Global_DataParser.elf_count)
	a.get_node("AllBuildsCount").text = str(Global_DataParser.get_count_builds())
	a.get_node("FarmCount").text = str(Global_DataParser.build_farm)
	a.get_node("VillageCount").text = str(Global_DataParser.build_village)
	a.get_node("TempleCount").text = str(Global_DataParser.build_temple)
	a.get_node("CastleCount").text = str(Global_DataParser.build_castle)
	a.get_node("CapitalCount").text = str(Global_DataParser.build_capital)
	a.get_node("AnimalCount").text = str(Global_DataParser.animal_count)
	a.get_node("SingleValue").text = str(Global_DataParser.singleplay)
	a.get_node("Player_id").text  = str(get_tree().get_network_unique_id())
	a.get_node("HardModeLevel").text  = str(Global_DataParser.hardlevel)
	a.get_node("DarkMagCount").text = str(Global_DataParser.darkmag_count)
	a.get_node("FortressCount").text = str(Global_DataParser.build_fortress)
	a.get_node("MagTowerCount").text = str(Global_DataParser.build_magtower)
#	a.get_node("CapitalCount").text = str(Global_DataParser.build_capital)
#	a.get_node("AnimalCount").text = str(Global_DataParser.animal_count)

	print(Global_DataParser.knight_count)
	print("KnightCount")	
	print(Global_DataParser.ork_count)
	print("Ork Count")	
	print(Global_DataParser.darkelf_count)
	print("DarkElf Count")
	print(Global_DataParser.ghost_count)
	print("ghost Count")
	print(Global_DataParser.kobold_count)
	print("Kobold Count")						
func _on_MenuButton2_pressed():
	SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
	teleport_neutral() 


func _on_MenuButton11_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	attack6(Global_DataParser.join_race)
	attack4(1)

func _on_MenuButton10_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	attack7(Global_DataParser.join_race)
	attack13(Global_DataParser.join_race)

func _on_MenuButton8_pressed(): # вызываем героя пантеона

#	attack_on(0,25)
#	attack16(Global_DataParser.join_race)
	move_object()
func move_object():
	if area_type_id != null:
		var new_position = self.position
		rpc_move_object(new_position,area_type_id)
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))		
sync func 	rpc_move_object(new_position,id_object):
	id_object.position = new_position
#	print("move object to new position:")
#	print(id_object)
#	print(new_position)	



func _on_MenuButton3_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	teleport_empire(location_number) 


func _on_MenuButton4_pressed():
#			SoundPlayer.play(preload("res://audio/sounds/click.wav"))	 
#	teleport_dark() 	
#	attack10(Global_DataParser.join_race)
			SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
			if $WorldMap.visible == true:
				$WorldMap.visible = false
			else:
				$WorldMap.visible = true
#				update_all_count()
#				get_parent().get_node("MidleMenu").visible = true
				$WorldMap.visible = true
#	attack7(Global_DataParser.join_race)
#	attack15(Global_DataParser.join_race)
	
func _on_MenuButton5_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	attack4(1)
	attack6(Global_DataParser.join_race)

func _on_MenuButton6_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	attack_on(0,1)
#	attack14(1)
	attack7(Global_DataParser.join_race)

func _on_MenuButton7_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	attack_on(2,50)

func _on_MenuButton12_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	attack0(Global_DataParser.join_race)
	attack_on(1,25)


func _on_MenuButton13_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	attack13(Global_DataParser.join_race)
	attack14(1)

func _on_InventoryButton2_button_down():
	if $ActionMenu.visible == true:
		$ActionMenu.visible = false
		return
	else:
		$ActionMenu.visible = true
func Action_Multi():					
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))
	if	area_type != 0:
		if area_type == 1:
			area_entered_bag_npc(area_type_id)
		if area_type == 2:
			area_entered_builds(area_type_id)
		if area_type == 3:
			area_entered_shops(area_type_id)
			if area_type_id.has_method('wellcome') and !_inventory.is_visible():
				area_type_id.wellcome()
		if area_type == 4:
			area_entered_temple(area_type_id)
		if area_type == 5:
			if(is_network_master()):
				del_location_number("location_name")					
				add_location_dungeon(2)
				get_parent().get_node("Empire").visible = false
				get_parent().get_node("Dark").visible = false
				get_parent().get_node("Neutral").visible = false
				get_parent().get_node("Animal").visible = false
				position = Vector2(900,1100)		
			return			
#			area_entered_tower(area_type_id)	
		if area_type == 6:
			area_entered_fortress(area_type_id)
		if area_type == 7:
			area_entered_castle(area_type_id)
		if area_type == 8:
			area_entered_capital(area_type_id)
		if area_type == 9:
			if(is_network_master()):
				del_location_number("location_name")					
				add_location_dungeon(3)
				get_parent().get_node("Empire").visible = false
				get_parent().get_node("Dark").visible = false
				get_parent().get_node("Neutral").visible = false
				get_parent().get_node("Animal").visible = false
				position = Vector2(1500,900)		
			return			
			
#			area_entered_village(area_type_id)
		if area_type == 10:
			area_entered_bags(area_type_id)	
		if area_type == 11:	
			if(is_network_master()):
				del_location_number("location_name")					
				add_location_dungeon(1)
				get_parent().get_node("Empire").visible = false
				get_parent().get_node("Dark").visible = false
				get_parent().get_node("Neutral").visible = false
				get_parent().get_node("Animal").visible = false		
				position = Vector2(1900,900)
			#	teleport_gungeon()
			return
		if area_type == 12:
			if area_type_id.has_method('get_teleport_dungeon_name'):
				var dungeon_name = area_type_id.get_teleport_dungeon_name()
				var number = 7 #номер локации
				del_location_number("location_name")					
				add_location_dungeon_name(dungeon_name,number)
				get_parent().get_node("Empire").visible = false
				get_parent().get_node("Dark").visible = false
				get_parent().get_node("Neutral").visible = false
				get_parent().get_node("Animal").visible = false
				position = Vector2(790,900)						
			return


func _on_ViewInfo_pressed():
	if get_parent().get_node("MidleMenu").visible == false:
		update_all_count()
		get_parent().get_node("MidleMenu").visible = true
	else:	
		get_parent().get_node("MidleMenu").visible = false
func save_to_file():
	player_stats_save()
func load_from_file():
	get_parent().load_data_world()
func load_from_server():
	world_now_load = true
	if Global_DataParser.world_already_load == false and (!get_tree().is_network_server()) and is_network_master():
#	if Global_DataParser.world_already_load == false and is_network_master():
#		var _world_data = Global_DataParser._new_data	
#		load_data_world_client(_world_data)
#		rpc("load_data_world_server")
		load_data_world_client(Global_DataParser._new_data)
		Global_DataParser.world_already_load = true	
	world_now_load = false	


func _on_LoadServer_pressed():
	$MidleMenu.visible = false	
	$MidleMenu2.visible = false	
	if is_network_master():	
		show_info("Loading world from server")
		print("Loading world from server")	
		load_from_server()
		show_info("Loading world from server completed")
		print("Loading world from server completed")	

func _on_LoadFile_pressed():
	$MidleMenu.visible = false	
	$MidleMenu2.visible = false	
	if is_network_master():	

		show_info("Loading world from local file")
		print("Loading world from local file")
		load_from_file()
		show_info("Loading world from local file completed")
		print("Loading world from local file completed")	


func _on_SaveFile_pressed():
	$MidleMenu.visible = false	
	$MidleMenu2.visible = false	
	if is_network_master():	

		show_info("Saving world to local file")	
		print("Saving world to local file")
		save_to_file()
		show_info("Saving world to local file completed")
		print("Saving world to local file completed")


func _on_Enter_pressed():
	$ActionMenu.visible = false
	Action_Multi()


func _on_Trade_pressed():
	$ActionMenu.visible = false	
	_on_InventoryButton_button_down()


func _on_Population_pressed():
#	if last_build_id !=0:
	if area_type_id.get_parent().has_method('set_what_do'):
		var a = area_type_id.get_parent()
		a.set_what_do(1)
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
func _on_Mining_pressed():
#	if last_build_id !=0:
	if area_type_id.get_parent().has_method('set_what_do'):
		var a = area_type_id.get_parent()
		a.set_what_do(0)
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
func _on_Defence_pressed():
#	if last_build_id !=0:
	if area_type_id.get_parent().has_method('set_what_do'):
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
#	if area_type_id.get_parent().has_method('set_what_do'):
		var a = area_type_id.get_parent()
		a.set_what_do(2)
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))	



func _on_Guard_pressed():
#	if last_build_id !=0:
	if area_type_id.get_parent().has_method('set_what_do'):
		var a = area_type_id.get_parent()
		a.set_what_do(3)
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
func _on_Research_pressed():
#	if last_build_id !=0:
	if area_type_id.get_parent().has_method('set_what_do'):
		var a = area_type_id.get_parent()
		a.set_what_do(4)
		SoundPlayer.play(preload("res://audio/sounds/click.wav"))	



func _on_MenuButton9_pressed():  #вызываем обычного юнита
			SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
			if $UnitMenu.visible == true:
				$UnitMenu.visible = false
			else:
				$UnitMenu.visible = true
				update_all_count()
#				get_parent().get_node("MidleMenu").visible = true
				$UnitMenu.visible = true
#	attack7(Global_DataParser.join_race)
#	attack15(Global_DataParser.join_race)


func _on_Unit1_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	unit1(Global_DataParser.join_race)
	


func _on_Unit2_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	unit2(Global_DataParser.join_race)


func _on_Unit3_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	unit3(Global_DataParser.join_race)


func _on_Unit4_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	unit4(Global_DataParser.join_race)


func _on_Unit_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	call_unit(Global_DataParser.join_race)


func _on_Unit5_pressed():

	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	unit5(Global_DataParser.join_race)


func _on_Unit6_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	
	$UnitMenu.visible = false
	unit6(Global_DataParser.join_race)


func _on_EMPIRE_pressed():
	SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
	$WorldMap.visible = false
#	teleport_neutral() 
	teleport_empire(1) 

func _on_DarkEMPIRE_pressed():
	SoundPlayer.play(preload("res://audio/sounds/click.wav"))	 
	$WorldMap.visible = false
	teleport_dark() 	


func _on_NEUTRAL_pressed():
	SoundPlayer.play(preload("res://audio/sounds/preload_sfx/fire_cast1.wav"))	
	$WorldMap.visible = false
	teleport_neutral() 


func _on_Set_Hardcore_pressed():
	Global_DataParser.hardlevel = 1
	hardcore_level = 1
	var a = $MidleMenu2/Panel	
	a.get_node("HardModeLevel").text  = str(Global_DataParser.hardlevel)

func _on_Set_EasyMode_pressed():
	Global_DataParser.hardlevel = 0
	hardcore_level = 0
	var a = $MidleMenu2/Panel	
	a.get_node("HardModeLevel").text  = str(Global_DataParser.hardlevel)

func _on_Set_Singleplay_pressed():
	Global_DataParser.singleplay = true


func _on_Set_Multiplay_pressed():
	Global_DataParser.singleplay = false


func _on_GiveEnergy_pressed():
#	if build_area_type_id.has_method('GiveEnergy'):
		if is_network_master() and (Global_DataParser.energy > (1000 * Global_DataParser.level)):		
			Global_DataParser.reduce_energy((1000 * Global_DataParser.level))
			build_area_type_id.GiveEnergy((1000 * Global_DataParser.level))
			return 1

func _on_TakeEnergy_pressed():
		var level
		var energy = Global_DataParser.energy
		level = 10 * Global_DataParser.level
#	if build_area_type_id.has_method('TakeEnergy'):
		if is_network_master():
			print("============================energy before:")
			print(energy)					
			energy = build_area_type_id.TakeEnergy(level)
			print("============================energy taked:")
			print(energy)
			Global_DataParser.energy += energy
			return 1
func _on_Upgrade_pressed():
	if area_type_id.has_method('UpgradeTown'):
		build_area_type_id.UpgradeTown()
