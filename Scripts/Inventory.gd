extends Control


const INVENTORY_MAX_SLOTS = 100


onready var _item_list_1 = $Panel/ItemList
onready var _item_list_2 = $Panel/ItemList2

onready var _item_list_label_1 = $Panel/ItemListLabel
onready var _item_list_label_2 = $Panel/ItemList2Label

var url_data_player
var url_data_other
var url_data:String

puppet var data_player:Dictionary
puppet var data_other:Dictionary

onready var button_multi = $Panel/Button
onready var button_multi_use = $Panel/Use


func _ready():
	set_process(false)
	set_process_input(false)
	
	visible = false
	_item_list_2.visible = false
	_item_list_label_2.visible = false
	set_center_item_visible(false)
# не используется сейчас
#заполняем инвентарь игрока и поселения  village
func load_data_empire(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data empire1 player ")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 25}
			elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 10}
			elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
			elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 10}
			elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 2}
			elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
			elif(int(slot) == 4 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "51", "amount": 1}

#			elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
#			elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
#			elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
#			elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "4", "amount": 20}
#			elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "14", "amount": 10}
#			elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "9", "amount": 1}
#			elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "7", "amount": 50}
#			elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
#			elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "18", "amount": 25}
#			elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "23", "amount": 1}
#			elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
#			elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "13", "amount": 10}
#			elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "22", "amount": 25}
#			elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "16", "amount": 5}
#			elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "22", "amount": 25}
#			elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "23", "amount": 25}
#			elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "2", "amount": 50}
#			elif(int(slot) == 22 && item_list_label == "Player" && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "21", "amount": 5}

#			elif(int(slot) == 2 && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "18", "amount": 1500}
#			elif(int(slot) == 3 && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "19", "amount": 1500}

#			elif(int(slot) == 4 && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
#			elif(int(slot) == 5&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "51", "amount": 1}
#			elif(int(slot) == 6&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "17", "amount": 102}
#			elif(int(slot) == 7&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "4", "amount": 103}
#								
			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 500}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1000}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other = data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data
# не используется сейчас
#заполняем инвентарь игрока и поселения  village
func load_data_dark1(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data dark")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 200}
			elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 35}
			elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 2}
			elif(int(slot) == 4&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
			elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 7}
			elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
			elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 1}
			elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 30}
			elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
			elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
			elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
			elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 1}
			elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 1}
			elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 1}
			elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
			elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 1}
			elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 1}
			elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
			elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
			elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 25}
			elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 100}
			elif(int(slot) == 22 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "21", "amount": 5}

			elif(int(slot) == 2 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 15}
			elif(int(slot) == 3 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 1}

			elif(int(slot) == 4 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 5}
			elif(int(slot) == 5&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "16", "amount": 2}
			elif(int(slot) == 6&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 1}
			elif(int(slot) == 7&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 103}
								
			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 500}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1000}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data
