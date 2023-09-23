extends Node

# # localhost
#var DEFAULT_IP   = '192.168.42.129' # localhost
#var DEFAULT_IP   = '10.42.1.1' # localhost
var DEFAULT_IP   = '127.0.0.1' # localhost
const DEFAULT_PORT = 27015
const MAX_PLAYERS = 16  #not including host
#var DEFAULT_IP   = '46.211.150.48' # localhost

var players = { }
var self_data = { name = '', position = Vector2(460, 280), race = 2 }
var self_npc_data = { name = '', position = Vector2(560, 280) }

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
#	DEFAULT_IP = Global_DataParser.DEAFAULT_IP

func create_server(player_nickname, race):
	print(Global_DataParser.DEFAULT_IP)
	print(DEFAULT_IP)	
	self_data.name = player_nickname
	self_data.race = race	
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
#	print("выбрана раса")
#	print(race)
	Global_DataParser.join_race = race
#	print(Global_DataParser.join_race)	


func connect_to_server(player_nickname,race):
	print(Global_DataParser.DEFAULT_IP)
	print(DEFAULT_IP)	
	self_data.name = player_nickname
#
	get_tree().connect('connected_to_server', self, '_connected_to_server')
#		Global_DataParser.singleplay = true	
#
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(DEFAULT_IP, DEFAULT_PORT)
	get_tree().set_network_peer(peer)
#запоминаем расу
#	print("выбрана раса")
#	print(race)
	Global_DataParser.join_race = race
#	print(Global_DataParser.join_race)	
func _connected_to_server():
	Global_DataParser.singleplay = false		
	var local_player_id = get_tree().get_network_unique_id()
	players[local_player_id] = self_data
	rpc('_send_player_info', local_player_id, self_data)

func _on_player_disconnected(id):
	players.erase(id)

func _on_player_connected(connected_player_id):
	var local_player_id = get_tree().get_network_unique_id()
	if not(get_tree().is_network_server()):
		rpc_id(1, '_request_player_info', local_player_id, connected_player_id)

remote func _request_player_info(request_from_id, player_id):
	if get_tree().is_network_server():
# получаем состояние мира
		get_parent().get_node("Game").get_data_npc()
		var _world_data = Global_DataParser._new_data		
		rpc_id(request_from_id, '_send_player_info', player_id, players[player_id])
		rpc_id(request_from_id, '_send_world_info', _world_data) # отправляем состояние мира
func rpc_spawn_object(request_from_id,object_path,spawn_position,object_name,object_data:Dictionary = {}):
	if not get_tree().is_network_server():
		var object_data1:Dictionary = object_data
		rpc_id(1,"spawn_object",request_from_id,object_path,spawn_position,object_name,Global_DataParser.join_race,Global_DataParser.location_number, object_data1)

remote func spawn_object(request_from_id,object_path,spawn_position,object_name1,race,location_number, object_data:Dictionary = {}):
	if get_tree().is_network_server():
		var object_name = object_name1 + "_" + str(Global_DataParser.rng.randi())	
		var object_data1:Dictionary = object_data
		spawn_new_object_on_server(object_path,spawn_position,object_name,race,location_number,object_data1) # создаём обьект на сервере
		for peer_id in players:
			if( peer_id != 1):			
				rpc_id(peer_id,"spawn_new_object",object_path,spawn_position,object_name,race,location_number,object_data1) #создаём обьект на клиентах
	print("spawned object on server and client end OK")
# A function to be used if needed. The purpose is to request all players in the current session.
remote func spawn_new_object(object_path,spawn_position,object_name,race,location_number,object_data:Dictionary = {}):
	if not get_tree().is_network_server():
		var town = load(object_path).instance()
		town.name = object_name # + "_" + str(Global_DataParser.rng.randi())
#		$'/root/Game/Empire'.add_child(town)
		add_npc_on_location(town,location_number,object_name)
		town.position = spawn_position
		if town.has_method('prepare_data_start'):
			town.prepare_data_start(object_data)		
#		Global_DataParser.inc_mobs(10,1)
		print("spawned on client new object OK")
		print(spawn_position)
		print(object_name)
		print(object_path)						
	else:
#		spawn_new_object(object_path,spawn_position,object_name,race,location_number)
		print("this is server")
	print("spawned new OK")
func spawn_new_object_on_server(object_path,spawn_position,object_name,race,location_number,object_data:Dictionary = {}):
#	if get_tree().is_network_server():
		var town = load(object_path).instance()
		town.name = object_name # + "_" + str(Global_DataParser.rng.randi())
#		$'/root/Game/Empire'.add_child(town)
		add_npc_on_location(town,location_number,object_name)
		town.position = spawn_position
		if town.has_method('prepare_data_start'):
			town.prepare_data_start(object_data)
#		Global_DataParser.inc_mobs(10,1)
		print("spawned on server new object OK")
		print(spawn_position)
		print(object_name)
		print(object_path)
func add_npc_on_location(object,location_number,object_name):
		if location_number == 1:
			$'/root/Game/Empire'.add_child(object)
			get_parent().get_node("Game").get_node("1").get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Builded object:\n" + object_name + "\n"			
			
		elif location_number == 2:
			$'/root/Game/Dark'.add_child(object)
			get_parent().get_node("Game").get_node("1").get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Builded object:\n" + object_name + "\n"			

		elif location_number == 3:
			$'/root/Game/Neutral'.add_child(object)
			get_parent().get_node("Game").get_node("1").get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Builded object:\n" + object_name + "\n"			

#		else:
#			get_parent().get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Failure. I can not do it here!:\n" + "\n"			

remote func _request_players(request_from_id):
	if get_tree().is_network_server():
		for peer_id in players:
			if( peer_id != request_from_id):
				rpc_id(request_from_id, '_send_player_info', peer_id, players[peer_id])
remote func _send_world_info(_world_data):
	Global_DataParser.singleplay = false
	Global_DataParser._new_data = _world_data
	Global_DataParser.world_already_load = false	
remote func _send_player_info(id, info):
	players[id] = info
	var new_player

	new_player = load('res://Scenes/Player.tscn').instance()


	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Game/'.add_child(new_player)
	new_player.init(info.name, info.position, true)
#	new_player.init(info.name, info.position, true, info.race)
func update_position(id, position):

	players[id].position = position
