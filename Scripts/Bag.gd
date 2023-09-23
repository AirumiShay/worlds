extends Node2D


onready var _url_data:String = ""
onready var _data:Dictionary = Dictionary()
var _name:String

func _ready():
	set_process(false)
	set_process_input(false)


sync func init(inventory:Control, name:String, data:Dictionary, spawn_position:Vector2, url_data:String = ""):
#	rpc("load_data", inventory, name, "Bag", data)
	_name = name
	_url_data = url_data
	_data = inventory.load_data(name, "Bag")
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
#	_data = inventory.load_data(_name, "Bag")
	_data = inventory.load_data_empire(_name, "Player")
	return _data
	if Global_DataParser.join_race == 0:	
		_data = inventory.load_data_empire(_name, "Player")
	elif Global_DataParser.join_race == 1:	
		_data = inventory.load_data_dark(_name, "Player")
	elif Global_DataParser.join_race == 2 or Global_DataParser.join_race == 3:	
		_data = inventory.load_data_exile(_name, "Player")				
	return _data
#func load_data_empire(name, item_list_label:String = "Player") -> Dictionary:
#	return _inventory.load_data_empire(name, item_list_label)
#func load_data_dark(name, item_list_label:String = "Player") -> Dictionary:
#	return _inventory.load_data_dark(name, item_list_label)
#func load_data_exile(name, item_list_label:String = "Player") -> Dictionary:
#	return _inventory.load_data_exile(name, item_list_label)


func is_data_empty_by_inventory(inventory:Control) -> bool:
	return inventory.is_inventory_empty_by_data(_data)


func rpc_destroy_self():
	rpc("destroy_self")


sync func destroy_self() -> void:
	for child in get_children():
		if child.has_method('queue_free'):
			child.queue_free()
	Global_DataParser.delete_file(_url_data)