#заполняем инвентарь игрока темного пантеона
func load_data_dark(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data exile player")
	print(filename)

	var data:Dictionary
	var url_bag_data = GlobalData.path + "player_" + str(filename) + "_bag.json"
	var _bag_data = Utility.loadDictionary(url_bag_data)
	if _bag_data == null:
		url_data = "res://Database//player_" + str(filename)  + "_bag.json"
		data = Global_DataParser.load_data(url_data)
		print("load data exile from res/database/player_name_bag.json")	
#	print(item_list_label)
#	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
#	if(is_save_data):
#		print("save data")
#		Global_DataParser.write_data(url_data, data_save)
	
#	var data:Dictionary = Global_DataParser.load_data(url_data)
	
		if (data.empty() || is_clear_items && !is_save_data):
			var dict:Dictionary = {"inventory":{}}
			print("generation data exile for player")		
			for slot in range (0, INVENTORY_MAX_SLOTS):
				if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "1", "amount": 200}
				elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 35}
				elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 2}
				elif(int(slot) == 4&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
				elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "15", "amount": 7}
				elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
				elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
				elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 1}
				elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 30}
				elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
				elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
				elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
				elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 1}
				elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 1}
				elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "19", "amount": 1}
				elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
				elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "25", "amount": 1}
				elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 1}
				elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
				elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
				elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "25", "amount": 25}
				elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 100}
				elif(int(slot) == 22 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "21", "amount": 5}

				elif(int(slot) == 2 && !is_clear_items):
					print("generation data exile for other name")					
					dict["inventory"][str(slot)] = {"id": "18", "amount": 10}
				elif(int(slot) == 3 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "19", "amount": 1}

				elif(int(slot) == 4 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "15", "amount": 5}
				elif(int(slot) == 5&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "16", "amount": 1}
				elif(int(slot) == 6&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "17", "amount": 2}
				elif(int(slot) == 7&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
									
				elif(int(slot) == 0 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 50}
				elif(int(slot) == 1&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "1", "amount": 100}

				else:
					dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
	#		Global_DataParser.write_data(url_data, dict)
			data = dict
			Utility.saveDictionary(url_bag_data, dict)
			print ("save data exile to usr/player_name.json")
			_bag_data = Utility.loadDictionary(url_bag_data)
			print ("save and load data exile completed")			
		else:
			_bag_data = data	
#	print(_bag_data)
	else:
		data = _bag_data	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data
	
#заполняем инвентарь игрока светлого пантеона богов
func load_data_empire2(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data empire2 player")
	print(filename)

	var data:Dictionary
	var url_bag_data = GlobalData.path + "player_" + str(filename) + "_bag.json"
	var _bag_data = Utility.loadDictionary(url_bag_data)
	if _bag_data == null:
		url_data = "res://Database//player_" + str(filename)  + "_bag.json"
		data = Global_DataParser.load_data(url_data)
		print("load data exile from res/database/player_name_bag.json")	
#	print(item_list_label)
#	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
#	if(is_save_data):
#		print("save data")
#		Global_DataParser.write_data(url_data, data_save)
	
#	var data:Dictionary = Global_DataParser.load_data(url_data)
	
		if (data.empty() || is_clear_items && !is_save_data):
			var dict:Dictionary = {"inventory":{}}
			print("generation data exile for player")		
			for slot in range (0, INVENTORY_MAX_SLOTS):
				if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "1", "amount": 100}
				elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 30}
				elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "8", "amount": 5}
				elif(int(slot) == 4&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "9", "amount": 1}
				elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "10", "amount": 1}
				elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
				elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
				elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
				elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 20}
				elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "14", "amount": 10}
				elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "9", "amount": 1}
				elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "7", "amount": 50}
				elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
				elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "18", "amount": 25}
				elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "23", "amount": 1}
				elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
				elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "13", "amount": 10}
				elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "22", "amount": 25}
				elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "16", "amount": 5}
				elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "22", "amount": 25}
				elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "23", "amount": 25}
				elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 50}
				elif(int(slot) == 22 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "21", "amount": 5}

				elif(int(slot) == 2 && !is_clear_items):
					print("generation data exile for other name")					
					dict["inventory"][str(slot)] = {"id": "18", "amount": 10}
				elif(int(slot) == 3 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "19", "amount": 1}

				elif(int(slot) == 4 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "15", "amount": 5}
				elif(int(slot) == 5&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "16", "amount": 1}
				elif(int(slot) == 6&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "17", "amount": 2}
				elif(int(slot) == 7&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
									
				elif(int(slot) == 0 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 50}
				elif(int(slot) == 1&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "1", "amount": 100}

				else:
					dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
	#		Global_DataParser.write_data(url_data, dict)
			data = dict
			Utility.saveDictionary(url_bag_data, dict)
			print ("save data exile to usr/player_name.json")
			_bag_data = Utility.loadDictionary(url_bag_data)
			print ("save and load data exile completed")			
		else:
			_bag_data = data	
#	print(_bag_data)
	else:
		data = _bag_data	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data

#заполняем инвентарь игрока нейтрального пантеона богов 
func load_data_exile(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data exile player")
	print(filename)
	var empt:Dictionary = {}
	var data:Dictionary = {"inventory":{"id": "1", "amount": 50}}
	var url_bag_data = GlobalData.path + "player_" + str(filename) + "_bag.json"
	var _bag_data:Dictionary = Utility.loadDictionary(url_bag_data)
	print("bag is :{}")
	print(_bag_data)	
	print(empt)		
	if _bag_data == empt:
		print("bag is empty {}")
		print(_bag_data)
	if _bag_data == null:
		url_data = "res://Database//player_" + str(filename)  + "_bag.json"
#		data = Global_DataParser.load_data(url_data)
		data ={}
		var data_not = Utility.loadDictionary(url_data)
		print("load data exile from res/database/player_name_bag.json")	
		print(url_data)
#	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
#	if(is_save_data):
#		print("save data")
#		Global_DataParser.write_data(url_data, data_save)
	
#	var data:Dictionary = Global_DataParser.load_data(url_data)
		if data_not == null:	
#		if (data == {}): # || is_clear_items && !is_save_data):
			var dict:Dictionary = {"inventory":{}}
			print("generation data exile for player")		
			for slot in range (0, INVENTORY_MAX_SLOTS):
				if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "1", "amount": 500}
				elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 40}
				elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
				elif(int(slot) == 4&& item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
				elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "10", "amount": 1}
				elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
				elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
				elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "19", "amount": 1}
				elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "7", "amount": 1}
				elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
				elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 10}
				elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 50}
				elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "17", "amount": 1}
				elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
				elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "19", "amount": 1}
				elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
				elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "21", "amount": 3}
				elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "22", "amount": 1}
				elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "23", "amount": 1}
				elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
				elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "25", "amount": 25}
				elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 10}

				elif(int(slot) == 2 && !is_clear_items):
					print("generation data exile for other name")					
					dict["inventory"][str(slot)] = {"id": "18", "amount": 10}
				elif(int(slot) == 3 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "19", "amount": 1}

				elif(int(slot) == 4 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "15", "amount": 5}
				elif(int(slot) == 5&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "16", "amount": 1}
				elif(int(slot) == 6&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "17", "amount": 2}
				elif(int(slot) == 7&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
									
				elif(int(slot) == 0 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 50}
				elif(int(slot) == 1&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "1", "amount": 100}

				else:
					dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
	#		Global_DataParser.write_data(url_data, dict)
			data = dict
			Utility.saveDictionary(url_bag_data, dict)
			print ("save data exile to usr/player_name.json")
			_bag_data = Utility.loadDictionary(url_bag_data)
			print ("save and load data exile completed")			
		else:
			_bag_data = data	
#	print(_bag_data)
	else:
		data = _bag_data	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data



#заполняем инвентарь игрока при легком уровне и поселения "город-замок"
func load_data_builds(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 100}
			elif(int(slot) == 1 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 1}
			elif(int(slot) == 2 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 10}
			elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
			elif(int(slot) == 4 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "7", "amount": 5}
			elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 2}
			elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 5}
			elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
			elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
			elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "13", "amount": 1}
			elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "14", "amount": 1}
			elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 1}
			elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "16", "amount": 2}
			elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 1}
			elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
			elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 1}
			elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 1}


			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 100}
			elif(int(slot) == 1 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 5}
			elif(int(slot) == 2 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 10}
			elif(int(slot) == 3 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 4}
			elif(int(slot) == 4  && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 4}
			elif(int(slot) == 5 &&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 2}
			elif(int(slot) == 6 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "7", "amount": 10}
			elif(int(slot) == 7 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 5}
			elif(int(slot) == 8 &&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 2}
			elif(int(slot) == 9 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 2}
			elif(int(slot) == 10 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
			elif(int(slot) == 11 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
			elif(int(slot) == 12 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "13", "amount": 5}
			elif(int(slot) == 13 &&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "14", "amount": 2}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data
# заполняем инвентарь торговца 	
func load_data(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data shop")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	print(url_data)
	Global_DataParser.IS_LOAD_FROM_FILE_ENABLED = true	
	if(is_save_data):
		print("save data")

		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 100}
			elif(int(slot) == 1 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 50}
			elif(int(slot) == 2 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 100}
			elif(int(slot) == 3 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 14}
			elif(int(slot) == 4 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 4}
			elif(int(slot) == 5 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 2}
			elif(int(slot) == 6 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "7", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 5}
			elif(int(slot) == 8 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 2}
			elif(int(slot) == 9 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 2}
			elif(int(slot) == 10 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
			elif(int(slot) == 11 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
			elif(int(slot) == 12 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "13", "amount": 2}
			elif(int(slot) == 13 && item_list_label == "Shop" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "14", "amount": 5}

			elif(int(slot) == 0 && !is_clear_items):
				print("load bag")
				dict["inventory"][str(slot)] = {"id": "3", "amount": 5}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 10}
			elif(int(slot) == 2  && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 100}
			elif(int(slot) == 3 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 14}
			elif(int(slot) == 4 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 4}
			elif(int(slot) == 5 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 2}
			elif(int(slot) == 6 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 2}


			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data


#заполняем инвентарь игрока и поселения  village
func load_data_village(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data village")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 100}
			elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 25}
			elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 2}
			elif(int(slot) == 4&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 1}
			elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 1}
			elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
			elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "13", "amount": 1}
			elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 1}
			elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
			elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 1}
			elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "16", "amount": 1}
			elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "14", "amount": 1}
			elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
			elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 3}
			elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
			elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "21", "amount": 1}
			elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "22", "amount": 1}
			elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "23", "amount": 1}
			elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
			elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 5}
			elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 10}

			elif(int(slot) == 0 && !is_clear_items):
				print("load village")
				dict["inventory"][str(slot)] = {"id": "1", "amount": 10}
			elif(int(slot) == 1 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 5}

			elif(int(slot) == 2 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 5}
			elif(int(slot) == 3&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 2}
			elif(int(slot) == 4&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "51", "amount": 1}
