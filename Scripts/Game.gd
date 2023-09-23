extends Node

func get_player():
	if has_node("Player"):
#		print ("get_player Admin")
		return $Player
#	if has_node("Player"):
#		return $Admin
#		return $Player
	else:
#		print ("get_player Player")
#
		return false
func get_playerNPC():
	if has_node("PlayerNPC"):
#		print ("get_player Admin")
		return $PlayerNPC
#	if has_node("Player"):
#		return $Admin
#		return $Player
	else:
#		print ("get_player Player")
#
		return false
#func load_data_bag_player(_name):
#	var _bag_data = Utility.loadDictionary(GlobalData.path + "player_"+ str(_name) + "_bag.json")
#	return	_bag_data	
#	Utility.saveDictionary(GlobalData.path + "player_"+ str($NicknameLabel.text) + "_bag.json", _data_player)		
func load_data_world():
	var _world_data = Utility.loadDictionary(GlobalData.path + "player_"+ str(Global_DataParser._player_name) + "_world.json")
	load_data_world_from_file(_world_data)
func load_data_world_from_server():
	var _world_data = {}
	load_data_world_from_file(_world_data)	
func load_data_world_from_file(_world_data):
	if Global_DataParser.location_number == 1:
		print("add  empire")
		load_data_npc(_world_data,"Empire")
	elif Global_DataParser.location_number == 2:
		print("add  darkempire")
		load_data_npc(_world_data,"DarkEmpire")
	elif Global_DataParser.location_number == 3:
		print("add neutral")		
		load_data_npc(_world_data,"Neutral")

	print("add animal")		
	load_data_npc(_world_data,"Animal")

func load_data_npc(_world_data,fraction):
	if _world_data == null:
		return
	var i = 0
	for fract in _world_data:
		
		if fract == fraction:
			for child in _world_data[fraction]:
#				if get_tree().is_network_server():				
#					rpc("spawn_object",child,fraction)
#				else:
					spawn_object(child,fraction)
			print("added")
			print(fraction)		
			print(i)
			i += 1
		else:
			print("Fraction not found:")
			print(fraction)	
	print (i)		
	return true
#sync 
func spawn_object(child,fraction):
	var object = load(child["whoiam"]).instance()

	object.name = child["nickname"] + "_" + str(Global_DataParser.rng.randi())
	if fraction	== "Empire":	
		$'/root/Game/Empire'.add_child(object)
		print("added empire")
	if fraction	== "DarkEmpire":	
		$'/root/Game/Dark'.add_child(object)
		print("added dark empire")		
	if fraction	== "Neutral":	
		$'/root/Game/Neutral'.add_child(object)
		print("added neutral")
	if fraction	== "Animal":	
		$'/root/Game/Animal'.add_child(object)
		print("added animal")		
	object.position.x = child["positionX"]

	print("positionX:")
	print(object.position.x)
	object.position.y = child["positionY"]
	print("positionY:")		
	print(object.position.y)
	object.set_data(child)
#	object.position.x = child["positionX"]
#	object.position.y = child["positionY"]		
	print("object:")
	print(child["whoiam"])
			
func get_data_npc():

#	var node = $Animal
#	var race = _new_data["Animal"]
	get_data_npc_empire()
#	node = $Empire
#	race = _new_data["Empire"]
	get_data_npc_darkempire()
	get_data_npc_darkfortress()	
#	node = $DarkEmpire
#	race = _new_data["Neutral"]
	get_data_npc_neutral()
#	node = $Neutral
#	race = _new_data["Neutral"]	
	get_data_npc_animal()
	return Global_DataParser._new_data
func get_data_npc_empire():
#	node = $Empire
	var val
#	var val1 = a.get_children()
	var i = 0
	for child in  $Empire.get_children():
					if child.has_method('get_data'):					
						val = child.get_data()
						if val != null:
							Global_DataParser._new_data["Empire"].append(val) 
						i += 1
	print("added empire")
	print (i)		
	return Global_DataParser._new_data
func get_data_npc_neutral():
#	node = $Neutral
	var val
#	var val1 = a.get_children()
	var i = 0
	for child in $Neutral.get_children():
					if child.has_method('get_data'):					
						val = child.get_data()
						if val != null:
							Global_DataParser._new_data["Neutral"].append(val) 
						i += 1
	print("added neutral")
	print (i)		
	return Global_DataParser._new_data
func get_data_npc_darkempire():
#	node = $DarkEmpire
	var val
#	var val1 = a.get_children()
	var i = 0
	for child in $Dark.get_children():
					if child.has_method('get_data'):					
						val = child.get_data()
						if val != null:
							Global_DataParser._new_data["DarkEmpire"].append(val) 
						i += 1
	print("added darkempire")
	print (i)		
	return Global_DataParser._new_data
func get_data_npc_darkfortress():
#	node = $DarkEmpire
	var val
#	var val1 = a.get_children()
	var i = 0
	for child in $Dark.get_children():
					if child.has_method('get_data'):					
						val = child.get_data()
						if val != null:
							Global_DataParser._new_data["DarkEmpire"].append(val) 
						i += 1
	print("added darkempire")
	print (i)		
	return Global_DataParser._new_data

func get_data_npc_animal():
#	node = $Animal
	var val
#	var val1 = a.get_children()
	var i = 0
	for child in $Animal.get_children():
					if child.has_method('get_data'):					
						val = child.get_data()
						if val != null:
							Global_DataParser._new_data["Animal"].append(val) 
						i += 1
	print("added animal")					
	print (i)		
	return Global_DataParser._new_data

func _ready():
#	$Timer.start(4)	
	set_process(false)
	set_process_input(false)
	
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://Scenes/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_child(new_player)
	var info = Global_Network.self_data
	new_player.init(info.name, info.position, false)
	loadPlayerInfo()
	if get_tree().is_network_server():
		Global_DataParser.singleplay = false
#	if 	Global_DataParser.singleplay == true:	
#		load_data_world()
	
	if(is_network_master()):	
		if Global_DataParser.singleplay == false:
			if get_tree().is_network_server():		
#				load_data_world()
				return
#			else:
#				load_data_world_local()
	
#		else:
#			load_data_world()
						
func loadPlayerInfo():
	if GlobalData.game_status.runs == 0:
	#	Utility.saveDictionary(GlobalData.path + "player_info.json", GlobalData.player_info)
		Utility.saveDictionary(GlobalData.path + "player_"+ Global_DataParser._player_name + "_info.json", GlobalData.player_info)
		return
	var data = Utility.loadDictionary(GlobalData.path + "player_"+ Global_DataParser._player_name + "_info.json")
	if data:
		Utility.dictionaryCpy(GlobalData.player_info, data)
	var _data_player =	Utility.loadDictionary(GlobalData.path + "player_"+ Global_DataParser._player_name + "_bag.json")
	if _data_player:
		Utility.dictionaryCpy(GlobalData.player_info, _data_player)




func _on_player_disconnected(id):
	get_node(str(id)).queue_free()


func _on_server_disconnected():
	get_tree().change_scene('res://Scenes/Menu.tscn')





func _on_Timer_timeout():
	set_process(false)
	if(!is_network_master()):
		Global_DataParser.singleplay = true
#		load_data_world()	
	else:
		Global_DataParser.singleplay = false		
