extends Node2D

const INVENTORY_MAX_SLOTS = 100
onready var _url_data:String = ""
onready var _data = {
		"inventory":[]
		} #Dictionary()
#var _new_data = {
#		"Empire":[]
#		}
var _name:String

func _ready():
	set_process(false)
	set_process_input(false)


sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
#	_data = data #load_data(inventory, name, "Bag", data)
#	_data = load_data_bag_player("default")
	_data = load_datanpc(name,"Bag")
	Utility.saveDictionary(GlobalData.path + "player_"+ str(_name) + "_bag.json", _data)		
#	_data = load_data_bag_player(_name)	
	position = spawn_position
#заполняем инвентарь npc
func load_datanpc(filename:String, item_list_label:String = "Player", is_clear_items:bool = false, is_save_data:bool = false, data_save:Dictionary = {}, load_from_url_data:String = "") -> Dictionary:
	print("new load data bag_npc boss")
	print(filename)
	var data:Dictionary
	var url_bag_data = GlobalData.path + "player_" + str(filename) + "_bag.json"
	var _bag_data = Utility.loadDictionary(url_bag_data)
	if _bag_data == null:
		var url_data = "res://Database//" + str(filename)  + "_bag.json"
		data = Global_DataParser.load_data(url_data)
	
		if (data.empty()):
			var dict:Dictionary = {"inventory":{}}
			for slot in range (0, INVENTORY_MAX_SLOTS):
				if(int(slot) == 0 && !is_clear_items):
					print("load bag npc boss")
					dict["inventory"][str(slot)] = {"id": "1", "amount": 10}
				elif(int(slot) == 1 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "3", "amount": 5}

				elif(int(slot) == 2 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "2", "amount": 500}
				elif(int(slot) == 3&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "5", "amount": 2}
				elif(int(slot) == 4&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "51", "amount": 1}
				elif(int(slot) == 5&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "4", "amount": 3}
									
				elif(int(slot) == 6 && !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "14", "amount": 5}
				elif(int(slot) == 7&&  !is_clear_items):
					dict["inventory"][str(slot)] = {"id": "11", "amount": 10}

				else:
					dict["inventory"][str(slot)] = {"id": "0", "amount": 0}
#			Global_DataParser.write_data(url_data, dict)
#			_bag_data = dict	
			Utility.saveDictionary(url_bag_data, dict)
			print (_bag_data)
			_bag_data = Utility.loadDictionary(url_bag_data)
			print (_bag_data)			
		else:
			_bag_data = data	
#	print(_bag_data)
	data = _bag_data
#	if(item_list_label == "Player"):
#		_item_list_label_1.text = "Inventory"
#		url_data_player = url_data
#		data_player = data
#		load_items(_item_list_1, data)
#	else:
#		_item_list_label_2.text = item_list_label
#		url_data_other = url_data
#		data_other= _bag_data
#		load_items(_item_list_2, _bag_data)
	
	return _bag_data

func load_data_bag_player(_name):
	var _bag_data = Utility.loadDictionary(GlobalData.path + "player_"+ str(_name) + "_bag.json")

	return	_bag_data	

func load_data(inventory:Control, filename:String, item_list_label:String = "Bag", data_player:Dictionary = Dictionary()): # -> Dictionary:
	if(item_list_label == "Bag"):
		var url_data = "res://Database//data_bag_" + filename + ".json"
		var data = Global_DataParser.load_data(url_data)
		if ((data.empty() && item_list_label == "Bag" && !data_player.empty())):
			Global_DataParser.write_data(url_data, data_player)
			data = data_player
			return data
	else:
		return data_player	

func reload_data_by_inventory(inventory:Control) -> Dictionary:
#	_data = inventory.load_data(_name, "Bag")
#	_data = load_data(inventory, _name, "Bag")
	var url_bag_data = GlobalData.path + str(name) + "_bag.json"
	_data = Utility.loadDictionary(url_bag_data)
#	_data = load_data_bag_player(_name)		
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