#			elif(int(slot) == 5&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
								
#			elif(int(slot) == 6 && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "3", "amount": 5}
#			elif(int(slot) == 7&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "1", "amount": 10}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data
	
#заполняем инвентарь npc
func load_datanpc(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("new load data bag_npc boss")
	print(filename)
	var data:Dictionary
	var url_bag_data = GlobalData.path + str(filename) + "_bag.json"
	var _bag_data = Utility.loadDictionary(url_bag_data)
	if _bag_data == null:
		url_data = "res://Database//" + str(filename)  + "_bag.json"
		data = Global_DataParser.load_data(url_data)
	
		if (data.empty()):
			var dict:Dictionary = {"inventory":{}}
			for slot in range (0, INVENTORY_MAX_SLOTS):
				if(int(slot) == 0 && !is_clear_items):
					print("load bag npc boss")
					dict["inventory"][str(slot)] = {"id": "1", "amount": 4}
				elif(int(slot) == 1 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 2}

				elif(int(slot) == 2 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 3}
				elif(int(slot) == 3&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "5", "amount": 1}
				elif(int(slot) == 4&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "51", "amount": 1}
				elif(int(slot) == 5&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 1}
									
				elif(int(slot) == 6 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "14", "amount": 1}
				elif(int(slot) == 7&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "11", "amount": 1}

				else:
					dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
#			Global_DataParser.write_data(url_data, dict)
#			_bag_data = dict	
			Utility.saveDictionary(url_bag_data, dict)
#			print (_bag_data)
			_bag_data = Utility.loadDictionary(url_bag_data)
#			print (_bag_data)			
		else:
			_bag_data = data	
#	print(_bag_data)
	else:
		data = _bag_data
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= _bag_data
		load_items(_item_list_2, _bag_data)
	
	return _bag_data
func load_datanpc_old(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
		
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.IS_LOAD_FROM_FILE_ENABLED = true
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 100}
			elif(int(slot) == 1&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 25}
			elif(int(slot) == 2&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 2}
			elif(int(slot) == 4&& item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 1}
			elif(int(slot) == 5 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 1}
			elif(int(slot) == 6 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "6", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 1}
			elif(int(slot) == 3 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "13", "amount": 1}
			elif(int(slot) == 9 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 1}
			elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
			elif(int(slot) == 12 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 1}
			elif(int(slot) == 13 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "16", "amount": 1}
			elif(int(slot) == 14 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "14", "amount": 1}
			elif(int(slot) == 15 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 1}
			elif(int(slot) == 16 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 3}
			elif(int(slot) == 17 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "20", "amount": 1}
			elif(int(slot) == 10 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "21", "amount": 1}
			elif(int(slot) == 11 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "22", "amount": 1}
			elif(int(slot) == 18 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "23", "amount": 1}
			elif(int(slot) == 19 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "24", "amount": 1}
			elif(int(slot) == 20 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 5}
			elif(int(slot) == 21 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 10}

			elif(int(slot) == 0 && !is_clear_items):
				print("load bag npc")
				dict["inventory"][str(slot)] = {"id": "1", "amount": 10}
			elif(int(slot) == 1 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 5}

			elif(int(slot) == 2 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 5}
			elif(int(slot) == 3&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 2}
			elif(int(slot) == 4&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "51", "amount": 1}
#			elif(int(slot) == 5&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
								
#			elif(int(slot) == 6 && !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "3", "amount": 5}
#			elif(int(slot) == 7&&  !is_clear_items):
#				dict["inventory"][str(slot)] = {"id": "1", "amount": 10}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data
	
#заполняем магическую башню
func load_data_town(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data village")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 300}
			elif(int(slot) == 1&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 30}
			elif(int(slot) == 2&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 25}
			elif(int(slot) == 4&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 10}
			elif(int(slot) == 5 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 5}
			elif(int(slot) == 6 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 10}
			elif(int(slot) == 3 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 50}
			elif(int(slot) == 8 && item_list_label == "Player" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "21", "amount": 5}
								
			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1500}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 101}
			elif(int(slot) == 2&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 102}
			elif(int(slot) == 3&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 103}
			elif(int(slot) == 4 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 1500}
			elif(int(slot) == 5&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "16", "amount": 101}
			elif(int(slot) == 6&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 102}
			elif(int(slot) == 7&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 103}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data

#заполняем крепость
func load_data_fortress(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data village")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 300}
			elif(int(slot) == 1&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 30}
			elif(int(slot) == 2&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 25}
			elif(int(slot) == 4&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 10}
			elif(int(slot) == 5 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 5}
			elif(int(slot) == 6 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 10}
			elif(int(slot) == 3 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 50}
								
			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 150}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 5}
			elif(int(slot) == 2&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 11}
			elif(int(slot) == 3&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
			elif(int(slot) == 4 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 1}
			elif(int(slot) == 5&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 1}
			elif(int(slot) == 6&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 20}
			elif(int(slot) == 7&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "25", "amount": 1}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data

#заполняем магическую башню
func load_data_capital(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data village")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 2300}
			elif(int(slot) == 1&& item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 230}
			elif(int(slot) == 2&& item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 125}
			elif(int(slot) == 3&& item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 105}
			elif(int(slot) == 4 && item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 15}
			elif(int(slot) == 5 && item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 11}
			elif(int(slot) == 6 && item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 12}
			elif(int(slot) == 7 && item_list_label == "Capital" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 52}
								
			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1500}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 101}
			elif(int(slot) == 2&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 102}
			elif(int(slot) == 3&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 103}
			elif(int(slot) == 4 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "15", "amount": 1500}
			elif(int(slot) == 5&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "16", "amount": 101}
			elif(int(slot) == 6&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 102}
			elif(int(slot) == 7&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 103}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data

#заполняем магическую башню
func load_data_castle(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("load data village")
	print(filename)
	print(item_list_label)
	url_data = "res://Database//data_" + item_list_label.to_lower() + "_" + filename + ".json"
	
	if(is_save_data):
		print("save data")
		Global_DataParser.write_data(url_data, data_save)
	
	var data:Dictionary = Global_DataParser.load_data(url_data)
	
	if (data.empty() || is_clear_items && !is_save_data):
		var dict:Dictionary = {"inventory":{}}
		for slot in range (0, INVENTORY_MAX_SLOTS):
			if(int(slot) == 0&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 300}
			elif(int(slot) == 1&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 30}
			elif(int(slot) == 2&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "8", "amount": 25}
			elif(int(slot) == 4&& item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "9", "amount": 10}
			elif(int(slot) == 5 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "10", "amount": 5}
			elif(int(slot) == 6 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "11", "amount": 1}
			elif(int(slot) == 7 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "12", "amount": 10}
			elif(int(slot) == 3 && item_list_label == "Town" && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "7", "amount": 50}
								
			elif(int(slot) == 0 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "1", "amount": 1500}
			elif(int(slot) == 1&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "3", "amount": 101}
			elif(int(slot) == 2&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "2", "amount": 102}
			elif(int(slot) == 3&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "4", "amount": 103}
			elif(int(slot) == 4 && !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "5", "amount": 1500}
			elif(int(slot) == 5&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "19", "amount": 101}
			elif(int(slot) == 6&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "17", "amount": 102}
			elif(int(slot) == 7&&  !is_clear_items):
				dict["inventory"][str(slot)] = {"id": "18", "amount": 103}

			else:
				dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
		Global_DataParser.write_data(url_data, dict)
		data = dict
	
	if(item_list_label == "Player"):
		_item_list_label_1.text = "Inventory"
		url_data_player = url_data
		data_player = data
		load_items(_item_list_1, data)
	else:
		_item_list_label_2.text = item_list_label
		url_data_other = url_data
		data_other= data
		load_items(_item_list_2, data)
	
#	if(get_tree().is_network_server()):
#		rset("data", data)
	return data




func load_items(item_list:Control = _item_list_1, data:Dictionary = data_player) -> Dictionary:
	var selected_items = item_list.get_selected_items()
	var slot_id
	if(selected_items): # check if item was selected before reloading items
		slot_id = selected_items[0]
	
	item_list.clear()
	var slot0 = 0
#	for slot in range(0, INVENTORY_MAX_SLOTS):
#	for slot in range(0, (len(data)-1)): #INVENTORY_MAX_SLOTS):
#	if data
	for slot3 in data:
		if slot3 == "inventory": # or data.inventory: #slot3 == "Inventory":
			for slot1 in data.inventory: #range(0, (len(data)-1)): #INVENTORY_MAX_SLOTS):
				item_list.add_item("", null, false)
				update_slot(slot0, item_list, data)
				slot0 += 1
		else:
			slot0 = 0
			for slot4 in data[slot3]:
				if slot4 == "inventory": 
					for slot1 in data[slot3].inventory: #range(0, (len(data)-1)): #INVENTORY_MAX_SLOTS):
						item_list.add_item("", null, false)
						update_slot(slot0, item_list, data[slot3]) # data)
						slot0 += 1
				else:
					slot0 = 0
					for slot5 in data[slot4]:
						if slot4 == "inventory": 
							for slot1 in data[slot3].inventory: #range(0, (len(data)-1)): #INVENTORY_MAX_SLOTS):
								item_list.add_item("", null, false)
								update_slot(slot0, item_list, data[slot4]) # data)
								slot0 += 1
						else:
							slot0 = 0
							for slot6 in data[slot5]:	
								item_list.add_item("", null, false)
								update_slot(slot0, item_list, data[slot5]) # data)
								slot0 += 1
	
	if(slot_id != null): # item was selected before reloading so lets reselect it
		_item_list_1.select(slot_id)
		_on_ItemList_item_selected(slot_id)
#		_update_center_item(slot_id, item_list, _get_item_id_from_slot_id(slot_id, data))
	return data


func unload_items(filename:String, item_list_label:String = "Player") -> void:
	if Global_DataParser.join_race == 0:
		load_data_empire(filename, item_list_label, true)
	if Global_DataParser.join_race == 1:
		load_data_dark(filename, item_list_label, true)
	if Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3 :
		load_data_exile(filename, item_list_label, true)

func update_slot(slot:int, item_list, data) -> void:
	if (slot < 0 or slot > (INVENTORY_MAX_SLOTS-1)):
		print("no present slot:")
		print(slot)
		return
#========================================
#	if !data.inventory[str(slot)]:
#	if !data[str(slot)]:
#		print("no present slot:")
#		print(slot)
#		return		
#	var inventory_item:Dictionary = data.inventory[str(slot)]
	var inventory_item:Dictionary = data.inventory[str(slot)]
	var item_meta_data = Global_ItemDatabase.get_item(str(inventory_item["id"])).duplicate()
#	print(item_meta_data)
	var icon = ResourceLoader.load(item_meta_data["icon"])
	var amount = int(inventory_item["amount"])
	
	item_meta_data["amount"] = amount
#	if (!item_meta_data["stackable"]):
#		amount = " " 
	if (item_meta_data["amount"] == 0):
		amount = " " 


#================================================================
	if (item_meta_data["amount"] > 0):
		print(amount)


	item_list.set_item_text(slot, String(amount))
#================================================================


	item_list.set_item_icon(slot, icon)
	item_list.set_item_selectable(slot, int(inventory_item["id"]) > 0)
	item_list.set_item_metadata(slot, item_meta_data)
	item_list.set_item_tooltip(slot, item_meta_data["name"])
	item_list.set_item_tooltip_enabled(slot, int(inventory_item["id"]) > 0)


func _update_center_item(slot_id, item_list, item_id:int):
	var item_meta_data = Global_ItemDatabase.get_item(str(item_id)).duplicate()
	$Panel/ItemNameLabel.text = item_list.get_item_tooltip(slot_id)
	$Panel/ItemSprite.texture = item_list.get_item_icon(slot_id)
	$Panel/ItemCountLabel.text = item_list.get_item_text(slot_id)
	$Panel/ItemDescriptionRichTextLabel.text = item_meta_data["description"]
	$Panel/ItemPriceLabel.text = "Price: " + var2str(stepify(float(item_meta_data["sell_price"]), 0.01)).pad_decimals(2)
	$Panel/ItemWeightLabel.text = "Weight: " + var2str(stepify(float(item_meta_data["weight"]), 0.01)).pad_decimals(2) + "kg"
	$Panel/LineEdit.text = str(1) #item_list.get_item_text(slot_id)
	print("amount")
	print(item_list.get_item_text(slot_id))
	$Panel/HSlider.max_value = float(item_list.get_item_text(slot_id))
	$Panel/HSlider.value = float(1) #float(item_list.get_item_text(slot_id))
	$Panel/HSlider.tick_count = int(item_list.get_item_text(slot_id)) / 25  + 2


func set_center_item_visible(is_center_item_visible):
	$Panel/ItemNameLabel.visible = is_center_item_visible
	$Panel/ItemSprite.visible = is_center_item_visible
	$Panel/ItemCountLabel.visible = is_center_item_visible
	$Panel/ItemDescriptionRichTextLabel.visible = is_center_item_visible
	$Panel/ItemPriceLabel.visible = is_center_item_visible
	$Panel/ItemWeightLabel.visible = is_center_item_visible
	$Panel/LineEdit.visible = is_center_item_visible
	$Panel/HSlider.visible = is_center_item_visible
	button_multi.visible = is_center_item_visible
	button_multi_use.visible = is_center_item_visible


func set_other_visible(is_visible):
	_item_list_2.clear()
	_item_list_label_2.visible = is_visible
	_item_list_2.visible = is_visible


func get_item_price(item_id:int) -> float:
	var item_meta_data = Global_ItemDatabase.get_item(str(item_id))
	return float(item_meta_data["sell_price"])


func get_item_meta_data(item_id:int) -> Dictionary:
	var item_meta_data = Global_ItemDatabase.get_item(str(item_id))
	return item_meta_data


func get_money_by_data(data) -> float:
	var money:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS - 1):
#		if(int(data.inventory[str(slot)]["id"]) == 1): #была пища вместо денег
		if(int(data.inventory[str(slot)]["id"]) == 2): #теперь золотые монеты
			money += float(data.inventory[str(slot)]["amount"])
	return money


func get_weight() -> float:
	var weight:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) != "vehicle"):
			weight += float(item_meta_data["weight"]) * float(int(data_player.inventory[str(slot)]["amount"]))
	return weight


func get_max_weight() -> float:
	var max_weight:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) == "vehicle"):
			max_weight += float(item_meta_data["max_weight"])
	return max_weight



func get_water() -> float:
	var water:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data_player.inventory[str(slot)]["id"]) == 3):
			water += float(data_player.inventory[str(slot)]["amount"])
	return water


func get_food() -> float:
	var food:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data_player.inventory[str(slot)]["id"]) == 1):
			food += float(data_player.inventory[str(slot)]["amount"])
	return food
	
func get_mana() -> float:
	var mana:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data_player.inventory[str(slot)]["id"]) == 4):
			mana += float(data_player.inventory[str(slot)]["amount"])
#	print ("mana")
#	print (mana)		
	return mana


func get_vehicles_min_speed() -> float:
	var min_speed:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) == "vehicle"):
			if(int(min_speed) > int(item_meta_data["max_speed"]) || int(min_speed) == 0):
				min_speed = float(item_meta_data["max_speed"])
	return min_speed
	
func get_weapon_max_damage() -> float:
	var max_damage:float = 0.0
	for slot in range (0, INVENTORY_MAX_SLOTS):
		var item_id:int = int(data_player.inventory[str(slot)]["id"])
		var item_meta_data:Dictionary = get_item_meta_data(item_id)
		if(str(item_meta_data["type"]) == "weapon"):
			if(int(max_damage) > int(item_meta_data["damage"]) || int(max_damage) == 0):
				max_damage = float(item_meta_data["damage"])
	return max_damage


func remove_item_amount_by_id(item_id:int, amount:float, data:Dictionary) -> Dictionary:
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == item_id):
			data.inventory[str(slot)]["amount"] = float(data.inventory[str(slot)]["amount"])
			if(data.inventory[str(slot)]["amount"] < amount):
				amount = amount - data.inventory[str(slot)]["amount"]
				data.inventory[str(slot)]["amount"] = 0.00
				data.inventory[str(slot)]["id"] = "0"
			else:
				data.inventory[str(slot)]["amount"] = data.inventory[str(slot)]["amount"] - amount
				if(data.inventory[str(slot)]["amount"] <= 0):
					data.inventory[str(slot)]["id"] = "0"
				break
	return data


func minus_money(amount:float, data:Dictionary) -> Dictionary:
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == 2): # теперь золото вместо пищи
			data.inventory[str(slot)]["amount"] = float(data.inventory[str(slot)]["amount"])
			if(data.inventory[str(slot)]["amount"] < amount):
				amount = amount - data.inventory[str(slot)]["amount"]
				data.inventory[str(slot)]["amount"] = 0.00
				data.inventory[str(slot)]["id"] = "0"
			else:
				data.inventory[str(slot)]["amount"] = data.inventory[str(slot)]["amount"] - amount
				if(data.inventory[str(slot)]["amount"] <= 0):
					data.inventory[str(slot)]["id"] = "0"
				break
				
	return data


func plus_money(amount, data) -> Dictionary:
	for slot in range (0, INVENTORY_MAX_SLOTS):
		if(int(data.inventory[str(slot)]["id"]) == 2):
			data.inventory[str(slot)]["amount"] += amount
			return data
	data = inventory_add_item(1,amount,data)
	return data


func inventory_get_empty_slot(data) -> int:
	if(data):
		for slot in range(0, INVENTORY_MAX_SLOTS):
			if (int(data.inventory[str(slot)]["id"]) == 0): 
				return int(slot)
		print ("Inventory is full!")
		get_parent().show_info("Inventory is full!")
	return -1


func is_inventory_empty_by_data(data) -> bool:
	if(data):
		for slot in range(0, INVENTORY_MAX_SLOTS):
			if (int(data.inventory[str(slot)]["id"]) != 0): 
				return false
		print ("Inventory is empty!")
	return true


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


remote func inventory_save_items(url_data, data):
	Global_DataParser.write_data(url_data, data)


func _get_item_id_from_slot_id(slot_id:int, data) -> int:
	return int(data["inventory"][str(slot_id)]["id"])


func _on_ItemList_item_selected(index):
	if(!_item_list_1.get_item_text(index) == " "):
		var item_id = _get_item_id_from_slot_id(index, data_player)
		_update_center_item(index, _item_list_1, item_id)
		set_center_item_visible(true)
		if(button_multi.text == "Buy" || button_multi.text == "Sell" ):
			button_multi.text = "Sell"
		elif(button_multi.text == "Take" && _item_list_2.visible):
			button_multi.text = "Give"
	_item_list_2.unselect_all()


func _on_ItemList2_item_selected(index):
	if(!_item_list_2.get_item_text(index) == " "):
		var item_id = _get_item_id_from_slot_id(index, data_other)
		_update_center_item(index, _item_list_2, item_id)
		set_center_item_visible(true)
		if(button_multi.text == "Buy" || button_multi.text == "Sell" ):
			button_multi.text = "Buy"
		elif(button_multi.text == "Give" && _item_list_2.visible):
			button_multi.text = "Take"
	_item_list_1.unselect_all()


func _on_HSlider_value_changed(value):
	$Panel/LineEdit.text = var2str(int(value)).replace('"', '')

func _on_Button_pressed():
	_on_Button_pressed1(0)
func _on_Button_pressed1(event):
	print("button drop use pressed")

	var use = event
	print(use)
	if(_item_list_2.visible):
		use = 0	
	var selected_items_player = $Panel/ItemList.get_selected_items()
	var selected_items_shop = $Panel/ItemList2.get_selected_items()
	var selected_items
	
	var item_list
	var data
	
	if(!selected_items_player.empty()):
		selected_items = selected_items_player
		item_list = _item_list_1
		data = data_player
	elif(!selected_items_shop.empty()):
		selected_items = selected_items_shop
		item_list = _item_list_2
		data = data_other
#	print("button drop use pressed 2")
	if(selected_items && item_list):
		var item_id = int(data.inventory[str(selected_items[0])]["id"])
		var amount_max= int(data.inventory[str(selected_items[0])]["amount"])
		
		var slot_id = int(selected_items[0])
		var amount = float($Panel/LineEdit.text)
#		print("button drop use pressed 3")
		if(amount > 0):
#			print("button drop use pressed 4")
			if(_item_list_2.visible):
				if use == 0:
					print("button drop use pressed shop")
	#				if(item_id == 1): return ## dont trade money for money lol, server resources are MY PRECIOUSSS
					if(button_multi.text == "Buy"):
						if(get_money_by_data(data_player) >= get_item_price(item_id) * amount):
							inventory_add_item(item_id,amount,data_player)
							minus_money(get_item_price(item_id) * amount, data_player)
							plus_money(get_item_price(item_id) * amount, data_other)
		#					rpc("inventory_save_items", url_data_player, data_player)
		#					rpc("inventory_save_items", url_data_other, data_other)
		#					rset('data_player', data_player)
		#					rset('data_other', data_other)
						else:
							print("Not enough money player!")
							get_parent().show_info("Not enough money player!")
							return
					elif(button_multi.text == "Sell" || button_multi.text == "Trade"):
						if(get_money_by_data(data_other) >= get_item_price(item_id) * amount):
							inventory_add_item(item_id,amount,data_other)
							minus_money(get_item_price(item_id) * amount, data_other)
							plus_money(get_item_price(item_id) * amount, data_player)
		#					rpc("inventory_save_items", url_data_player, data_player)
		#					rpc("inventory_save_items", url_data_other, data_other)
		#					rset('data_player', data_player)
		#					rset('data_other', data_other)
						else:
							print("Not enough money shop!")
							get_parent().show_info("Not enough money shop!")
							return
					elif(button_multi.text == "Take"):
						if amount > amount_max:
							amount = amount_max						
						inventory_add_item(item_id,amount,data_player)
					elif(button_multi.text == "Give"):
						if amount > amount_max:
							amount = amount_max
						inventory_add_item(item_id,amount,data_other)
				else:
#					get_tree().change_scene('res://Scenes/Map/MapLocalDungeon_WildLands.tscn')
#					set_center_item_visible(false)
#					get_parent().update_vars()
					return
#					position = Vector2(-30.0,-200.0)
#					print("new position")
#					rset_unreliable('slave_position', Vector2(-23000.0,0.0))

			elif(button_multi.text == "Drop"):
				print("button drop use pressed DROP 1")
				data_other = {"inventory":{}} # create empty inventory
				for slot_id1 in range (0, INVENTORY_MAX_SLOTS): # fill empty inventory with placeholder
					data_other["inventory"][str(slot_id1)] = {"id": "0", "amount": 0}
				print("button drop use pressed after FOR")
				print(use)	
#				data_other = inventory_add_item(item_id,amount,data_other) # add item to inventory
				if use == 1:
					use=0
					print("USE ITEM")
#					if item_id == 2:
#						health = max_health
					if (item_id >= 1 and item_id <=4) or (item_id >=7 and item_id <=26):
						print("USE ITEM Build")
						print(item_id)

						data_other = inventory_add_item(item_id,1,data_other) # add item to inventory
						if item_id == 1:
							get_parent().damage_health = -20
						if item_id == 3:
							get_parent().damage_health = -0.5*(get_parent().max_health)
						if item_id == 4:
							get_parent().damage_mana = -0.5*(get_parent().max_mana)

						if item_id == 7:
							if (Global_DataParser.get_energy() > 950):		
								Global_DataParser.reduce_energy(950)
			
								get_parent().rpc_spawn_town(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 8:
							if (Global_DataParser.get_energy() > 1000):		
								Global_DataParser.reduce_energy(1000)
							
								get_parent().rpc_spawn_village(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 9:
							if (Global_DataParser.get_energy() > 1000000):		
								Global_DataParser.reduce_energy(1000000)
							
								get_parent().rpc_spawn_capital(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 10:
							if (Global_DataParser.get_energy() > 3000):		
								Global_DataParser.reduce_energy(3000)
							
								get_parent().rpc_spawn_fortress(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 11:
							if (Global_DataParser.get_energy() > 2500000):		
								Global_DataParser.reduce_energy(250000)

								get_parent().rpc_spawn_castle(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 12:
							if (Global_DataParser.get_energy() > 25000):		
								Global_DataParser.reduce_energy(25000)
							
								get_parent().rpc_spawn_magictower(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 14:
							if (Global_DataParser.get_energy() > 50000):		
								Global_DataParser.reduce_energy(50000)

								get_parent().rpc_spawn_barack(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)

						if item_id == 13:
							if (Global_DataParser.get_energy() > 750):		
								Global_DataParser.reduce_energy(750)
							
								get_parent().rpc_spawn_temple(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 15:
							if (Global_DataParser.get_energy() > 5000000):		
								Global_DataParser.reduce_energy(5000000)
							
								get_parent().rpc_spawn_dark_fortress(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)

						if item_id == 16:
							if (Global_DataParser.get_energy() > 2000):		
								Global_DataParser.reduce_energy(2000)

								get_parent().rpc_spawn_village(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 17:
							if (Global_DataParser.get_energy() > 25000):		
								Global_DataParser.reduce_energy(25000)

								get_parent().rpc_spawn_start_town(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
						if item_id == 26:
							if (Global_DataParser.get_energy() > 100000):		
								Global_DataParser.reduce_energy(100000)
							
								get_parent().rpc_spawn_storage(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)

					if item_id >=18 and item_id <=25:
						print("USE Spawn Mobs")
						print(item_id)
						rpc_spawn_mobs(item_id, amount)
#					if item_id == 3:
#						$Health.value = 100
#					if item_id == 1:
#						$Health.value += 20
#						if  $Health.value > 100:
#							$Health.value = 100	

				elif use == 0:
					print("drop item")
					data_other = inventory_add_item(item_id,amount,data_other) # add item to inventory

					get_parent().rpc_spawn_bag(get_parent().get_node("NicknameLabel").text, data_other, get_parent().global_position, url_data)
				
			if(data.inventory[str(slot_id)]["amount"] - amount > 0):
				data.inventory[str(slot_id)]["amount"] -= amount
			else:
				data.inventory[str(slot_id)]["id"] = 0
				data.inventory[str(slot_id)]["amount"] = 0
	
			if(!data_player.empty()):
				Global_DataParser.write_data(url_data_player, data_player)
				var url_bag_data = GlobalData.path + "player_" + str(Global_DataParser._player_name) + "_bag.json"
				Utility.saveDictionary(url_bag_data, data_player)
				load_items(_item_list_1, data_player)
			if(!data_other.empty()):
#				print("url data other")
#				print(url_data_other)
#				print("data other")
#				print(data_other)
#				print("end data other")				
				Global_DataParser.write_data(url_data_other, data_other)
				load_items(_item_list_2, data_other)
			
			set_center_item_visible(false)
			get_parent().update_vars()

func rpc_spawn_mobs(item_id,amount): #(nickname:String, data:Dictionary, die_position:Vector2, url_data:String="") -> void:
	if(is_network_master()):
#		print("prepare spawn")
#		print(position)
		rpc("spawn_mobs", "AngryAnimal", get_global_mouse_position(),item_id,amount)
	


sync func spawn_mobs(nickname:String, die_position:Vector2,item_id,amount): #, url_data:String="") -> void:
#	if(!_inventory.is_inventory_empty_by_data(data)):
	print("spawning stage 1")
	print(item_id)
	if item_id == 20:
		if (Global_DataParser.get_energy() > 2000):		
			Global_DataParser.reduce_energy(2000)
		
			var town = load('res://Scenes/Race/Ork.tscn').instance()
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())

			$'/root/Game/Empire'.add_child(town)
			print("Ork spawning rpc end")
			town.position = get_global_mouse_position() - Vector2(164,164)
			Global_DataParser.inc_ork(1)

	if item_id == 21:
		if (Global_DataParser.get_energy() > 4000):		
			Global_DataParser.reduce_energy(4000)

			var town = load('res://Scenes/Race/Mag.tscn').instance()
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())

			$'/root/Game/Neutral'.add_child(town)
			print("Mag spawning rpc end")
	#		town.position = get_global_mouse_position()+Vector2(64,64)
			Global_DataParser.inc_magfire(1)

	if item_id == 19:
		if (Global_DataParser.get_energy() > 12000):		
			Global_DataParser.reduce_energy(12000)

			var town = load('res://Scenes/Race/Alchemist.tscn').instance()
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())

			$'/root/Game/Neutral'.add_child(town)
			print("Alchemist spawning rpc end")
			town.position = get_global_mouse_position() - Vector2(100,100)
	#		town.DamagePos.position = get_global_mouse_position()
	if item_id == 22:
		if (Global_DataParser.get_energy() > 20000):		
			Global_DataParser.reduce_energy(20000)

			var town = load('res://Scenes/Race/Priest.tscn').instance()
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())

			$'/root/Game/Neutral'.add_child(town)
			print("Priest spawning rpc end")
			town.position = get_global_mouse_position()-Vector2(64,64)

	if item_id == 23:
		if (Global_DataParser.get_energy() > 50000):		
			Global_DataParser.reduce_energy(50000)

			var town = load('res://Scenes/Race/PriestExile.tscn').instance()
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())

			$'/root/Game/Neutral'.add_child(town)
			print("PriestExile spawning rpc end")
			town.position = get_global_mouse_position()


	if item_id == 24:
		if (Global_DataParser.get_energy() > 25000):		
			Global_DataParser.reduce_energy(25000)

			var town = load('res://Scenes/Race/Crafter.tscn').instance()
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())

			$'/root/Game/Neutral'.add_child(town)
			print("PriestExile spawning rpc end")
			town.position = get_global_mouse_position()-Vector2(64,64)


	if item_id == 25:
		if (Global_DataParser.get_energy() > 100000):		
			Global_DataParser.reduce_energy(100000)

			var town = load('res://Scenes/Race/Vampire_High.tscn').instance()	
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())
			add_npc_on_location(town)						
			print("Animal spawning rpc end")
			town.position = get_global_mouse_position()-Vector2(64,64)
			town.set_player_id(get_parent())
			Global_DataParser.inc_mobs(11,1)		
	if item_id == 18:
		if (Global_DataParser.get_energy() > 5000):		
			Global_DataParser.reduce_energy(5000)
			
			var town = load('res://Scenes/Race/Peasant2.tscn').instance()	
			town.name = nickname + "_" + str(Global_DataParser.rng.randi())
			add_npc_on_location(town)

			print("Peasant spawning")
			town.position = get_global_mouse_position()-Vector2(64,64)
			Global_DataParser.inc_mobs(8,1)
			

	print("spawning rpc end")
func add_npc_on_location(npc):
		if  Global_DataParser.location_number == 1:
			$'/root/Game/Empire'.add_child(npc)
		elif  Global_DataParser.location_number == 2:
			$'/root/Game/Dark'.add_child(npc)
		elif  Global_DataParser.location_number == 3:
			$'/root/Game/Neutral'.add_child(npc)
		else:
			get_parent().get_node("Chat").get_node("Panel").get_node("RichTextLabel").text += "Failure. I can not do it here!\n"			
func _on_Use_pressed():
	_on_Button_pressed1(1)
